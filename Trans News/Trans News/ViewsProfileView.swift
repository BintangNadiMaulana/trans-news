//
//  ProfileView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allArticles: [NewsArticle]
    var viewModel: NewsViewModel
    
    @AppStorage("userName") private var userName = "Bintang Nadi"
    @AppStorage("userEmail") private var userEmail = "bintang@transnews.com"
    @AppStorage("userInitials") private var userInitials = "BN"
    
    @State private var showEditProfile = false
    
    private var bookmarkedCount: Int {
        allArticles.filter { $0.isBookmarked }.count
    }
    
    private var readCount: Int {
        allArticles.filter { $0.isRead }.count
    }

    private var liveFeedCount: Int {
        if !viewModel.homeArticles.isEmpty {
            return viewModel.homeArticles.count
        }

        return bookmarkedCount + readCount
    }

    private var topInterest: String {
        viewModel.dominantCategoryName()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header Card
                    profileHeaderCard
                    
                    // Stats Row
                    statsRow
                    
                    // Menu Sections
                    menuSection(title: "Konten", items: [
                        MenuItem(icon: "bell.badge.fill", title: "Notifikasi", color: .red, destination: AnyView(NotificationsView())),
                        MenuItem(icon: "clock.arrow.circlepath", title: "Riwayat Baca", color: .transNewsBlue, destination: AnyView(ReadHistoryView(viewModel: viewModel))),
                    ])
                    
                    menuSection(title: "Pengaturan", items: [
                        MenuItem(icon: "gearshape.fill", title: "Pengaturan", color: .gray, destination: AnyView(SettingsView())),
                        MenuItem(icon: "questionmark.circle.fill", title: "Bantuan & FAQ", color: .transNewsBlue, destination: AnyView(HelpFAQView())),
                    ])
                    
                    menuSection(title: "Legal", items: [
                        MenuItem(icon: "doc.text.fill", title: "Syarat & Ketentuan", color: .purple, destination: AnyView(TermsPrivacyView(pageType: .terms))),
                        MenuItem(icon: "lock.shield.fill", title: "Kebijakan Privasi", color: .green, destination: AnyView(TermsPrivacyView(pageType: .privacy))),
                    ])
                    
                    // About
                    aboutSection
                    
                    Text("Trans News v1.0.0")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L10n.tr("profile.title", fallback: "Profil"))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    userName: $userName,
                    userEmail: $userEmail,
                    userInitials: $userInitials
                )
            }
        }
    }
    
    // MARK: - Profile Header Card
    private var profileHeaderCard: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.transNewsGradient)
                    .frame(width: 90, height: 90)
                    .shadow(color: Color.transNewsOrange.opacity(0.3), radius: 10, x: 0, y: 4)
                
                Text(userInitials)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 4) {
                Text(userName)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(userEmail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Button {
                showEditProfile = true
            } label: {
                Text(L10n.tr("profile.edit", fallback: "Edit Profil"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.transNewsOrange)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Color.transNewsOrange.opacity(0.12))
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatBadge(icon: "bookmark.fill", value: bookmarkedCount, label: L10n.tr("profile.saved", fallback: "Tersimpan"), color: .transNewsOrange)
            StatBadge(icon: "eye.fill", value: readCount, label: L10n.tr("profile.read", fallback: "Dibaca"), color: .transNewsBlue)
            StatBadge(icon: "newspaper.fill", value: liveFeedCount, label: L10n.tr("profile.activeFeed", fallback: "Feed Aktif"), color: .purple)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Menu Section
    private func menuSection(title: String, items: [MenuItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 28)
                .padding(.bottom, 6)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    NavigationLink(destination: item.destination) {
                        HStack(spacing: 14) {
                            Image(systemName: item.icon)
                                .font(.body)
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(item.color)
                                .cornerRadius(8)
                            
                            Text(item.title)
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    if index < items.count - 1 {
                        Divider().padding(.leading, 62)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .padding(.horizontal)
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.tr("profile.about", fallback: "Tentang"))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 28)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Trans News adalah aplikasi berita terpercaya yang menyajikan informasi terkini dari berbagai kategori. Kami berkomitmen untuk memberikan berita yang akurat, objektif, dan berkualitas tinggi.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.tr("profile.preference", fallback: "Minat Utama"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text(topInterest)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .padding(.horizontal)
        }
    }
}

// MARK: - MenuItem
struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
    let destination: AnyView
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var userInitials: String
    
    @State private var editName = ""
    @State private var editEmail = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informasi Profil") {
                    TextField("Nama", text: $editName)
                    TextField("Email", text: $editEmail)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Pratinjau") {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.transNewsGradient)
                                .frame(width: 56, height: 56)
                            
                            Text(computeInitials(from: editName))
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(editName.isEmpty ? "Nama" : editName)
                                .font(.headline)
                            Text(editEmail.isEmpty ? "email@example.com" : editEmail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Edit Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simpan") {
                        userName = editName
                        userEmail = editEmail
                        userInitials = computeInitials(from: editName)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(editName.isEmpty || editEmail.isEmpty)
                }
            }
            .onAppear {
                editName = userName
                editEmail = userEmail
            }
        }
    }
    
    private func computeInitials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map { String($0).uppercased() }
        return initials.joined()
    }
}

#Preview {
    ProfileView(viewModel: NewsViewModel())
        .modelContainer(for: NewsArticle.self, inMemory: true)
}
