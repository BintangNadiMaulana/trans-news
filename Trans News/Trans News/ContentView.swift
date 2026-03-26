//
//  ContentView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var viewModel = NewsViewModel()
    @State private var previousTab = 0
    @State private var navigationState = AppNavigationState.shared
    @State private var deepLinkedArticle: NewsArticle?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                HomeView(viewModel: viewModel)
                    .tag(0)
                
                CategoriesView(viewModel: viewModel)
                    .tag(1)
                
                BookmarksView(viewModel: viewModel)
                    .tag(2)
                
                ProfileView(viewModel: viewModel)
                    .tag(3)
            }
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: selectedTab) { _, newValue in
            if newValue != previousTab {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                previousTab = newValue
            }
        }
        .task {
            viewModel.configure(modelContext: modelContext)
        }
        .task {
            await NotificationService.shared.refreshNotificationBadgeCount()
        }
        .onChange(of: navigationState.pendingNotificationArticle) { _, payload in
            guard let payload else { return }
            deepLinkedArticle = resolveArticle(from: payload)
            selectedTab = 0
            navigationState.pendingNotificationArticle = nil
        }
        .onOpenURL { url in
            guard let article = resolveArticle(from: url) else { return }
            deepLinkedArticle = article
            selectedTab = 0
        }
        .sheet(item: $deepLinkedArticle) { article in
            NavigationStack {
                NewsDetailView(article: article, viewModel: viewModel)
            }
        }
    }

    private func resolveArticle(from payload: NotificationArticlePayload) -> NewsArticle {
        if let article = viewModel.article(withID: payload.id) {
            return article
        }

        let publishedAt = ISO8601DateFormatter().date(from: payload.publishedAtISO8601) ?? Date()
        return NewsArticle(
            id: payload.id,
            title: payload.title,
            articleDescription: payload.articleDescription,
            content: payload.content,
            author: payload.author,
            sourceName: payload.sourceName,
            url: payload.url,
            imageURL: payload.imageURL,
            publishedAt: publishedAt,
            category: payload.category
        )
    }

    private func resolveArticle(from url: URL) -> NewsArticle? {
        guard url.scheme == "transnews",
              url.host == "article",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        let values = Dictionary(uniqueKeysWithValues: components.queryItems?.map { ($0.name, $0.value ?? "") } ?? [])
        let articleURL = values["url"] ?? ""
        let articleID = values["id"].flatMap { $0.isEmpty ? nil : $0 } ?? articleURL

        guard !articleID.isEmpty,
              !articleURL.isEmpty,
              let title = values["title"],
              !title.isEmpty,
              let sourceName = values["source"],
              !sourceName.isEmpty else {
            return nil
        }

        if let article = viewModel.article(withID: articleID) {
            return article
        }

        let publishedAt = values["publishedAt"]
            .flatMap(TimeInterval.init)
            .map(Date.init(timeIntervalSince1970:)) ?? Date()

        return NewsArticle(
            id: articleID,
            title: title,
            sourceName: sourceName,
            url: articleURL,
            publishedAt: publishedAt
        )
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var tabAnimation
    
    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Beranda"),
        ("square.grid.2x2.fill", "Kategori"),
        ("bookmark.fill", "Tersimpan"),
        ("person.fill", "Profil")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if selectedTab == index {
                                Capsule()
                                    .fill(Color.transNewsOrange.opacity(0.15))
                                    .frame(width: 56, height: 32)
                                    .matchedGeometryEffect(id: "tabBg", in: tabAnimation)
                            }
                            
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: selectedTab == index ? .semibold : .regular))
                                .foregroundStyle(selectedTab == index ? Color.transNewsOrange : .gray)
                        }
                        .frame(height: 32)
                        
                        Text(tab.label)
                            .font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundStyle(selectedTab == index ? Color.transNewsOrange : .gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: NewsArticle.self, inMemory: true)
}
