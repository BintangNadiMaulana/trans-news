//
//  NotificationService.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import Foundation
import Observation
import UserNotifications
import UIKit

struct AppNotification: Identifiable {
    let id: String
    let title: String
    let message: String
    let time: Date
    let icon: String
    let colorName: String
    let isDelivered: Bool
}

@MainActor
@Observable
final class NotificationService {
    static let shared = NotificationService()
    
    var isAuthorized = false
    var notificationBadgeCount = 0

    private let lastBreakingArticleKey = "lastBreakingArticleID"
    
    private init() {}

    private var notificationsEnabled: Bool {
        if UserDefaults.standard.object(forKey: "notificationsEnabled") == nil {
            return true
        }

        return UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }
    
    // MARK: - Request Permission
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
            return granted
        } catch {
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Schedule Breaking News Notification
    
    func scheduleBreakingNewsNotification(for article: NewsArticle) {
        guard notificationsEnabled else { return }
        guard UserDefaults.standard.string(forKey: lastBreakingArticleKey) != article.id else { return }
        
        let content = UNMutableNotificationContent()
        content.title = AppLanguage.current == .english ? "BREAKING NEWS" : "BREAKING NEWS"
        content.subtitle = article.title
        content.body = article.articleDescription ?? article.sourceName
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "articleId": article.id,
            "title": article.title,
            "articleDescription": article.articleDescription ?? "",
            "content": article.content ?? "",
            "author": article.author ?? "",
            "sourceName": article.sourceName,
            "url": article.url,
            "imageURL": article.imageURL ?? "",
            "publishedAt": ISO8601DateFormatter().string(from: article.publishedAt),
            "category": article.category
        ]
        content.categoryIdentifier = "BREAKING_NEWS"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "breaking-\(article.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        UserDefaults.standard.set(article.id, forKey: lastBreakingArticleKey)
    }
    
    // MARK: - Schedule Category News Notification
    
    func scheduleCategoryNotification(category: String, title: String, body: String) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = category
        content.body = title
        content.sound = .default
        content.userInfo = ["category": category]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "category-\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Schedule Daily Digest
    
    func scheduleDailyDigest(hour: Int = 8, minute: Int = 0) {
        guard notificationsEnabled else { return }
        
        // Hapus jadwal lama
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-digest"])
        
        let content = UNMutableNotificationContent()
        content.title = AppLanguage.current == .english ? "Morning Digest" : "Rangkuman Pagi"
        content.body = AppLanguage.current == .english ? "Read today's top stories from Trans News" : "Baca berita terkini hari ini dari Trans News"
        content.sound = .default
        content.categoryIdentifier = "DAILY_DIGEST"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-digest", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Clear Badge
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
        notificationBadgeCount = 0
    }
    
    // MARK: - Remove All Notifications
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        clearBadge()
    }

    func processBreakingNewsIfNeeded(article: NewsArticle?) {
        guard let article else { return }
        guard notificationsEnabled else { return }
        guard isAuthorized else { return }

        let lastSeenArticleID = UserDefaults.standard.string(forKey: lastBreakingArticleKey)
        if lastSeenArticleID == nil {
            UserDefaults.standard.set(article.id, forKey: lastBreakingArticleKey)
            return
        }

        scheduleBreakingNewsNotification(for: article)
    }

    func fetchNotifications() async -> [AppNotification] {
        let center = UNUserNotificationCenter.current()
        let delivered = await center.deliveredNotifications()
        let pending = await center.pendingNotificationRequests()

        let deliveredItems = delivered.map { notification in
            AppNotification(
                id: notification.request.identifier,
                title: notification.request.content.title,
                message: notification.request.content.body,
                time: notification.date,
                icon: iconName(for: notification.request.content.categoryIdentifier),
                colorName: colorName(for: notification.request.content.categoryIdentifier),
                isDelivered: true
            )
        }

        let pendingItems = pending.map { request in
            AppNotification(
                id: request.identifier,
                title: request.content.title,
                message: request.content.body,
                time: nextTriggerDate(for: request) ?? Date(),
                icon: iconName(for: request.content.categoryIdentifier),
                colorName: colorName(for: request.content.categoryIdentifier),
                isDelivered: false
            )
        }

        return (deliveredItems + pendingItems).sorted { $0.time > $1.time }
    }

    func refreshNotificationBadgeCount() async {
        let center = UNUserNotificationCenter.current()
        let delivered = await center.deliveredNotifications()
        let pending = await center.pendingNotificationRequests()
        notificationBadgeCount = delivered.count + pending.count
    }
    
    // MARK: - Setup Notification Categories
    
    func setupNotificationCategories() {
        let openAction = UNNotificationAction(identifier: "OPEN_ARTICLE", title: "Baca Selengkapnya", options: .foreground)
        let bookmarkAction = UNNotificationAction(identifier: "BOOKMARK_ARTICLE", title: "Simpan", options: [])
        
        let breakingCategory = UNNotificationCategory(
            identifier: "BREAKING_NEWS",
            actions: [openAction, bookmarkAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        let digestCategory = UNNotificationCategory(
            identifier: "DAILY_DIGEST",
            actions: [openAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([breakingCategory, digestCategory])
    }

    private func iconName(for categoryIdentifier: String) -> String {
        switch categoryIdentifier {
        case "BREAKING_NEWS":
            return "bolt.fill"
        case "DAILY_DIGEST":
            return "sun.max.fill"
        default:
            return "bell.fill"
        }
    }

    private func colorName(for categoryIdentifier: String) -> String {
        switch categoryIdentifier {
        case "BREAKING_NEWS":
            return "red"
        case "DAILY_DIGEST":
            return "orange"
        default:
            return "blue"
        }
    }

    private func nextTriggerDate(for request: UNNotificationRequest) -> Date? {
        if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger {
            return calendarTrigger.nextTriggerDate()
        }

        if let timeIntervalTrigger = request.trigger as? UNTimeIntervalNotificationTrigger {
            return Date().addingTimeInterval(timeIntervalTrigger.timeInterval)
        }

        return nil
    }
}
