//
//  AppNavigationState.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import Observation

@Observable
final class AppNavigationState {
    static let shared = AppNavigationState()

    var pendingNotificationArticle: NotificationArticlePayload?

    private init() {}
}

struct NotificationArticlePayload: Equatable {
    let id: String
    let title: String
    let articleDescription: String?
    let content: String?
    let author: String?
    let sourceName: String
    let url: String
    let imageURL: String?
    let publishedAtISO8601: String
    let category: String
}
