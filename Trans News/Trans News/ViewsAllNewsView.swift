//
//  AllNewsView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI

struct AllNewsView: View {
    var viewModel: NewsViewModel
    @State private var sortOrder: AllNewsSortOrder = .newest
    @State private var filterCategory: NewsCategory? = nil
    
    enum AllNewsSortOrder: CaseIterable {
        case newest
        case oldest

        var displayName: String {
            switch self {
            case .newest:
                return L10n.tr("allNews.sortNewest", fallback: "Terbaru")
            case .oldest:
                return L10n.tr("allNews.sortOldest", fallback: "Terlama")
            }
        }
    }
    
    var displayedArticles: [NewsArticle] {
        var result = viewModel.selectedCategory == .general ? viewModel.homeArticles : viewModel.articles
        
        if let cat = filterCategory {
            result = result.filter { $0.category == cat.rawValue }
        }
        
        switch sortOrder {
        case .newest:
            result.sort { $0.publishedAt > $1.publishedAt }
        case .oldest:
            result.sort { $0.publishedAt < $1.publishedAt }
        }
        
        return result
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Filter & Sort Bar
                HStack {
                    // Category filter
                    Menu {
                        Button(L10n.tr("category.all", fallback: "Semua Kategori")) {
                            withAnimation { filterCategory = nil }
                        }
                        ForEach(NewsCategory.allCases) { cat in
                            Button {
                                withAnimation { filterCategory = cat }
                            } label: {
                                HStack {
                                    Text(cat.displayName)
                                    if filterCategory == cat {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease")
                            Text(filterCategory?.displayName ?? L10n.tr("allNews.allCategories", fallback: "Semua"))
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    Text("\(displayedArticles.count) \(L10n.tr("allNews.count", fallback: "berita"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Sort
                    Menu {
                        ForEach(AllNewsSortOrder.allCases, id: \.self) { order in
                            Button {
                                    withAnimation { sortOrder = order }
                                } label: {
                                HStack {
                                    Text(order.displayName)
                                    if sortOrder == order {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(sortOrder.displayName)
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.transNewsOrange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.transNewsOrange.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
                .padding()
                
                // Articles
                LazyVStack(spacing: 12) {
                    ForEach(displayedArticles) { article in
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
        .navigationTitle(L10n.tr("allNews.title", fallback: "Semua Berita"))
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview {
    NavigationStack {
        AllNewsView(viewModel: NewsViewModel())
    }
}
