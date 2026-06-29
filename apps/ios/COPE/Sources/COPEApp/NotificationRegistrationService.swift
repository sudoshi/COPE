import Foundation
import UIKit
import UserNotifications

extension Notification.Name {
    static let copeRemoteNotificationTokenDidChange = Notification.Name("app.cope.remoteNotificationTokenDidChange")
}

@MainActor
final class NotificationRegistrationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationRegistrationService()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var deviceToken: String?
    @Published private(set) var registrationError: String?

    private override init() {
        super.init()
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            registrationError = "Notification permission could not be requested."
            return false
        }
    }

    func registerForRemoteNotifications() {
        registrationError = nil
        UIApplication.shared.registerForRemoteNotifications()
    }

    func handleDeviceToken(_ tokenData: Data) {
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        deviceToken = token
        registrationError = nil
        NotificationCenter.default.post(name: .copeRemoteNotificationTokenDidChange, object: token)
    }

    func handleRegistrationError(_ error: Error) {
        registrationError = error.localizedDescription
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Task { @MainActor in
            UNUserNotificationCenter.current().delegate = NotificationRegistrationService.shared
        }
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            NotificationRegistrationService.shared.handleDeviceToken(deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task { @MainActor in
            NotificationRegistrationService.shared.handleRegistrationError(error)
        }
    }
}
