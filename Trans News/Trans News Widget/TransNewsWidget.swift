//
//  TransNewsWidget.swift
//  Trans News Widget
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI
import WidgetKit

struct TransNewsWidgetEntry: TimelineEntry {
    let date: Date
    let headlines: [WidgetHeadline]
    let isEnglish: Bool
}

struct WidgetHeadline: Identifiable {
    let id: String
    let title: String
    let source: String
    let publishedAt: Date
    let articleURL: String
}

struct TransNewsWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TransNewsWidgetEntry {
        TransNewsWidgetEntry(
            date: Date(),
            headlines: [
                WidgetHeadline(id: "1", title: "Breaking news headline will appear here", source: "Trans News", publishedAt: Date(), articleURL: "https://news.google.com"),
                WidgetHeadline(id: "2", title: "Widget menampilkan ringkasan berita terbaru", source: "Google News", publishedAt: Date().addingTimeInterval(-3600), articleURL: "https://news.google.com")
            ],
            isEnglish: WidgetLanguage.current == .english
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TransNewsWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TransNewsWidgetEntry>) -> Void) {
        Task {
            let headlines = await WidgetNewsService().fetchHeadlines()
            let entry = TransNewsWidgetEntry(
                date: Date(),
                headlines: headlines,
                isEnglish: WidgetLanguage.current == .english
            )
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
}

struct TransNewsWidget: Widget {
    let kind = "TransNewsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TransNewsWidgetProvider()) { entry in
            TransNewsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(widgetURL(for: entry))
        }
        .configurationDisplayName("Trans News")
        .description("Lihat headline terbaru langsung dari Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }

    private func widgetURL(for entry: TransNewsWidgetEntry) -> URL? {
        guard let headline = entry.headlines.first else { return nil }
        var components = URLComponents()
        components.scheme = "transnews"
        components.host = "article"
        components.queryItems = [
            URLQueryItem(name: "id", value: headline.id),
            URLQueryItem(name: "title", value: headline.title),
            URLQueryItem(name: "source", value: headline.source),
            URLQueryItem(name: "url", value: headline.articleURL),
            URLQueryItem(name: "publishedAt", value: String(headline.publishedAt.timeIntervalSince1970))
        ]
        return components.url
    }
}

struct TransNewsWidgetView: View {
    let entry: TransNewsWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        default:
            mediumWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            widgetHeader

            if let headline = entry.headlines.first {
                Text(headline.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(4)

                Spacer()

                Text(headline.source)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text(entry.isEnglish ? "No stories available" : "Belum ada berita")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    private var mediumWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            widgetHeader

            ForEach(entry.headlines.prefix(3)) { headline in
                VStack(alignment: .leading, spacing: 4) {
                    Text(headline.title)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(2)
                    HStack(spacing: 6) {
                        Text(headline.source)
                        Text("•")
                        Text(headline.publishedAt.widgetTimeAgo(isEnglish: entry.isEnglish))
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
    }

    private var widgetHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Trans News")
                    .font(.headline)
                Text(entry.isEnglish ? "Top headlines" : "Headline terbaru")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "newspaper.fill")
                .foregroundStyle(.orange)
        }
    }
}

private actor WidgetNewsService {
    func fetchHeadlines() async -> [WidgetHeadline] {
        let isEnglish = WidgetLanguage.current == .english
        let feedURL = isEnglish
            ? "https://news.google.com/rss?hl=en-US&gl=US&ceid=US:en"
            : "https://news.google.com/rss?hl=id&gl=ID&ceid=ID:id"

        guard let url = URL(string: feedURL) else { return [] }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return []
            }
            return WidgetRSSParser().parse(data: data)
        } catch {
            return []
        }
    }
}

private final class WidgetRSSParser: NSObject, XMLParserDelegate {
    private var headlines: [WidgetHeadline] = []
    private var currentItem: WidgetRSSItem?
    private var currentElement = ""
    private var currentValue = ""

    func parse(data: Data) -> [WidgetHeadline] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return Array(headlines.prefix(3))
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentValue = ""

        if elementName == "item" {
            currentItem = WidgetRSSItem()
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let trimmed = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)

        switch elementName {
        case "title":
            currentItem?.title = trimmed
        case "source":
            currentItem?.source = trimmed
        case "link":
            currentItem?.link = trimmed
        case "pubDate":
            currentItem?.pubDate = trimmed
        case "item":
            if let headline = currentItem?.makeHeadline() {
                headlines.append(headline)
            }
            currentItem = nil
        default:
            break
        }
    }
}

private struct WidgetRSSItem {
    var title = ""
    var source = ""
    var link = ""
    var pubDate = ""

    func makeHeadline() -> WidgetHeadline? {
        guard !title.isEmpty else { return nil }

        let split = title.components(separatedBy: " - ")
        let headlineTitle: String
        let fallbackSource: String

        if split.count >= 2 {
            headlineTitle = split.dropLast().joined(separator: " - ")
            fallbackSource = split.last ?? "Google News"
        } else {
            headlineTitle = title
            fallbackSource = "Google News"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let parsedDate = formatter.date(from: pubDate) ?? Date()

        return WidgetHeadline(
            id: link.isEmpty ? headlineTitle : link,
            title: headlineTitle,
            source: source.isEmpty ? fallbackSource : source,
            publishedAt: parsedDate,
            articleURL: link.isEmpty ? "https://news.google.com" : link
        )
    }
}

private enum WidgetLanguage: String {
    case indonesian = "id"
    case english = "en"

    static var current: WidgetLanguage {
        WidgetLanguage(rawValue: UserDefaults(suiteName: "group.NEWS.Trans-News")?.string(forKey: "selectedLanguage")
            ?? UserDefaults.standard.string(forKey: "selectedLanguage")
            ?? Locale.current.language.languageCode?.identifier
            ?? "id") ?? .indonesian
    }
}

private extension Date {
    func widgetTimeAgo(isEnglish: Bool) -> String {
        let minutes = max(Int(Date().timeIntervalSince(self) / 60), 0)
        if minutes < 60 {
            return isEnglish ? "\(minutes)m ago" : "\(minutes)m lalu"
        }

        let hours = minutes / 60
        if hours < 24 {
            return isEnglish ? "\(hours)h ago" : "\(hours)j lalu"
        }

        let days = hours / 24
        return isEnglish ? "\(days)d ago" : "\(days)h lalu"
    }
}

#Preview(as: .systemMedium) {
    TransNewsWidget()
} timeline: {
    TransNewsWidgetEntry(
        date: Date(),
        headlines: [
            WidgetHeadline(id: "1", title: "Indonesia markets rally as investors watch regional growth", source: "Reuters", publishedAt: Date(), articleURL: "https://news.google.com"),
            WidgetHeadline(id: "2", title: "Apple expands on-device AI features across iPhone lineup", source: "The Verge", publishedAt: Date().addingTimeInterval(-3600), articleURL: "https://news.google.com"),
            WidgetHeadline(id: "3", title: "Timnas Indonesia menatap laga penting pekan ini", source: "Kompas", publishedAt: Date().addingTimeInterval(-7200), articleURL: "https://news.google.com")
        ],
        isEnglish: false
    )
}
