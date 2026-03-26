//
//  ReadHistoryView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI
import SwiftData

struct ReadHistoryView: View {
    @Query(
        filter: #Predicate<NewsArticle> { $0.isRead == true },
        sort: \NewsArticle.publishedAt,
        order: .reverse
    ) private var readArticles: [NewsArticle]
    
    var viewModel: NewsViewModel
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        Group {
            if readArticles.isEmpty {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.transNewsOrange.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.transNewsOrange.opacity(0.6))
                    }
                    
                    VStack(spacing: 8) {
                        Text("Belum Ada Riwayat")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Berita yang sudah Anda baca akan muncul di sini")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    // Stats header
                    HStack {
                        Label("\(readArticles.count) berita dibaca", systemImage: "book.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(readArticles) { article in
                            NavigationLink(destination: NewsDetailView(article: article, viewModel: viewModel)) {
                                ReadHistoryCard(article: article)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle(L10n.tr("history.title", fallback: "Riwayat Baca"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !readArticles.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .alert("Hapus Riwayat", isPresented: $showDeleteConfirmation) {
            Button("Batal", role: .cancel) {}
            Button("Hapus Semua", role: .destructive) {
                viewModel.deleteAllReadHistory()
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        } message: {
            Text("Semua riwayat baca akan dihapus. Ini tidak akan menghapus bookmark Anda.")
        }
    }
}

// MARK: - Read History Card
struct ReadHistoryCard: View {
    let article: NewsArticle
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            AsyncImage(url: URL(string: article.imageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "newspaper")
                            .foregroundStyle(.gray.opacity(0.5))
                    )
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 6) {
                    Text(article.sourceName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(article.publishedAt.timeAgoDisplay())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer(minLength: 0)
            
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.transNewsOrange.opacity(0.5))
                .font(.caption)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        ReadHistoryView(viewModel: NewsViewModel())
            .modelContainer(for: NewsArticle.self, inMemory: true)
    }
}
