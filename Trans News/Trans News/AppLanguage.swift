//
//  AppLanguage.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case indonesian = "id"
    case english = "en"

    var id: String { rawValue }

    static var current: AppLanguage {
        AppLanguage(rawValue: SharedAppStorage.currentSelectedLanguage()) ?? .indonesian
    }

    var localeIdentifier: String {
        switch self {
        case .indonesian:
            return "id_ID"
        case .english:
            return "en_US"
        }
    }

    func text(id: String, fallback: String) -> String {
        switch self {
        case .indonesian:
            return IndonesianStrings.values[id] ?? fallback
        case .english:
            return EnglishStrings.values[id] ?? fallback
        }
    }
}

enum L10n {
    static func tr(_ id: String, fallback: String) -> String {
        AppLanguage.current.text(id: id, fallback: fallback)
    }
}

private enum IndonesianStrings {
    static let values: [String: String] = [
        "home.featured": "Berita Utama",
        "home.latest": "Berita Terbaru",
        "home.seeAll": "Lihat Semua",
        "home.recommended": "Untuk Anda",
        "home.recommendedSubtitle": "Diurutkan berdasarkan kategori yang paling sering Anda baca",
        "home.searchTitle": "Cari Berita",
        "home.breaking": "BREAKING",
        "settings.title": "Pengaturan",
        "settings.theme": "Tema Aplikasi",
        "settings.system": "Sistem",
        "settings.light": "Terang",
        "settings.dark": "Gelap",
        "settings.readingMode": "Mode Baca",
        "settings.default": "Default",
        "settings.sepia": "Sepia (Hangat)",
        "settings.fontSize": "Ukuran Font Berita",
        "settings.notifications": "Aktifkan Notifikasi",
        "settings.notificationInfo": "Anda akan menerima breaking news dan rangkuman berdasarkan minat Anda",
        "settings.language": "Bahasa Berita",
        "settings.languageInfo.id": "Berita akan ditampilkan dalam Bahasa Indonesia",
        "settings.languageInfo.en": "News will be displayed in English",
        "settings.dailyDigest": "Rangkuman Harian",
        "settings.dailyDigestInfo": "Jadwalkan notifikasi rangkuman berita setiap pagi",
        "settings.darkOptimization": "Optimasi Dark Mode",
        "settings.darkOptimizationInfo": "Kontras kartu, teks, dan warna aksen disesuaikan otomatis untuk mode gelap",
        "detail.readFull": "Baca Artikel Lengkap",
        "detail.related": "Berita Terkait",
        "detail.listen": "Dengarkan",
        "detail.stopListening": "Berhenti",
        "detail.share": "Bagikan",
        "detail.shareMessage": "Baca berita ini di Trans News",
        "notifications.title": "Notifikasi",
        "notifications.emptyTitle": "Belum Ada Notifikasi",
        "notifications.emptySubtitle": "Notifikasi breaking news atau rangkuman harian akan muncul di sini.",
        "notifications.clearAll": "Hapus Semua",
        "notifications.inbox": "Masuk",
        "notifications.scheduled": "Terjadwal",
        "profile.title": "Profil",
        "profile.saved": "Tersimpan",
        "profile.read": "Dibaca",
        "profile.activeFeed": "Feed Aktif",
        "profile.preference": "Minat Utama",
        "profile.preferenceFallback": "Belum cukup data baca",
        "profile.about": "Tentang",
        "profile.edit": "Edit Profil",
        "search.title": "Cari Berita",
        "search.placeholder": "Cari berita...",
        "search.close": "Tutup",
        "search.loading": "Mencari berita...",
        "search.recent": "Pencarian Terakhir",
        "search.clear": "Hapus",
        "search.popular": "Topik Populer",
        "search.browse": "Jelajahi Kategori",
        "search.emptyTitle": "Tidak Ada Hasil",
        "search.emptySubtitle": "Coba kata kunci lain untuk menemukan berita yang Anda cari",
        "search.results": "hasil ditemukan",
        "category.title": "Kategori",
        "category.subtitle": "Jelajahi berita berdasarkan topik favorit Anda",
        "category.trending": "Trending",
        "category.all": "Semua Kategori",
        "allNews.title": "Semua Berita",
        "allNews.allCategories": "Semua",
        "allNews.count": "berita",
        "allNews.sortNewest": "Terbaru",
        "allNews.sortOldest": "Terlama",
        "bookmark.title": "Tersimpan",
        "history.title": "Riwayat Baca"
    ]
}

private enum EnglishStrings {
    static let values: [String: String] = [
        "home.featured": "Top Stories",
        "home.latest": "Latest News",
        "home.seeAll": "See All",
        "home.recommended": "Recommended For You",
        "home.recommendedSubtitle": "Ranked using your reading and bookmark history",
        "home.searchTitle": "Search News",
        "home.breaking": "BREAKING",
        "settings.title": "Settings",
        "settings.theme": "App Theme",
        "settings.system": "System",
        "settings.light": "Light",
        "settings.dark": "Dark",
        "settings.readingMode": "Reading Mode",
        "settings.default": "Default",
        "settings.sepia": "Sepia (Warm)",
        "settings.fontSize": "Article Font Size",
        "settings.notifications": "Enable Notifications",
        "settings.notificationInfo": "You will receive breaking alerts and digests based on your interests",
        "settings.language": "News Language",
        "settings.languageInfo.id": "News will be displayed in Bahasa Indonesia",
        "settings.languageInfo.en": "News will be displayed in English",
        "settings.dailyDigest": "Daily Digest",
        "settings.dailyDigestInfo": "Schedule a morning digest notification every day",
        "settings.darkOptimization": "Dark Mode Optimization",
        "settings.darkOptimizationInfo": "Cards, text contrast, and accent colors adapt automatically in dark mode",
        "detail.readFull": "Read Full Article",
        "detail.related": "Related Articles",
        "detail.listen": "Listen",
        "detail.stopListening": "Stop",
        "detail.share": "Share",
        "detail.shareMessage": "Read this story on Trans News",
        "notifications.title": "Notifications",
        "notifications.emptyTitle": "No Notifications Yet",
        "notifications.emptySubtitle": "Breaking alerts and daily digests will appear here.",
        "notifications.clearAll": "Clear All",
        "notifications.inbox": "Inbox",
        "notifications.scheduled": "Scheduled",
        "profile.title": "Profile",
        "profile.saved": "Saved",
        "profile.read": "Read",
        "profile.activeFeed": "Active Feed",
        "profile.preference": "Top Interest",
        "profile.preferenceFallback": "Not enough reading data yet",
        "profile.about": "About",
        "profile.edit": "Edit Profile",
        "search.title": "Search News",
        "search.placeholder": "Search stories...",
        "search.close": "Close",
        "search.loading": "Searching stories...",
        "search.recent": "Recent Searches",
        "search.clear": "Clear",
        "search.popular": "Popular Topics",
        "search.browse": "Browse Categories",
        "search.emptyTitle": "No Results",
        "search.emptySubtitle": "Try another keyword to find the story you're looking for",
        "search.results": "results found",
        "category.title": "Categories",
        "category.subtitle": "Explore stories based on your favorite topics",
        "category.trending": "Trending",
        "category.all": "All Categories",
        "allNews.title": "All News",
        "allNews.allCategories": "All",
        "allNews.count": "stories",
        "allNews.sortNewest": "Newest",
        "allNews.sortOldest": "Oldest",
        "bookmark.title": "Saved",
        "history.title": "Reading History"
    ]
}
