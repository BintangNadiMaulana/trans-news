//
//  NewsAPIService.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import Foundation

enum NewsAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case emptyData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL berita tidak valid."
        case .invalidResponse:
            return "Gagal mengambil data berita."
        case .emptyData:
            return "Berita tidak tersedia saat ini."
        }
    }
}

struct NewsAPIService: Sendable {
    static let shared = NewsAPIService()

    private init() {}

    func fetchNews(category: NewsCategory = .general, country: String = "id") async throws -> [NewsArticleDTO] {
        let locale = NewsLocale(country: country)
        let urlString = feedURL(for: category, locale: locale)
        return try await fetchRSS(from: urlString, fallbackCategory: category.rawValue)
    }

    func searchNews(query: String, country: String = "id") async throws -> [NewsArticleDTO] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let locale = NewsLocale(country: country)
        guard let encodedQuery = trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NewsAPIError.invalidURL
        }

        let urlString = "https://news.google.com/rss/search?q=\(encodedQuery)&hl=\(locale.languageCode)&gl=\(locale.regionCode)&ceid=\(locale.regionCode):\(locale.languageCode)"
        return try await fetchRSS(from: urlString, fallbackCategory: NewsCategory.general.rawValue)
    }

    private func feedURL(for category: NewsCategory, locale: NewsLocale) -> String {
        let base = "https://news.google.com/rss"

        guard let topic = category.googleNewsTopic else {
            return "\(base)?hl=\(locale.languageCode)&gl=\(locale.regionCode)&ceid=\(locale.regionCode):\(locale.languageCode)"
        }

        return "\(base)/headlines/section/topic/\(topic)?hl=\(locale.languageCode)&gl=\(locale.regionCode)&ceid=\(locale.regionCode):\(locale.languageCode)"
    }

    private func fetchRSS(from urlString: String, fallbackCategory: String) async throws -> [NewsArticleDTO] {
        guard let url = URL(string: urlString) else {
            throw NewsAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NewsAPIError.invalidResponse
        }

        let parser = GoogleNewsRSSParser(defaultCategory: fallbackCategory)
        let articles = parser.parse(data: data)

        guard !articles.isEmpty else {
            throw NewsAPIError.emptyData
        }

        return articles
    }
}

private struct NewsLocale {
    let languageCode: String
    let regionCode: String

    init(country: String) {
        switch country.lowercased() {
        case "us":
            languageCode = "en"
            regionCode = "US"
        default:
            languageCode = "id"
            regionCode = "ID"
        }
    }
}

private extension NewsCategory {
    var googleNewsTopic: String? {
        switch self {
        case .general:
            return nil
        case .business:
            return "BUSINESS"
        case .technology:
            return "TECHNOLOGY"
        case .entertainment:
            return "ENTERTAINMENT"
        case .health:
            return "HEALTH"
        case .science:
            return "SCIENCE"
        case .sports:
            return "SPORTS"
        }
    }
}

private final class GoogleNewsRSSParser: NSObject, XMLParserDelegate {
    private var articles: [NewsArticleDTO] = []
    private var currentItem: RSSItem?
    private var currentElement = ""
    private var currentValue = ""

    init(defaultCategory: String) {
        _ = defaultCategory
    }

    func parse(data: Data) -> [NewsArticleDTO] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return articles
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentValue = ""

        if elementName == "item" {
            currentItem = RSSItem()
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let trimmedValue = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)

        switch elementName {
        case "title":
            currentItem?.title = trimmedValue
        case "link":
            currentItem?.link = trimmedValue
        case "pubDate":
            currentItem?.pubDate = trimmedValue
        case "description":
            currentItem?.description = Self.cleanDescription(trimmedValue)
        case "source":
            currentItem?.source = trimmedValue
        case "item":
            if let currentItem, let article = article(from: currentItem) {
                articles.append(article)
            }
            currentItem = nil
        default:
            break
        }
    }

    private func article(from item: RSSItem) -> NewsArticleDTO? {
        guard !item.title.isEmpty, !item.link.isEmpty else {
            return nil
        }

        let parsedTitleSource = Self.splitTitleAndSource(item.title)
        let publishedAt = Self.isoDateString(from: item.pubDate)

        return NewsArticleDTO(
            source: NewsSource(id: nil, name: item.source.isEmpty ? parsedTitleSource.source : item.source),
            author: item.source.isEmpty ? parsedTitleSource.source : item.source,
            title: parsedTitleSource.title,
            description: item.description.isEmpty ? nil : item.description,
            url: item.link,
            urlToImage: nil,
            publishedAt: publishedAt,
            content: item.description.isEmpty ? nil : item.description
        )
    }

    private static func splitTitleAndSource(_ rawTitle: String) -> (title: String, source: String) {
        let parts = rawTitle.components(separatedBy: " - ")
        if parts.count >= 2 {
            let source = parts.last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Google News"
            let title = parts.dropLast().joined(separator: " - ").trimmingCharacters(in: .whitespacesAndNewlines)
            return (title.isEmpty ? rawTitle : title, source.isEmpty ? "Google News" : source)
        }

        return (rawTitle, "Google News")
    }

    private static func isoDateString(from pubDate: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let date = formatter.date(from: pubDate) ?? Date()
        return ISO8601DateFormatter().string(from: date)
    }

    private static func cleanDescription(_ rawDescription: String) -> String {
        let withoutHTML = rawDescription.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        let withoutEntities = withoutHTML
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
        return withoutEntities
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct RSSItem {
    var title = ""
    var link = ""
    var pubDate = ""
    var description = ""
    var source = ""
}
