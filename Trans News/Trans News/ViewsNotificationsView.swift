//
//  NotificationsView.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [AppNotification] = []
    @State private var isLoading = false

    private var deliveredNotifications: [AppNotification] {
        notifications.filter(\.isDelivered)
    }

    private var scheduledNotifications: [AppNotification] {
        notifications.filter { !$0.isDelivered }
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Memuat notifikasi...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if notifications.isEmpty {
                emptyStateView
            } else {
                List {
                    if !deliveredNotifications.isEmpty {
                        Section(L10n.tr("notifications.inbox", fallback: "Masuk")) {
                            ForEach(deliveredNotifications) { notification in
                                notificationRow(notification)
                            }
                        }
                    }

                    if !scheduledNotifications.isEmpty {
                        Section(L10n.tr("notifications.scheduled", fallback: "Terjadwal")) {
                            ForEach(scheduledNotifications) { notification in
                                notificationRow(notification)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(L10n.tr("notifications.title", fallback: "Notifikasi"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !notifications.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.tr("notifications.clearAll", fallback: "Hapus Semua")) {
                        NotificationService.shared.removeAllNotifications()
                        NotificationService.shared.notificationBadgeCount = 0
                        notifications = []
                    }
                    .foregroundStyle(Color.transNewsOrange)
                }
            }
        }
        .task {
            await loadNotifications()
        }
        .refreshable {
            await loadNotifications()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 50))
                .foregroundStyle(.gray.opacity(0.5))
            Text(L10n.tr("notifications.emptyTitle", fallback: "Belum Ada Notifikasi"))
                .font(.title3)
                .fontWeight(.semibold)
            Text(L10n.tr("notifications.emptySubtitle", fallback: "Notifikasi breaking news atau rangkuman harian akan muncul di sini."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func notificationRow(_ notification: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: notification.icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(color(for: notification.colorName))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(notification.time.timeAgoDisplay())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(notification.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 4)
    }

    private func loadNotifications() async {
        isLoading = true
        notifications = await NotificationService.shared.fetchNotifications()
        await NotificationService.shared.refreshNotificationBadgeCount()
        isLoading = false
    }

    private func color(for colorName: String) -> Color {
        switch colorName {
        case "red":
            return .red
        case "orange":
            return .transNewsOrange
        default:
            return .transNewsBlue
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
