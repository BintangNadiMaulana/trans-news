//
//  NewsArticle.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import Foundation
import SwiftData

// MARK: - API Response Models
struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticleDTO]
}

struct NewsArticleDTO: Codable {
    let source: NewsSource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct NewsSource: Codable {
    let id: String?
    let name: String
}

// MARK: - App Models
@Model
final class NewsArticle {
    @Attribute(.unique) var id: String
    var title: String
    var articleDescription: String?
    var content: String?
    var author: String?
    var sourceName: String
    var url: String
    var imageURL: String?
    var publishedAt: Date
    var category: String
    var isBookmarked: Bool
    var isRead: Bool
    
    init(
        id: String = UUID().uuidString,
        title: String,
        articleDescription: String? = nil,
        content: String? = nil,
        author: String? = nil,
        sourceName: String,
        url: String,
        imageURL: String? = nil,
        publishedAt: Date,
        category: String = "general",
        isBookmarked: Bool = false,
        isRead: Bool = false
    ) {
        self.id = id
        self.title = title
        self.articleDescription = articleDescription
        self.content = content
        self.author = author
        self.sourceName = sourceName
        self.url = url
        self.imageURL = imageURL
        self.publishedAt = publishedAt
        self.category = category
        self.isBookmarked = isBookmarked
        self.isRead = isRead
    }
    
    // Convert from DTO
    static func from(dto: NewsArticleDTO, category: String = "general") -> NewsArticle {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: dto.publishedAt) ?? Date()
        
        return NewsArticle(
            id: dto.url,
            title: dto.title,
            articleDescription: dto.description,
            content: dto.content,
            author: dto.author,
            sourceName: dto.source.name,
            url: dto.url,
            imageURL: dto.urlToImage,
            publishedAt: date,
            category: category
        )
    }
    
    // Localized category name
    var localizedCategory: String {
        NewsCategory(rawValue: category)?.displayName ?? category.capitalized
    }
}

// MARK: - News Category
enum NewsCategory: String, CaseIterable, Identifiable {
    case general = "general"
    case business = "business"
    case technology = "technology"
    case entertainment = "entertainment"
    case health = "health"
    case science = "science"
    case sports = "sports"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .general: return AppLanguage.current == .english ? "Top" : "Terkini"
        case .business: return AppLanguage.current == .english ? "Business" : "Bisnis"
        case .technology: return AppLanguage.current == .english ? "Technology" : "Teknologi"
        case .entertainment: return AppLanguage.current == .english ? "Entertainment" : "Hiburan"
        case .health: return AppLanguage.current == .english ? "Health" : "Kesehatan"
        case .science: return AppLanguage.current == .english ? "Science" : "Sains"
        case .sports: return AppLanguage.current == .english ? "Sports" : "Olahraga"
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "newspaper"
        case .business: return "briefcase"
        case .technology: return "laptopcomputer"
        case .entertainment: return "tv"
        case .health: return "cross.case"
        case .science: return "atom"
        case .sports: return "sportscourt"
        }
    }
}
