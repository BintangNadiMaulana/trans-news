//
//  SettingsView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI
import SwiftData
import UserNotifications
import WidgetKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("fontSize") private var fontSize: Double = 16
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("selectedLanguage") private var selectedLanguage = "id"
    @AppStorage("appColorScheme") private var appColorScheme = "system"
    @AppStorage("readingMode") private var readingMode = "default"
    @AppStorage("dailyDigestEnabled") private var dailyDigestEnabled = true
    @State private var showDeleteConfirmation = false
    @State private var showDeleteSuccess = false
    @State private var showNotificationDenied = false
    
    var body: some View {
        List {
            // Tampilan
            Section {
                // Dark mode
                Picker(L10n.tr("settings.theme", fallback: "Tema Aplikasi"), selection: $appColorScheme) {
                    HStack {
                        Image(systemName: "iphone")
                        Text(L10n.tr("settings.system", fallback: "Sistem"))
                    }.tag("system")
                    HStack {
                        Image(systemName: "sun.max.fill")
                        Text(L10n.tr("settings.light", fallback: "Terang"))
                    }.tag("light")
                    HStack {
                        Image(systemName: "moon.fill")
                        Text(L10n.tr("settings.dark", fallback: "Gelap"))
                    }.tag("dark")
                }
                
                // Reading Mode
                Picker(L10n.tr("settings.readingMode", fallback: "Mode Baca"), selection: $readingMode) {
                    Text(L10n.tr("settings.default", fallback: "Default")).tag("default")
                    Text(L10n.tr("settings.sepia", fallback: "Sepia (Hangat)")).tag("sepia")
                    Text(L10n.tr("settings.dark", fallback: "Gelap")).tag("dark")
                }
                
                // Font Size
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(L10n.tr("settings.fontSize", fallback: "Ukuran Font Berita"))
                        Spacer()
                        Text("\(Int(fontSize))pt")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.transNewsOrange)
                    }
                    
                    Slider(value: $fontSize, in: 12...24, step: 1)
                        .tint(.transNewsOrange)
                    
                    // Live preview with reading mode
                    Text("Contoh teks berita dengan ukuran font yang dipilih. Ini adalah preview bagaimana berita akan ditampilkan.")
                        .font(.system(size: fontSize))
                        .foregroundStyle(readingModePreviewTextColor)
                        .padding(12)
                        .background(readingModePreviewBg)
                        .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Label(L10n.tr("settings.darkOptimization", fallback: "Optimasi Dark Mode"), systemImage: "moon.stars.fill")
                        .font(.subheadline.weight(.semibold))
                    Text(L10n.tr("settings.darkOptimizationInfo", fallback: "Kontras kartu, teks, dan warna aksen disesuaikan otomatis untuk mode gelap"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Label("Tampilan", systemImage: "paintbrush.fill")
            }
            
            // Notifikasi
            Section {
                Toggle(isOn: $notificationsEnabled) {
                    HStack(spacing: 10) {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(.red)
                        Text(L10n.tr("settings.notifications", fallback: "Aktifkan Notifikasi"))
                    }
                }
                .tint(.transNewsOrange)
                .onChange(of: notificationsEnabled) { _, newValue in
                    handleNotificationToggle(enabled: newValue)
                }
                
                if notificationsEnabled {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        Text(L10n.tr("settings.notificationInfo", fallback: "Anda akan menerima breaking news dan rangkuman berdasarkan minat Anda"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle(L10n.tr("settings.dailyDigest", fallback: "Rangkuman Harian"), isOn: $dailyDigestEnabled)
                    .tint(.transNewsOrange)
                    .onChange(of: dailyDigestEnabled) { _, newValue in
                        if newValue {
                            NotificationService.shared.scheduleDailyDigest()
                        } else {
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-digest"])
                        }
                    }

                Text(L10n.tr("settings.dailyDigestInfo", fallback: "Jadwalkan notifikasi rangkuman berita setiap pagi"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Label("Notifikasi", systemImage: "bell.fill")
            }
            
            // Bahasa
            Section {
                Picker(selection: $selectedLanguage) {
                    Text("Bahasa Indonesia").tag("id")
                    Text("English").tag("en")
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "globe")
                            .foregroundStyle(.transNewsBlue)
                        Text(L10n.tr("settings.language", fallback: "Bahasa Berita"))
                    }
                }
                
                HStack(spacing: 10) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Text(selectedLanguage == "id"
                         ? L10n.tr("settings.languageInfo.id", fallback: "Berita akan ditampilkan dalam Bahasa Indonesia")
                         : L10n.tr("settings.languageInfo.en", fallback: "News will be displayed in English"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Label("Bahasa", systemImage: "globe")
            }
            
            // Data
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "trash")
                        Text("Hapus Semua Data Cache")
                    }
                }
            } header: {
                Label("Data & Penyimpanan", systemImage: "internaldrive.fill")
            }
            
            // Info
            Section {
                HStack {
                    Text("Versi")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Build")
                    Spacer()
                    Text("2026.03.23")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Label("Informasi", systemImage: "info.circle.fill")
            }
        }
        .navigationTitle(L10n.tr("settings.title", fallback: "Pengaturan"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            SharedAppStorage.syncSelectedLanguage(selectedLanguage)
        }
        .onChange(of: selectedLanguage) { _, newValue in
            SharedAppStorage.syncSelectedLanguage(newValue)
        }
        .alert("Hapus Cache", isPresented: $showDeleteConfirmation) {
            Button("Batal", role: .cancel) {}
            Button("Hapus", role: .destructive) { clearCache() }
        } message: {
            Text("Semua data cache akan dihapus. Berita tersimpan (bookmark) tidak akan terpengaruh.")
        }
        .alert("Berhasil", isPresented: $showDeleteSuccess) {
            Button("OK") {}
        } message: {
            Text("Cache berhasil dihapus.")
        }
        .alert("Notifikasi Diblokir", isPresented: $showNotificationDenied) {
            Button("Buka Pengaturan") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Batal", role: .cancel) {
                notificationsEnabled = false
            }
        } message: {
            Text("Izin notifikasi ditolak. Buka Pengaturan untuk mengaktifkan notifikasi.")
        }
    }
    
    // MARK: - Reading Mode Preview
    
    private var readingModePreviewBg: Color {
        switch readingMode {
        case "sepia": return Color(red: 0.96, green: 0.93, blue: 0.87)
        case "dark": return Color(red: 0.12, green: 0.12, blue: 0.14)
        default: return Color(.systemGray6)
        }
    }
    
    private var readingModePreviewTextColor: Color {
        switch readingMode {
        case "sepia": return Color(red: 0.3, green: 0.25, blue: 0.15)
        case "dark": return Color(red: 0.85, green: 0.85, blue: 0.85)
        default: return .secondary
        }
    }
    
    // MARK: - Actions
    
    private func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        showDeleteSuccess = true
    }
    
    private func handleNotificationToggle(enabled: Bool) {
        if enabled {
            Task {
                let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                if granted != true {
                    showNotificationDenied = true
                } else {
                    NotificationService.shared.isAuthorized = true
                    NotificationService.shared.scheduleDailyDigest()
                }
            }
        } else {
            NotificationService.shared.isAuthorized = false
            UIApplication.shared.unregisterForRemoteNotifications()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-digest"])
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
