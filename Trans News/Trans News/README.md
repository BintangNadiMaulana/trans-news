# Trans News - Aplikasi Berita Modern

![Trans News Logo](Trans%20News%20LOGO.png)

## 📱 Deskripsi

Trans News adalah aplikasi berita modern yang dibangun dengan SwiftUI dan Swift 6. Aplikasi ini mengambil berita nyata dari Google News RSS, sehingga bisa langsung dijalankan tanpa API key tambahan.

## ✨ Fitur Utama

- **Berita Terkini**: Dapatkan berita terbaru dari berbagai sumber terpercaya
- **Kategori Berita**: 7 kategori berita (Terkini, Bisnis, Teknologi, Hiburan, Kesehatan, Sains, Olahraga)
- **Pencarian**: Cari berita berdasarkan kata kunci
- **Bookmark**: Simpan berita favorit untuk dibaca nanti
- **Mode Offline**: Berita yang disimpan bisa dibaca tanpa koneksi internet
- **UI/UX Modern**: Desain yang clean dan intuitif dengan animasi halus

## 🏗️ Arsitektur

Aplikasi ini dibangun menggunakan:

- **SwiftUI**: Framework UI modern dari Apple
- **SwiftData**: Untuk persistent storage (bookmark)
- **MVVM Pattern**: Memisahkan business logic dari UI
- **Async/Await**: Concurrency modern Swift
- **Google News RSS**: Sumber berita publik tanpa API key

## 📂 Struktur Project

```
Trans News/
├── Models/
│   └── NewsArticle.swift          # Data models
├── Services/
│   └── NewsAPIService.swift       # API integration
├── ViewModels/
│   └── NewsViewModel.swift        # Business logic
├── Views/
│   ├── ContentView.swift          # Tab bar utama
│   ├── HomeView.swift             # Halaman beranda
│   ├── NewsDetailView.swift       # Detail berita
│   ├── CategoriesView.swift       # Kategori berita
│   ├── BookmarksView.swift        # Berita tersimpan
│   ├── SearchView.swift           # Pencarian
│   ├── ProfileView.swift          # Profil pengguna
│   └── AllNewsView.swift          # Semua berita
├── Extensions/
│   └── ColorExtension.swift       # Color utilities
└── Trans_NewsApp.swift            # App entry point
```

## 🚀 Cara Menggunakan

### 1. Run Aplikasi

1. Buka project di Xcode
2. Pilih simulator atau device
3. Tekan `Cmd + R` atau klik tombol Run

### 2. Koneksi Internet

Feed berita, kategori, dan pencarian membutuhkan koneksi internet aktif karena data diambil langsung dari feed publik Google News RSS.

## 📱 Fitur Detail

### Home Screen
- **Featured News**: Carousel berita utama dengan gambar menarik
- **Latest News**: List berita terbaru dengan thumbnail
- **Pull to Refresh**: Tarik ke bawah untuk refresh berita
- **Search**: Tombol search di navigation bar

### Categories
- Grid view dengan 7 kategori berita
- Setiap kategori memiliki icon dan warna yang berbeda
- Tap kategori untuk melihat berita per kategori

### Bookmarks
- Lihat semua berita yang telah disimpan
- Filter berdasarkan waktu (Hari Ini, Minggu Ini, Bulan Ini)
- Swipe untuk delete bookmark

### Search
- Real-time search dengan debouncing
- Suggestion topik populer
- Empty state yang informatif

### Profile
- Statistik berita tersimpan dan dibaca
- Menu pengaturan aplikasi
- Informasi tentang aplikasi

## 🎨 Desain UI/UX

### Color Scheme
- **Primary**: Orange (#FF8000) - Warna brand Trans News
- **Secondary**: Red (#E63333) - Aksen
- **Accent**: Blue (#0080FF) - Kategori tertentu

### Typography
- **San Francisco** (System Font)
- Menggunakan Dynamic Type untuk aksesibilitas
- Font weight yang bervariasi untuk hierarki visual

### Components
- **Cards**: Rounded corners dengan shadow halus
- **Gradients**: Digunakan untuk featured news dan accent
- **Icons**: SF Symbols untuk konsistensi

## 🔧 Dependencies

Project ini menggunakan framework bawaan iOS:
- SwiftUI
- SwiftData
- Foundation
- Combine (minimal)

**Tidak ada third-party dependencies!**

## 📋 Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 6.0+

## 🌟 Status Fitur Lanjutan

- [x] Push notifications untuk breaking news
- [x] Dark mode optimization
- [x] Widget untuk iOS home screen
- [x] Sharing ke social media
- [x] Audio news (text-to-speech)
- [x] Personalisasi berdasarkan reading history
- [x] Multi-language support

## 👨‍💻 Developer

**Bintang Nadi Maulana**

## 📄 License

Copyright © 2026 Trans News. All rights reserved.

## 🙏 Credits

- Google News RSS
- Images: Unsplash (untuk mock data)
- Icons: SF Symbols

---

**Happy Coding! 🚀**
