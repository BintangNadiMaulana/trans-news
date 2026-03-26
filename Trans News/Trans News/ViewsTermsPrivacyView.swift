//
//  TermsPrivacyView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI

enum LegalPageType {
    case terms
    case privacy
    
    var title: String {
        switch self {
        case .terms: return "Syarat & Ketentuan"
        case .privacy: return "Kebijakan Privasi"
        }
    }
}

struct TermsPrivacyView: View {
    let pageType: LegalPageType
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(pageType.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Terakhir diperbarui: 22 Maret 2026")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // Content
                if pageType == .terms {
                    termsContent
                } else {
                    privacyContent
                }
            }
            .padding()
        }
        .navigationTitle(pageType.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Terms Content
    private var termsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            legalSection(
                title: "1. Penerimaan Syarat",
                content: "Dengan mengunduh dan menggunakan aplikasi Trans News, Anda menyetujui untuk terikat oleh syarat dan ketentuan ini. Jika Anda tidak menyetujui syarat ini, mohon untuk tidak menggunakan aplikasi."
            )
            
            legalSection(
                title: "2. Penggunaan Layanan",
                content: "Trans News menyediakan layanan berita dan informasi untuk keperluan pribadi dan non-komersial. Anda tidak diperkenankan menyalin, memodifikasi, atau mendistribusikan konten tanpa izin tertulis."
            )
            
            legalSection(
                title: "3. Konten",
                content: "Semua konten berita yang ditampilkan dalam aplikasi bersumber dari sumber-sumber terpercaya. Trans News berusaha menyajikan informasi yang akurat namun tidak menjamin kebenaran mutlak dari setiap berita."
            )
            
            legalSection(
                title: "4. Akun Pengguna",
                content: "Anda bertanggung jawab untuk menjaga kerahasiaan informasi akun Anda. Segala aktivitas yang terjadi melalui akun Anda menjadi tanggung jawab Anda."
            )
            
            legalSection(
                title: "5. Perubahan Syarat",
                content: "Trans News berhak mengubah syarat dan ketentuan ini sewaktu-waktu. Perubahan akan diberitahukan melalui aplikasi. Penggunaan berkelanjutan setelah perubahan berarti Anda menerima syarat yang diperbarui."
            )
        }
    }
    
    // MARK: - Privacy Content
    private var privacyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            legalSection(
                title: "1. Data yang Kami Kumpulkan",
                content: "Kami mengumpulkan data minimal yang diperlukan untuk menyediakan layanan, termasuk preferensi berita, bookmark, dan riwayat baca. Data ini disimpan secara lokal di perangkat Anda."
            )
            
            legalSection(
                title: "2. Penggunaan Data",
                content: "Data yang dikumpulkan digunakan untuk mempersonalisasi pengalaman membaca Anda, termasuk rekomendasi berita dan preferensi tampilan. Kami tidak menjual data pribadi Anda kepada pihak ketiga."
            )
            
            legalSection(
                title: "3. Penyimpanan Data",
                content: "Semua data pengguna disimpan secara lokal di perangkat Anda menggunakan teknologi enkripsi standar industri. Kami tidak menyimpan data Anda di server kami."
            )
            
            legalSection(
                title: "4. Hak Pengguna",
                content: "Anda berhak untuk mengakses, memperbarui, atau menghapus data pribadi Anda kapan saja melalui menu Pengaturan di aplikasi."
            )
            
            legalSection(
                title: "5. Keamanan",
                content: "Kami berkomitmen untuk melindungi keamanan data Anda. Kami menggunakan langkah-langkah keamanan teknis dan organisasi yang sesuai untuk mencegah akses tidak sah."
            )
        }
    }
    
    private func legalSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
    }
}

#Preview {
    NavigationStack {
        TermsPrivacyView(pageType: .terms)
    }
}
