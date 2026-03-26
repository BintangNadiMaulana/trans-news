//
//  Trans_NewsApp.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct Trans_NewsApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("appColorScheme") private var appColorScheme = "system"
    @AppStorage("dailyDigestEnabled") private var dailyDigestEnabled = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        if ProcessInfo.processInfo.arguments.contains("UITEST_SKIP_ONBOARDING") {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        }

        SharedAppStorage.syncSelectedLanguage(
            UserDefaults.standard.string(forKey: SharedAppStorage.selectedLanguageKey) ?? "id"
        )
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            NewsArticle.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private var colorScheme: ColorScheme? {
        switch appColorScheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    ContentView()
                } else {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                }
            }
            .preferredColorScheme(colorScheme)
            .task {
                await NotificationService.shared.checkAuthorizationStatus()
                NotificationService.shared.setupNotificationCategories()
                NotificationService.shared.clearBadge()
                if dailyDigestEnabled, NotificationService.shared.isAuthorized {
                    NotificationService.shared.scheduleDailyDigest()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - App Delegate for Push Notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs token: \(token)")
    }
    
    // Tampilkan notifikasi saat app di foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }
    
    // Handle tap pada notifikasi
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        if let articleId = userInfo["articleId"] as? String,
           let title = userInfo["title"] as? String,
           let sourceName = userInfo["sourceName"] as? String,
           let url = userInfo["url"] as? String,
           let publishedAt = userInfo["publishedAt"] as? String,
           let category = userInfo["category"] as? String {
            AppNavigationState.shared.pendingNotificationArticle = NotificationArticlePayload(
                id: articleId,
                title: title,
                articleDescription: (userInfo["articleDescription"] as? String).flatMap { $0.isEmpty ? nil : $0 },
                content: (userInfo["content"] as? String).flatMap { $0.isEmpty ? nil : $0 },
                author: (userInfo["author"] as? String).flatMap { $0.isEmpty ? nil : $0 },
                sourceName: sourceName,
                url: url,
                imageURL: (userInfo["imageURL"] as? String).flatMap { $0.isEmpty ? nil : $0 },
                publishedAtISO8601: publishedAt,
                category: category
            )
        }
        
        NotificationService.shared.clearBadge()
        await NotificationService.shared.refreshNotificationBadgeCount()
    }
}
