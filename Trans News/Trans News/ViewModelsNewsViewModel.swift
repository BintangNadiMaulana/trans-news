//
//  NewsViewModel.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class NewsViewModel {
    // MARK: - Home data (tidak pernah ditimpa oleh search/category)
    var homeArticles: [NewsArticle] = []
    var featuredArticles: [NewsArticle] = []
    
    // MARK: - Per-context data
    var articles: [NewsArticle] = []
    var searchResults: [NewsArticle] = []
    var categoryArticleCounts: [NewsCategory: Int] = [:]
    var recommendedArticles: [NewsArticle] = []
    
    var isLoading = false
    var errorMessage: String?
    var selectedCategory: NewsCategory = .general
    var searchText = ""
    var isSearching = false
    var showError = false
    var recentSearches: [String] = []
    var dominantCategory: NewsCategory?
    
    /// Bahasa berita dari Settings (dibaca langsung dari UserDefaults)
    var newsLanguage: String {
        UserDefaults.standard.string(forKey: "selectedLanguage") ?? "id"
    }
    
    private let apiService = NewsAPIService.shared
    private var modelContext: ModelContext?
    private var searchTask: Task<Void, Never>?
    
    private let recentSearchesKey = "recentSearches"
    private let maxRecentSearches = 8
    
    init() {
        loadRecentSearches()
    }
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Load News
    
    func loadNews(category: NewsCategory? = nil) async {
        isLoading = true
        errorMessage = nil
        
        let categoryToFetch = category ?? selectedCategory
        selectedCategory = categoryToFetch
        
        do {
            let articleDTOs = try await apiService.fetchNews(category: categoryToFetch, country: newsLanguage == "en" ? "us" : "id")
            var newsArticles = articleDTOs.map { dto in
                NewsArticle.from(dto: dto, category: categoryToFetch.rawValue)
            }
            synchronizePersistedState(to: &newsArticles)
            categoryArticleCounts[categoryToFetch] = newsArticles.count
            
            if categoryToFetch == .general || category == nil {
                featuredArticles = Array(newsArticles.prefix(5))
                homeArticles = newsArticles
                recommendedArticles = personalizedArticles(from: newsArticles)
                NotificationService.shared.processBreakingNewsIfNeeded(article: newsArticles.first)
            }
            articles = newsArticles
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    /// Load berita untuk kategori tertentu tanpa menimpa homeArticles
    func loadCategoryNews(category: NewsCategory) async {
        isLoading = true
        errorMessage = nil
        selectedCategory = category
        
        do {
            let articleDTOs = try await apiService.fetchNews(category: category, country: newsLanguage == "en" ? "us" : "id")
            var fetchedArticles = articleDTOs.map { dto in
                NewsArticle.from(dto: dto, category: category.rawValue)
            }
            synchronizePersistedState(to: &fetchedArticles)
            categoryArticleCounts[category] = fetchedArticles.count
            articles = fetchedArticles
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Search
    
    func searchNews() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        addRecentSearch(searchText)
        
        do {
            let articleDTOs = try await apiService.searchNews(query: searchText, country: newsLanguage == "en" ? "us" : "id")
            var fetchedResults = articleDTOs.map { NewsArticle.from(dto: $0) }
            synchronizePersistedState(to: &fetchedResults)
            searchResults = fetchedResults
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isSearching = false
    }
    
    func debouncedSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await searchNews()
        }
    }
    
    // MARK: - Recent Searches
    
    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentSearches.removeAll { $0.lowercased() == trimmed.lowercased() }
        recentSearches.insert(trimmed, at: 0)
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        saveRecentSearches()
    }
    
    func removeRecentSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    // MARK: - Related Articles
    
    func relatedArticles(for article: NewsArticle, limit: Int = 5) -> [NewsArticle] {
        // Gabungkan homeArticles dan articles untuk pool yang lebih besar
        let pool = Array(Set(homeArticles + articles))
        
        return pool
            .filter { $0.title != article.title }
            .filter { $0.category == article.category }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Bookmark
    
    func toggleBookmark(_ article: NewsArticle) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let newValue = !article.isBookmarked
        article.isBookmarked = newValue

        if let persistentArticle = upsertArticle(article) {
            persistentArticle.isBookmarked = newValue
            if !persistentArticle.isBookmarked && !persistentArticle.isRead {
                modelContext?.delete(persistentArticle)
            }
            try? modelContext?.save()
            recommendedArticles = personalizedArticles(from: homeArticles)
        }
    }
    
    func markAsRead(_ article: NewsArticle) {
        article.isRead = true

        if let persistentArticle = upsertArticle(article) {
            persistentArticle.isRead = true
            try? modelContext?.save()
            recommendedArticles = personalizedArticles(from: homeArticles)
        }
    }
    
    func loadBookmarkedArticles() -> [NewsArticle] {
        guard let modelContext else { return [] }
        let descriptor = FetchDescriptor<NewsArticle>(
            predicate: #Predicate { $0.isBookmarked == true },
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func deleteAllBookmarks() {
        let generator = UINotificationFeedbackGenerator()
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<NewsArticle>(
            predicate: #Predicate { $0.isBookmarked == true }
        )
        if let bookmarked = try? modelContext.fetch(descriptor) {
            for article in bookmarked {
                article.isBookmarked = false
                // Hapus dari DB jika juga tidak isRead
                if !article.isRead {
                    modelContext.delete(article)
                }
            }
            try? modelContext.save()
            generator.notificationOccurred(.success)
            recommendedArticles = personalizedArticles(from: homeArticles)
        }
    }
    
    func deleteAllReadHistory() {
        let generator = UINotificationFeedbackGenerator()
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<NewsArticle>(
            predicate: #Predicate { $0.isRead == true }
        )
        if let readArticles = try? modelContext.fetch(descriptor) {
            for article in readArticles {
                article.isRead = false
                // Hapus dari DB jika juga tidak bookmark
                if !article.isBookmarked {
                    modelContext.delete(article)
                }
            }
            try? modelContext.save()
            generator.notificationOccurred(.success)
            recommendedArticles = personalizedArticles(from: homeArticles)
        }
    }
    
    func loadReadArticles() -> [NewsArticle] {
        guard let modelContext else { return [] }
        let descriptor = FetchDescriptor<NewsArticle>(
            predicate: #Predicate { $0.isRead == true },
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func refresh() async {
        if selectedCategory == .general {
            await loadNews(category: .general)
        } else {
            await loadCategoryNews(category: selectedCategory)
        }
    }

    func cachedArticleCount(for category: NewsCategory) -> Int? {
        categoryArticleCounts[category]
    }

    func currentLanguageLabel() -> String {
        AppLanguage.current == .english ? "English" : "Bahasa Indonesia"
    }

    func article(withID articleID: String) -> NewsArticle? {
        let inMemoryArticles = homeArticles + articles + searchResults
        if let article = inMemoryArticles.first(where: { $0.id == articleID }) {
            return article
        }

        guard let modelContext else { return nil }
        let descriptor = FetchDescriptor<NewsArticle>(
            predicate: #Predicate { article in
                article.id == articleID
            }
        )

        return try? modelContext.fetch(descriptor).first
    }

    func personalizedArticles(from articles: [NewsArticle]) -> [NewsArticle] {
        let scores = categoryPreferenceScores()
        dominantCategory = scores.max(by: { $0.value < $1.value })?.key

        return articles.sorted { lhs, rhs in
            let leftScore = scores[NewsCategory(rawValue: lhs.category) ?? .general] ?? 0
            let rightScore = scores[NewsCategory(rawValue: rhs.category) ?? .general] ?? 0

            if leftScore == rightScore {
                return lhs.publishedAt > rhs.publishedAt
            }

            return leftScore > rightScore
        }
    }

    func dominantCategoryName() -> String {
        dominantCategory?.displayName ?? L10n.tr("profile.preferenceFallback", fallback: "Belum cukup data baca")
    }

    private func categoryPreferenceScores() -> [NewsCategory: Int] {
        guard let modelContext else { return [:] }
        let descriptor = FetchDescriptor<NewsArticle>()
        guard let persistedArticles = try? modelContext.fetch(descriptor) else { return [:] }

        var scores: [NewsCategory: Int] = [:]
        for article in persistedArticles {
            guard let category = NewsCategory(rawValue: article.category) else { continue }
            let readScore = article.isRead ? 2 : 0
            let bookmarkScore = article.isBookmarked ? 3 : 0
            scores[category, default: 0] += readScore + bookmarkScore
        }

        return scores
    }

    private func synchronizePersistedState(to articles: inout [NewsArticle]) {
        guard let modelContext else { return }
        let articleIDs = Set(articles.map(\.id))
        let descriptor = FetchDescriptor<NewsArticle>()

        guard let persistedArticles = try? modelContext.fetch(descriptor) else { return }

        let persistedByID = Dictionary(uniqueKeysWithValues: persistedArticles.map { ($0.id, $0) })
        for article in articles where articleIDs.contains(article.id) {
            if let persisted = persistedByID[article.id] {
                article.isBookmarked = persisted.isBookmarked
                article.isRead = persisted.isRead
            }
        }
    }

    private func upsertArticle(_ article: NewsArticle) -> NewsArticle? {
        guard let modelContext else { return nil }

        let articleID = article.id
        let descriptor = FetchDescriptor<NewsArticle>(
            predicate: #Predicate { storedArticle in
                storedArticle.id == articleID
            }
        )

        if let existingArticle = try? modelContext.fetch(descriptor).first {
            existingArticle.title = article.title
            existingArticle.articleDescription = article.articleDescription
            existingArticle.content = article.content
            existingArticle.author = article.author
            existingArticle.sourceName = article.sourceName
            existingArticle.url = article.url
            existingArticle.imageURL = article.imageURL
            existingArticle.publishedAt = article.publishedAt
            existingArticle.category = article.category
            return existingArticle
        }

        modelContext.insert(article)
        return article
    }
}
