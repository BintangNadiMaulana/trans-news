//
//  SearchView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI

struct SearchView: View {
    @Bindable var viewModel: NewsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search field
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField(L10n.tr("search.placeholder", fallback: "Cari berita..."), text: $viewModel.searchText)
                        .focused($isSearchFieldFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            Task { await viewModel.searchNews() }
                        }
                        .onChange(of: viewModel.searchText) {
                            viewModel.debouncedSearch()
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                            viewModel.searchResults = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(14)
                .padding()
                
                // Content
                if viewModel.isSearching {
                    Spacer()
                    ProgressView(L10n.tr("search.loading", fallback: "Mencari berita..."))
                    Spacer()
                } else if viewModel.searchText.isEmpty {
                    searchSuggestionsView
                } else if viewModel.searchResults.isEmpty {
                    emptySearchResults
                } else {
                    searchResultsView
                }
            }
            .navigationTitle(L10n.tr("search.title", fallback: "Cari Berita"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.tr("search.close", fallback: "Tutup")) { dismiss() }
                }
            }
            .onAppear {
                isSearchFieldFocused = true
            }
            .onDisappear {
                // Bersihkan search saat dismiss agar tidak menimpa data
                viewModel.searchText = ""
                viewModel.searchResults = []
            }
        }
    }
    
    // MARK: - Search Suggestions
    private var searchSuggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Recent Searches
                if !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(L10n.tr("search.recent", fallback: "Pencarian Terakhir"))
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(L10n.tr("search.clear", fallback: "Hapus")) {
                                withAnimation { viewModel.clearRecentSearches() }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ForEach(viewModel.recentSearches, id: \.self) { query in
                            HStack(spacing: 12) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text(query)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        viewModel.removeRecentSearch(query)
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.searchText = query
                                Task { await viewModel.searchNews() }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                        }
                    }
                }
                
                // Popular Topics
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.tr("search.popular", fallback: "Topik Populer"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(popularTopics, id: \.self) { topic in
                                Button {
                                    viewModel.searchText = topic
                                    Task { await viewModel.searchNews() }
                                } label: {
                                    Text(topic)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.transNewsOrange.opacity(0.12))
                                        .foregroundStyle(Color.transNewsOrange)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Browse by Category
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.tr("search.browse", fallback: "Jelajahi Kategori"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(NewsCategory.allCases) { category in
                            Button {
                                viewModel.searchText = category.displayName
                                Task { await viewModel.searchNews() }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: category.icon)
                                        .font(.caption)
                                    Text(category.displayName)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .foregroundStyle(.primary)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 12)
        }
    }
    
    // MARK: - Empty Results
    private var emptySearchResults: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.5))
            
            Text(L10n.tr("search.emptyTitle", fallback: "Tidak Ada Hasil"))
                .font(.title3)
                .fontWeight(.bold)
            
            Text(L10n.tr("search.emptySubtitle", fallback: "Coba kata kunci lain untuk menemukan berita yang Anda cari"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Search Results
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                Text(searchResultsCountText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(viewModel.searchResults) { article in
                    NavigationLink(destination: NewsDetailView(article: article, viewModel: viewModel)) {
                        NewsListCard(article: article)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }

    private var searchResultsCountText: String {
        "\(viewModel.searchResults.count) \(L10n.tr("search.results", fallback: "hasil ditemukan"))"
    }

    private var popularTopics: [String] {
        if AppLanguage.current == .english {
            return ["Economy", "Politics", "Technology", "Sports", "Health", "Startups", "World Cup", "AI"]
        }
        return ["Ekonomi", "Politik", "Teknologi", "Olahraga", "Kesehatan", "Startup", "Piala Dunia", "AI"]
    }
}

#Preview {
    SearchView(viewModel: NewsViewModel())
}
