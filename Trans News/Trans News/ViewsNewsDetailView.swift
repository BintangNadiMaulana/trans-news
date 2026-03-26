//
//  NewsDetailView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI

struct NewsDetailView: View {
    let article: NewsArticle
    var viewModel: NewsViewModel
    @AppStorage("fontSize") private var fontSize: Double = 16
    @AppStorage("readingMode") private var readingMode = "default"
    @State private var scrollProgress: CGFloat = 0
    @State private var speechService = SpeechService.shared
    
    private var readingModeBackground: Color {
        switch readingMode {
        case "sepia": return Color(red: 0.96, green: 0.93, blue: 0.87)
        case "dark": return Color(red: 0.12, green: 0.12, blue: 0.14)
        default: return Color(.systemBackground)
        }
    }
    
    private var readingModeTextColor: Color {
        switch readingMode {
        case "sepia": return Color(red: 0.3, green: 0.25, blue: 0.15)
        case "dark": return Color(red: 0.85, green: 0.85, blue: 0.85)
        default: return .primary
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            readingModeBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero image with parallax
                    if let imageURL = article.imageURL {
                        GeometryReader { geo in
                            let offset = geo.frame(in: .global).minY
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color.transNewsSoftGradient)
                                        .overlay { ProgressView() }
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    Rectangle()
                                        .fill(Color.transNewsSoftGradient)
                                        .overlay {
                                            Image(systemName: "photo")
                                                .font(.system(size: 50))
                                                .foregroundStyle(.white.opacity(0.5))
                                        }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: geo.size.width, height: 320 + max(0, offset))
                            .offset(y: -max(0, offset))
                            .clipped()
                        }
                        .frame(height: 320)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        // Category badge + read time + actions
                        HStack {
                            HStack(spacing: 8) {
                                Text(article.localizedCategory)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.transNewsOrange.opacity(0.15))
                                    .foregroundStyle(Color.transNewsOrange)
                                    .cornerRadius(20)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                    Text(Date.estimatedReadTime(for: fullContent))
                                }
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 14) {
                                Button {
                                    viewModel.toggleBookmark(article)
                                } label: {
                                    Image(systemName: article.isBookmarked ? "bookmark.fill" : "bookmark")
                                        .font(.title3)
                                        .foregroundStyle(article.isBookmarked ? Color.transNewsOrange : readingModeTextColor)
                                }
                                
                                if let url = URL(string: article.url) {
                                    ShareLink(item: "\(article.title)\n\(url.absoluteString)") {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.title3)
                                            .foregroundStyle(readingModeTextColor)
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        // Title
                        Text(article.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(readingModeTextColor)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Metadata
                        HStack(spacing: 6) {
                            Text(article.sourceName)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.transNewsOrange)
                            
                            Text("•")
                                .foregroundStyle(.secondary)
                            
                            if let author = article.author {
                                Text(author)
                                    .foregroundStyle(.secondary)
                                Text("•")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text(article.publishedAt.formattedIndonesian())
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Description
                        if let description = article.articleDescription {
                            Text(description)
                                .font(.system(size: fontSize))
                                .fontWeight(.medium)
                                .foregroundStyle(readingModeTextColor)
                                .lineSpacing(4)
                                .padding(.bottom, 4)
                        }
                        
                        // Content
                        if let content = article.content {
                            Text(content)
                                .font(.system(size: fontSize))
                                .foregroundStyle(readingModeTextColor)
                                .lineSpacing(6)
                        }

                        controlPanel
                        
                        // Read full article button
                        if let url = URL(string: article.url) {
                            Link(destination: url) {
                                HStack {
                                    Text(L10n.tr("detail.readFull", fallback: "Baca Artikel Lengkap"))
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.title3)
                                }
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.transNewsGradient)
                                .cornerRadius(14)
                            }
                            .padding(.top, 8)
                        }
                        
                        // Related Articles
                        relatedArticlesSection
                    }
                    .padding()
                    .background(
                        GeometryReader { contentGeo in
                            Color.clear
                                .onAppear {
                                    updateProgress(contentGeo: contentGeo)
                                }
                                .onChange(of: contentGeo.frame(in: .global).minY) { _, _ in
                                    updateProgress(contentGeo: contentGeo)
                                }
                        }
                    )
                }
            }
            
            // Reading progress bar at top
            VStack(spacing: 0) {
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.transNewsGradient)
                        .frame(width: geo.size.width * scrollProgress, height: 3)
                        .animation(.linear(duration: 0.1), value: scrollProgress)
                }
                .frame(height: 3)
                Spacer()
            }
            .allowsHitTesting(false)
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            viewModel.markAsRead(article)
        }
    }
    
    // MARK: - Full content for read time calc
    private var fullContent: String {
        [article.articleDescription, article.content].compactMap { $0 }.joined(separator: " ")
    }

    private var speechText: String {
        [article.title, article.articleDescription, article.content].compactMap { $0 }.joined(separator: ". ")
    }

    private var quickShareText: String {
        "\(L10n.tr("detail.shareMessage", fallback: "Baca berita ini di Trans News"))\n\n\(article.title)\n\(article.url)"
    }

    private var controlPanel: some View {
        HStack(spacing: 12) {
            Button {
                if speechService.isSpeaking, speechService.currentArticleID == article.id {
                    speechService.stop()
                } else {
                    speechService.speak(text: speechText, articleID: article.id)
                }
            } label: {
                Label(
                    speechService.isSpeaking && speechService.currentArticleID == article.id
                        ? L10n.tr("detail.stopListening", fallback: "Berhenti")
                        : L10n.tr("detail.listen", fallback: "Dengarkan"),
                    systemImage: speechService.isSpeaking && speechService.currentArticleID == article.id ? "stop.circle.fill" : "waveform.circle.fill"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(readingModeTextColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(readingModeTextColor.opacity(readingMode == "dark" ? 0.12 : 0.08))
                .clipShape(Capsule())
            }

            if URL(string: article.url) != nil {
                ShareLink(item: quickShareText) {
                    Label(L10n.tr("detail.share", fallback: "Bagikan"), systemImage: "paperplane.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(readingModeTextColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(readingModeTextColor.opacity(readingMode == "dark" ? 0.12 : 0.08))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - Scroll Progress
    private func updateProgress(contentGeo: GeometryProxy) {
        let contentHeight = contentGeo.size.height
        let frameMinY = contentGeo.frame(in: .global).minY
        let visibleHeight = contentGeo.frame(in: .global).height
        let maxScroll = contentHeight - visibleHeight + 320
        guard maxScroll > 0 else {
            scrollProgress = 1
            return
        }
        let scrolled = -frameMinY + 320
        scrollProgress = min(max(scrolled / maxScroll, 0), 1)
    }
    
    // MARK: - Related Articles
    private var relatedArticlesSection: some View {
        let related = viewModel.relatedArticles(for: article)
        
        return Group {
            if !related.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    Text(L10n.tr("detail.related", fallback: "Berita Terkait"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(readingModeTextColor)
                    
                    ForEach(related) { relatedArticle in
                        NavigationLink(destination: NewsDetailView(article: relatedArticle, viewModel: viewModel)) {
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: relatedArticle.imageURL ?? "")) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    default:
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.transNewsSoftGradient)
                                    }
                                }
                                .frame(width: 70, height: 70)
                                .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(relatedArticle.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(readingModeTextColor)
                                        .lineLimit(2)
                                    
                                    HStack(spacing: 4) {
                                        Text(relatedArticle.sourceName)
                                            .foregroundStyle(Color.transNewsOrange)
                                        Text("•")
                                        Text(relatedArticle.publishedAt.timeAgoDisplay())
                                    }
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                }
                                
                                Spacer(minLength: 0)
                            }
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewsDetailView(
            article: NewsArticle(
                title: "Perekonomian Indonesia Tumbuh 5.2% di Kuartal Pertama 2026",
                articleDescription: "Badan Pusat Statistik (BPS) melaporkan pertumbuhan ekonomi Indonesia mencapai 5.2% pada kuartal pertama 2026.",
                content: "Pertumbuhan ekonomi Indonesia di kuartal pertama 2026 mencapai 5.2 persen...",
                author: "Redaksi Trans News",
                sourceName: "Trans News",
                url: "https://example.com",
                imageURL: "https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=800",
                publishedAt: Date(),
                category: "business"
            ),
            viewModel: NewsViewModel()
        )
    }
}
