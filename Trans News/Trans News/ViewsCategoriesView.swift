//
//  CategoriesView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    var viewModel: NewsViewModel
    @State private var animateCards = false
    
    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
            // Header
            headerSection
                    
                    // Trending Categories
                    trendingSection
                    
                    // All Categories Grid
                    allCategoriesSection
                }
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.tr("category.title", fallback: "Kategori"))
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text(L10n.tr("category.subtitle", fallback: "Jelajahi berita berdasarkan topik favorit Anda"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // MARK: - Trending Section
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text(L10n.tr("category.trending", fallback: "Trending"))
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(trendingCategories, id: \.self) { category in
                        NavigationLink(destination: CategoryNewsView(category: category, viewModel: viewModel)) {
                            TrendingCategoryPill(category: category, articleCount: articleCount(for: category))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - All Categories Grid
    private var allCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.tr("category.all", fallback: "Semua Kategori"))
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Array(NewsCategory.allCases.enumerated()), id: \.element) { index, category in
                    NavigationLink(destination: CategoryNewsView(category: category, viewModel: viewModel)) {
                        CategoryCard(
                            category: category,
                            articleCount: articleCount(for: category),
                            index: index
                        )
                    }
                    .buttonStyle(CategoryButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helpers
    
    private var trendingCategories: [NewsCategory] {
        [.technology, .sports, .entertainment]
    }
    
    private func articleCount(for category: NewsCategory) -> Int {
        viewModel.cachedArticleCount(for: category) ?? 0
    }
}

// MARK: - Category Button Style (press animation)
struct CategoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Trending Category Pill
struct TrendingCategoryPill: View {
    let category: NewsCategory
    let articleCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(categoryGradient.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(articleCount > 0 ? "\(articleCount) berita" : "Berita live")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: categoryColor.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(categoryColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var categoryColor: Color {
        category.themeColor
    }
    
    private var categoryGradient: LinearGradient {
        LinearGradient(colors: [categoryColor, categoryColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Category Card (redesigned)
struct CategoryCard: View {
    let category: NewsCategory
    let articleCount: Int
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top gradient area with icon
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [category.themeColor, category.themeColor.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Background pattern
                Image(systemName: category.icon)
                    .font(.system(size: 70))
                    .foregroundStyle(.white.opacity(0.12))
                    .offset(x: 15, y: -10)
                
                // Article count badge
                Text(articleCount > 0 ? "\(articleCount)" : "Live")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(category.themeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.white)
                    )
                    .padding(10)
            }
            .frame(height: 90)
            
            // Bottom info area
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: category.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(category.themeColor)
                    
                    Text(category.displayName)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                Text(articleCount > 0 ? "\(articleCount) berita tersedia" : "Tap untuk memuat berita terbaru")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: category.themeColor.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Category News View (redesigned)
struct CategoryNewsView: View {
    let category: NewsCategory
    var viewModel: NewsViewModel
    @State private var sortOrder: SortOrder = .newest
    
    enum SortOrder: String, CaseIterable {
        case newest = "Terbaru"
        case oldest = "Terlama"
    }
    
    var sortedArticles: [NewsArticle] {
        switch sortOrder {
        case .newest:
            return viewModel.articles.sorted { $0.publishedAt > $1.publishedAt }
        case .oldest:
            return viewModel.articles.sorted { $0.publishedAt < $1.publishedAt }
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Category Header
                    categoryHeader
                    
                    // Sorting & Count Bar
                    sortingBar
                    
                    // Articles List
                    LazyVStack(spacing: 12) {
                        ForEach(sortedArticles) { article in
                            NavigationLink(destination: NewsDetailView(article: article, viewModel: viewModel)) {
                                NewsListCard(article: article)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }
            }
            
            // Loading overlay
            if viewModel.isLoading && viewModel.articles.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Memuat berita \(category.displayName)...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.9))
            }
            
            // Error state
            if !viewModel.isLoading && viewModel.articles.isEmpty && viewModel.errorMessage != nil {
                ErrorRetryView {
                    Task { await viewModel.loadCategoryNews(category: category) }
                }
            }
        }
        .navigationTitle(category.displayName)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadCategoryNews(category: category)
        }
        .refreshable {
            await viewModel.loadCategoryNews(category: category)
        }
    }
    
    // MARK: - Category Header
    private var categoryHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [category.themeColor, category.themeColor.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Background icon
            Image(systemName: category.icon)
                .font(.system(size: 120))
                .foregroundStyle(.white.opacity(0.1))
                .offset(x: 200, y: -20)
            
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
                
                Text(category.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text(category.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(20)
        }
        .frame(height: 180)
    }
    
    // MARK: - Sorting Bar
    private var sortingBar: some View {
        HStack {
            Text("\(sortedArticles.count) berita")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Menu {
                ForEach(SortOrder.allCases, id: \.self) { order in
                    Button {
                        withAnimation { sortOrder = order }
                    } label: {
                        HStack {
                            Text(order.rawValue)
                            if sortOrder == order {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(sortOrder.rawValue)
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.transNewsOrange)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.transNewsOrange.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - NewsCategory Theme Extension
extension NewsCategory {
    var themeColor: Color {
        switch self {
        case .general: return .blue
        case .business: return Color(red: 0.2, green: 0.7, blue: 0.3)
        case .technology: return .purple
        case .entertainment: return .pink
        case .health: return Color(red: 0.9, green: 0.3, blue: 0.3)
        case .science: return .cyan
        case .sports: return .transNewsOrange
        }
    }
    
    var subtitle: String {
        switch self {
        case .general: return "Berita terkini dari seluruh Indonesia"
        case .business: return "Ekonomi, pasar saham, dan dunia bisnis"
        case .technology: return "Inovasi, gadget, dan dunia digital"
        case .entertainment: return "Film, musik, seni, dan hiburan"
        case .health: return "Kesehatan, medis, dan gaya hidup"
        case .science: return "Penemuan, riset, dan eksplorasi"
        case .sports: return "Sepakbola, badminton, dan olahraga lainnya"
        }
    }
}

#Preview {
    CategoriesView(viewModel: NewsViewModel())
        .modelContainer(for: NewsArticle.self, inMemory: true)
}
