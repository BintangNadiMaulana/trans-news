//
//  OnboardingView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "newspaper.fill",
            title: "Berita Terkini",
            subtitle: "Dapatkan berita terbaru dari berbagai kategori langsung di genggaman Anda",
            color: .transNewsOrange
        ),
        OnboardingPage(
            icon: "square.grid.2x2.fill",
            title: "7 Kategori Lengkap",
            subtitle: "Jelajahi berita dari Bisnis, Teknologi, Olahraga, Hiburan, Kesehatan, Sains, dan lainnya",
            color: .purple
        ),
        OnboardingPage(
            icon: "bookmark.fill",
            title: "Simpan & Baca Nanti",
            subtitle: "Bookmark berita favorit Anda dan baca kapan saja, bahkan secara offline",
            color: .transNewsBlue
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Pages
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    VStack(spacing: 32) {
                        Spacer()
                        
                        // Icon
                        ZStack {
                            Circle()
                                .fill(page.color.opacity(0.15))
                                .frame(width: 160, height: 160)
                            
                            Circle()
                                .fill(page.color.opacity(0.08))
                                .frame(width: 220, height: 220)
                            
                            Image(systemName: page.icon)
                                .font(.system(size: 70))
                                .foregroundStyle(page.color)
                        }
                        
                        VStack(spacing: 16) {
                            Text(page.title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                            
                            Text(page.subtitle)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        Spacer()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Bottom controls
            VStack(spacing: 24) {
                // Custom page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.transNewsOrange : Color.gray.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                
                // Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            hasSeenOnboarding = true
                        }
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Lanjut" : "Mulai Membaca")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.transNewsGradient)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                
                if currentPage < pages.count - 1 {
                    Button("Lewati") {
                        withAnimation { hasSeenOnboarding = true }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                } else {
                    Color.clear.frame(height: 20)
                }
            }
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
