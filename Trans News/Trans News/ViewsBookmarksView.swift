//
//  BookmarksView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI
import SwiftData

struct BookmarksView: View {
    @Query(
        filter: #Predicate<NewsArticle> { $0.isBookmarked == true },
        sort: \NewsArticle.publishedAt,
        order: .reverse
    ) private var bookmarkedArticles: [NewsArticle]
    
    var viewModel: NewsViewModel
    @State private var selectedFilter: BookmarkFilter = .all
    @State private var showDeleteAllConfirmation = false
    
    enum BookmarkFilter: String, CaseIterable {
        case all = "Semua"
        case today = "Hari Ini"
        case week = "Minggu Ini"
        case month = "Bulan Ini"
    }
    
    var filteredArticles: [NewsArticle] {
        let calendar = Calendar.current
        let now = Date()
        switch selectedFilter {
        case .all: return bookmarkedArticles
        case .today: return bookmarkedArticles.filter { calendar.isDateInToday($0.publishedAt) }
        case .week: return bookmarkedArticles.filter { calendar.isDate($0.publishedAt, equalTo: now, toGranularity: .weekOfYear) }
        case .month: return bookmarkedArticles.filter { calendar.isDate($0.publishedAt, equalTo: now, toGranularity: .month) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !bookmarkedArticles.isEmpty {
                    filterView
                        .padding(.top, 8)
                }
                
                if bookmarkedArticles.isEmpty {
                    emptyStateView
                        .frame(maxHeight: .infinity)
                } else if filteredArticles.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray.opacity(0.5))
                        Text("Tidak ada berita untuk filter ini")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredArticles) { article in
                            NavigationLink(destination: NewsDetailView(article: article, viewModel: viewModel)) {
                                CompactBookmarkCard(article: article)
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        viewModel.toggleBookmark(article)
                                    }
                                } label: {
                                    Label("Hapus", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                if let url = URL(string: article.url) {
                                    ShareLink(item: url) {
                                        Label("Bagikan", systemImage: "square.and.arrow.up")
                                    }
                                    .tint(.transNewsBlue)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .padding(.bottom, 80)
                }
            }
            .animation(.easeInOut, value: selectedFilter)
            .navigationTitle(L10n.tr("bookmark.title", fallback: "Tersimpan"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !bookmarkedArticles.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showDeleteAllConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(Color.transNewsOrange)
                        }
                    }
                }
            }
            .alert("Hapus Semua Bookmark", isPresented: $showDeleteAllConfirmation) {
                Button("Batal", role: .cancel) {}
                Button("Hapus Semua", role: .destructive) {
                    viewModel.deleteAllBookmarks()
                }
            } message: {
                Text("Semua berita tersimpan akan dihapus. Tindakan ini tidak dapat dibatalkan.")
            }
        }
    }
    
    // MARK: - Filter
    private var filterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(BookmarkFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation { selectedFilter = filter }
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter ? Color.transNewsOrange : Color(.systemGray6))
                            )
                            .foregroundStyle(selectedFilter == filter ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.transNewsOrange.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bookmark.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.transNewsOrange.opacity(0.5))
            }
            
            VStack(spacing: 8) {
                Text("Belum Ada Berita Tersimpan")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Simpan berita favorit Anda dengan\nmengetuk ikon bookmark atau swipe ke kiri")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Compact Bookmark Card
struct CompactBookmarkCard: View {
    let article: NewsArticle
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: article.imageURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.transNewsSoftGradient)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(article.localizedCategory)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.transNewsOrange)
                    
                    Spacer()
                    
                    Image(systemName: "bookmark.fill")
                        .font(.caption)
                        .foregroundStyle(Color.transNewsOrange)
                }
                
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Text(article.sourceName)
                    Text("•")
                    Text(article.publishedAt.timeAgoDisplay())
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    BookmarksView(viewModel: NewsViewModel())
        .modelContainer(for: NewsArticle.self, inMemory: true)
}
