//
//  HomeView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Bindable var viewModel: NewsViewModel
    @AppStorage("userName") private var userName = "Bintang"
    @State private var showSearch = false
    @State private var showNotifications = false
    @State private var selectedQuickCategory: NewsCategory = .general
    @State private var showAllCategories = false
    @State private var notificationService = NotificationService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.transNewsPageBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerView
                        
                        // Breaking News Banner
                        if let breakingNews = viewModel.featuredArticles.first {
                            breakingNewsBanner(article: breakingNews)
                        }
                        
                        // Quick Category Chips
                        quickCategoryChips
                        
                        // Featured Carousel (hanya tampil untuk kategori Umum)
                        if selectedQuickCategory == .general && viewModel.featuredArticles.count > 1 {
                            featuredNewsSection
                        }

                        if selectedQuickCategory == .general && !viewModel.recommendedArticles.isEmpty {
                            recommendedSection
                        }
                        
                        // Latest News (berdasarkan kategori terpilih)
                        latestNewsSection
                    }
                    .padding(.bottom, 100)
                }
                .refreshable {
                    await viewModel.refresh()
                }
                
                // Loading overlay with skeleton
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    skeletonLoadingView
                }
                
                // Error state
                if !viewModel.isLoading && viewModel.articles.isEmpty && viewModel.errorMessage != nil {
                    ErrorRetryView {
                        Task { await viewModel.loadNews() }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.transNewsOrange)
                            .frame(width: 36, height: 36)
                            .background(Color.transNewsOrange.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showNotifications) {
                NotificationsView()
            }
            .task {
                if viewModel.articles.isEmpty {
                    await viewModel.loadNews()
                }
                await notificationService.refreshNotificationBadgeCount()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date.greeting + " \u{1F44B}")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Trans News")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.transNewsGradient)
            }
            
            Spacer()
            
            Button {
                showNotifications = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.title3)
                        .foregroundStyle(Color.transNewsOrange)
                        .frame(width: 42, height: 42)
                        .background(Color.transNewsOrange.opacity(0.1))
                        .clipShape(Circle())
                    
                    if notificationService.notificationBadgeCount > 0 {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 2, y: -1)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Breaking News Banner
    private func breakingNewsBanner(article: NewsArticle) -> some View {
        NavigationLink(destination: NewsDetailView(article: article, viewModel: viewModel)) {
            HStack(spacing: 12) {
                Image(systemName: "bolt.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color.red)
                    .clipShape(Circle())
                
                Text(L10n.tr("home.breaking", fallback: "BREAKING"))
                    .font(.caption2)
                    .fontWeight(.black)
                    .foregroundStyle(.red)
                
                Text(article.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.transNewsCardBackground)
                    .shadow(color: .red.opacity(0.1), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Quick Category Chips
    private var quickCategoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(NewsCategory.allCases) { category in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedQuickCategory = category
                        }
                        Task {
                            if category == .general {
                                await viewModel.loadNews()
                            } else {
                                await viewModel.loadCategoryNews(category: category)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.caption2)
                            Text(category.displayName)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedQuickCategory == category ? Color.transNewsOrange : Color(.systemBackground))
                        )
                        .foregroundStyle(selectedQuickCategory == category ? .white : .primary)
                        .overlay(
                            Capsule()
                                .stroke(selectedQuickCategory == category ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Featured News Section
    private var featuredNewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.tr("home.featured", fallback: "Berita Utama"))
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()
            }
            .padding(.horizontal)
            
            TabView {
                ForEach(viewModel.featuredArticles) { article in
                    NavigationLink(destination: NewsDetailView(article: article, viewModel: viewModel)) {
                        FeaturedNewsCard(article: article)
                    }
                }
            }
            .frame(height: 260)
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.tr("home.recommended", fallback: "Untuk Anda"))
                    .font(.title3)
                    .fontWeight(.bold)

                Text(L10n.tr("home.recommendedSubtitle", fallback: "Diurutkan berdasarkan kategori yang paling sering Anda baca"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recommendedArticles.prefix(6)) { article in
                        NavigationLink(destination: NewsDetailView(article: article, viewModel: viewModel)) {
                            RecommendedNewsCard(article: article)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Latest News Section
    private var latestNewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedQuickCategory == .general ? L10n.tr("home.latest", fallback: "Berita Terbaru") : selectedQuickCategory.displayName)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                if selectedQuickCategory == .general {
                    NavigationLink(L10n.tr("home.seeAll", fallback: "Lihat Semua")) {
                        AllNewsView(viewModel: viewModel)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.transNewsOrange)
                }
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.articles.prefix(10).enumerated()), id: \.element.id) { index, article in
                    NavigationLink(destination: NewsDetailView(article: article, viewModel: viewModel)) {
                        NewsListCard(article: article)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Skeleton Loading
    private var skeletonLoadingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SkeletonView(width: 120, height: 20)
                    SkeletonView(width: 200, height: 28)
                }
                .padding(.horizontal)
                .padding(.top, 80)
                
                SkeletonView(height: 240)
                    .cornerRadius(20)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { _ in
                        HStack(spacing: 12) {
                            SkeletonView(width: 90, height: 90)
                                .cornerRadius(12)
                            VStack(alignment: .leading, spacing: 8) {
                                SkeletonView(height: 16)
                                SkeletonView(width: 200, height: 12)
                                SkeletonView(width: 120, height: 10)
                            }
                        }
                        .padding(12)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.transNewsPageBackground)
    }
}

// MARK: - Skeleton View
struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 20
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.15))
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 300 : -300)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Error Retry View
struct ErrorRetryView: View {
    var message: String = "Gagal memuat berita"
    var onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "wifi.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(.gray.opacity(0.5))
            }
            
            VStack(spacing: 8) {
                Text(message)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(AppLanguage.current == .english ? "Check your internet connection and try again" : "Periksa koneksi internet Anda dan coba lagi")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                onRetry()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text(AppLanguage.current == .english ? "Try Again" : "Coba Lagi")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Color.transNewsGradient)
                .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.transNewsPageBackground)
    }
}

// MARK: - Featured News Card
struct FeaturedNewsCard: View {
    let article: NewsArticle
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: article.imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(LinearGradient(colors: [Color.transNewsOrange.opacity(0.3), Color.transNewsRed.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(LinearGradient(colors: [Color.transNewsOrange.opacity(0.3), Color.transNewsRed.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 260)
            .clipped()
            
            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(article.localizedCategory)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.transNewsOrange)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    
                    Text(Date.estimatedReadTime(for: article.content))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Text(article.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    Text(article.sourceName)
                        .fontWeight(.semibold)
                    Text("•")
                    Text(article.publishedAt.timeAgoDisplay())
                }
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
            }
            .padding(16)
        }
        .frame(height: 260)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

struct RecommendedNewsCard: View {
    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: article.imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.transNewsSoftGradient)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.transNewsSoftGradient)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 220, height: 130)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 6) {
                Text(article.localizedCategory)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.transNewsOrange)

                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(3)
                    .foregroundStyle(.primary)

                Text(article.publishedAt.timeAgoDisplay())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .frame(width: 220)
        .padding(10)
        .background(Color.transNewsCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.transNewsBorder, lineWidth: 1)
        )
    }
}

// MARK: - News List Card
struct NewsListCard: View {
    let article: NewsArticle
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: article.imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.transNewsSoftGradient)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.transNewsSoftGradient)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 95, height: 95)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                if let description = article.articleDescription {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 4) {
                    Text(article.sourceName)
                        .foregroundStyle(Color.transNewsOrange)
                        .fontWeight(.medium)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(article.publishedAt.timeAgoDisplay())
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if article.isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(Color.transNewsOrange)
                    }
                    
                    Text(Date.estimatedReadTime(for: article.content))
                        .foregroundStyle(.tertiary)
                }
                .font(.caption2)
            }
        }
        .padding(12)
        .background(Color.transNewsCardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.transNewsBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    HomeView(viewModel: NewsViewModel())
        .modelContainer(for: NewsArticle.self, inMemory: true)
}
