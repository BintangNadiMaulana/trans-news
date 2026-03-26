//
//  Trans_NewsTests.swift
//  Trans NewsTests
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import Testing
import Foundation
@testable import Trans_News

struct Trans_NewsTests {

    @Test("News article ID mengikuti URL agar persistence stabil")
    func articleIDUsesURL() {
        let dto = NewsArticleDTO(
            source: NewsSource(id: nil, name: "Trans News"),
            author: "Editor",
            title: "Judul Berita",
            description: "Deskripsi",
            url: "https://example.com/article",
            urlToImage: nil,
            publishedAt: ISO8601DateFormatter().string(from: Date()),
            content: "Isi berita"
        )

        let article = NewsArticle.from(dto: dto, category: NewsCategory.business.rawValue)

        #expect(article.id == dto.url)
        #expect(article.category == NewsCategory.business.rawValue)
    }

    @Test("Estimasi waktu baca minimal satu menit")
    func estimatedReadTimeHasMinimumOneMinute() {
        let shortText = "Halo dunia"
        let result = Date.estimatedReadTime(for: shortText)

        #expect(result.contains("1"))
    }
}
