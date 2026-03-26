//
//  HelpFAQView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct HelpFAQView: View {
    @State private var expandedItem: UUID?
    
    private let faqItems: [FAQItem] = [
        FAQItem(
            question: "Bagaimana cara menyimpan berita?",
            answer: "Ketuk ikon bookmark pada halaman detail berita untuk menyimpannya. Berita yang tersimpan dapat diakses melalui tab 'Tersimpan' di menu utama."
        ),
        FAQItem(
            question: "Apakah berita bisa dibaca secara offline?",
            answer: "Saat ini berita memerlukan koneksi internet untuk dimuat. Namun berita yang sudah tersimpan (bookmark) akan tetap dapat diakses secara offline."
        ),
        FAQItem(
            question: "Bagaimana cara mengubah ukuran teks?",
            answer: "Buka menu Profil > Pengaturan > Tampilan. Di sana Anda dapat mengatur ukuran font sesuai kenyamanan Anda."
        ),
        FAQItem(
            question: "Bagaimana cara mencari berita tertentu?",
            answer: "Ketuk ikon pencarian di halaman Beranda atau gunakan tab Kategori untuk menjelajahi berita berdasarkan topik tertentu."
        ),
        FAQItem(
            question: "Bagaimana cara berbagi berita?",
            answer: "Buka halaman detail berita, lalu ketuk ikon bagikan (share) di bagian atas. Anda dapat berbagi melalui berbagai platform seperti WhatsApp, Instagram, dan lainnya."
        ),
        FAQItem(
            question: "Bagaimana cara menghapus semua bookmark?",
            answer: "Buka tab 'Tersimpan', lalu ketuk ikon tempat sampah di pojok kanan atas untuk menghapus semua berita tersimpan."
        ),
        FAQItem(
            question: "Bagaimana cara menghubungi tim Trans News?",
            answer: "Anda dapat menghubungi kami melalui email di support@transnews.com atau melalui media sosial resmi Trans News."
        )
    ]
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pusat Bantuan")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Temukan jawaban untuk pertanyaan yang sering diajukan")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }
            
            Section("Pertanyaan Umum") {
                ForEach(faqItems) { item in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedItem == item.id },
                            set: { isExpanded in
                                withAnimation {
                                    expandedItem = isExpanded ? item.id : nil
                                }
                            }
                        )
                    ) {
                        Text(item.answer)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    } label: {
                        Text(item.question)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Section("Hubungi Kami") {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.transNewsOrange)
                        .frame(width: 28)
                    Text("support@transnews.com")
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "globe")
                        .foregroundStyle(.transNewsOrange)
                        .frame(width: 28)
                    Text("www.transnews.com")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Bantuan & FAQ")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        HelpFAQView()
    }
}
