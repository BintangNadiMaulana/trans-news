# Setup Guide - Trans News

## 📝 Panduan Lengkap Setup Aplikasi

### 1. Clone/Download Project

Pastikan semua file sudah ada di project Anda:
- ✅ Models/NewsArticle.swift
- ✅ Services/NewsAPIService.swift
- ✅ ViewModels/NewsViewModel.swift
- ✅ Views/*.swift (semua file view)
- ✅ Extensions/*.swift

### 2. Konfigurasi Xcode

#### A. File Organization
Organisir file di Xcode sesuai struktur folder:

```
Trans News/
├── Models/
├── Services/
├── ViewModels/
├── Views/
├── Extensions/
└── Resources/
```

#### B. Build Settings
1. Pastikan Deployment Target: **iOS 17.0+**
2. Swift Language Version: **Swift 6**

### 3. Setup Sumber Berita

Project ini sudah langsung menggunakan feed publik Google News RSS.

- Tidak perlu API key
- Tidak perlu konfigurasi provider tambahan
- Tidak perlu mengganti mock data

Pastikan perangkat atau simulator memiliki koneksi internet aktif agar feed berita dan pencarian bisa dimuat.

### 4. Test Aplikasi

#### A. Build & Run
1. Pilih simulator iPhone (recommended: iPhone 15 Pro)
2. Tekan `Cmd + R`
3. Tunggu aplikasi launch

#### B. Test Fitur
- ✅ Home screen menampilkan berita
- ✅ Tap berita untuk lihat detail
- ✅ Bookmark berita (icon bookmark)
- ✅ Navigate ke tab Kategori
- ✅ Browse kategori berita
- ✅ Search berita
- ✅ Lihat bookmarks di tab Tersimpan

### 5. Troubleshooting

#### Error: "Could not create ModelContainer"
**Solusi**: 
- Clean Build Folder (`Cmd + Shift + K`)
- Reset simulator
- Rebuild project

#### Error: "Type 'NewsArticle' not found"
**Solusi**:
- Pastikan file `Models/NewsArticle.swift` sudah ditambahkan ke target
- Rebuild project

#### Berita tidak muncul
**Solusi**:
- Periksa koneksi internet
- Coba pull to refresh di halaman Home atau kategori
- Check console untuk error log

#### UI tidak rapi
**Solusi**:
- Pastikan iOS Deployment Target: 17.0+
- Test di simulator yang supported
- Restart simulator

### 6. Customization

#### A. Ganti Warna Brand
Edit file `Extensions/ColorExtension.swift`:

```swift
extension Color {
    static let transNewsOrange = Color(red: 1.0, green: 0.5, blue: 0.0)
    static let transNewsRed = Color(red: 0.9, green: 0.2, blue: 0.2)
}
```

#### B. Tambah Kategori
Edit enum di `Models/NewsArticle.swift`:

```swift
enum NewsCategory: String, CaseIterable, Identifiable {
    case general = "general"
    case business = "business"
    case customCategory = "custom" // 👈 Tambah di sini
    
    var displayName: String {
        switch self {
        case .customCategory: return "Custom"
        // ... dst
        }
    }
}
```

### 7. Assets (Opsional)

#### Tambah App Icon
1. Klik folder `Assets.xcassets`
2. Klik `AppIcon`
3. Drag & drop logo Trans News dengan berbagai ukuran:
   - 1024x1024 (App Store)
   - 180x180 (iPhone)
   - dll sesuai slot yang tersedia

#### Tambah Launch Screen
1. Edit `LaunchScreen.storyboard` atau
2. Buat SwiftUI LaunchScreen

### 8. Testing

#### Unit Testing
Buat test untuk ViewModel:

```swift
import Testing
import SwiftData

@Test("Load news from API")
func testLoadNews() async throws {
    let viewModel = NewsViewModel()
    await viewModel.loadNews()
    #expect(!viewModel.articles.isEmpty)
}
```

### 9. Build untuk Device

#### Langkah Deploy ke iPhone Fisik
1. Connect iPhone via USB
2. Pilih device di Xcode
3. Sign in dengan Apple ID di Xcode > Preferences > Accounts
4. Select Team di Signing & Capabilities
5. Build & Run

### 10. Submit ke App Store (Lanjutan)

Jika ingin publish:
1. Tambah privacy policy
2. Setup App Store Connect
3. Create app listing
4. Submit for review

## 🎉 Selesai!

Aplikasi Trans News Anda siap digunakan!

### Kontak
Jika ada masalah, silakan:
- Baca error di Xcode console
- Check dokumentasi Apple SwiftUI
- Review file README.md

---

**Happy Coding! 🚀**
