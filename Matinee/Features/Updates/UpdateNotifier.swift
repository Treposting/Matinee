import Foundation
@preconcurrency import UserNotifications

/// Posts the "new version available" notification. Notification permission is requested the
/// first time an update is found, not at launch.
@MainActor
final class UpdateNotifier: NSObject, UNUserNotificationCenterDelegate {
    private nonisolated static let identifier = "com.nahid.matinee.update-available"

    var onOpen: () -> Void = {}

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func notifyUpdateAvailable(version: String) async {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "Matinee \(version) is available"
        content.body = "Click to update. Matinee will quit, install the new version and reopen."
        content.sound = .default

        let request = UNNotificationRequest(identifier: Self.identifier, content: content, trigger: nil)
        try? await center.add(request)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard response.notification.request.identifier == Self.identifier else { return }
        await MainActor.run { self.onOpen() }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
