import Foundation
import UserNotifications
import XCTest
@testable import COPE

@MainActor
final class CareViewModelTests: XCTestCase {
    func testLoadCachesSafetyResourcesFromNetwork() async throws {
        let harness = try makeHarness()
        let response = makeResourcesResponse(
            name: "988 Suicide and Crisis Lifeline",
            disclaimer: "Call 911 for immediate danger."
        )
        let api = MockCareAPI(safetyResourcesResponse: response)
        let notificationService = MockNotificationRegistrationService()
        let model = CareViewModel(
            apiClient: api,
            notificationService: notificationService,
            safetyResourceCache: harness.cache
        )

        await model.load()

        let cachedRecord = try await harness.cache.loadResources()
        let cached = try XCTUnwrap(cachedRecord)
        let safetyResourceRequestCount = await api.safetyResourceRequestCount()

        XCTAssertEqual(model.safetyResources, response.resources)
        XCTAssertEqual(model.safetyDisclaimer, response.disclaimer)
        XCTAssertNil(model.safetyResourceCacheMessage)
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(cached.response, response)
        XCTAssertEqual(safetyResourceRequestCount, 1)
        XCTAssertEqual(notificationService.refreshCount, 1)
    }

    func testLoadRestoresCachedSafetyResourcesWhenNetworkUnavailable() async throws {
        let harness = try makeHarness()
        let cachedResponse = makeResourcesResponse(
            name: "Local Crisis Line",
            disclaimer: "Saved resources may be out of date."
        )
        try await harness.cache.saveResources(cachedResponse)

        let api = MockCareAPI(
            safetyResourcesResponse: nil,
            safetyResourcesError: APIClientError.serverMessage("offline")
        )
        let notificationService = MockNotificationRegistrationService()
        let model = CareViewModel(
            apiClient: api,
            notificationService: notificationService,
            safetyResourceCache: harness.cache
        )

        await model.load()

        let safetyResourceRequestCount = await api.safetyResourceRequestCount()

        XCTAssertEqual(model.safetyResources, cachedResponse.resources)
        XCTAssertEqual(model.safetyDisclaimer, cachedResponse.disclaimer)
        XCTAssertEqual(model.safetyResourceCacheMessage, "Network unavailable. Showing saved crisis resources.")
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(safetyResourceRequestCount, 1)
    }

    private struct Harness {
        let cache: SafetyResourceCacheStore
    }

    private func makeHarness(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Harness {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("COPECareViewModelTests-\(UUID().uuidString)", isDirectory: true)
        let keyStore = LocalEncryptionKeyStore(
            service: "com.cope.tests.care-view-model.\(UUID().uuidString)",
            account: "test-key"
        )
        let secureStore = EncryptedLocalFileStore(keyStore: keyStore)

        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: root)
            try? keyStore.deleteKey()
        }

        return Harness(
            cache: SafetyResourceCacheStore(
                secureStore: secureStore,
                baseDirectory: root
            )
        )
    }

    private func makeResourcesResponse(
        name: String,
        disclaimer: String?
    ) -> SafetyResourcesResponse {
        SafetyResourcesResponse(
            resources: [
                SafetyResource(
                    id: "crisis-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))",
                    name: name,
                    phone: "988",
                    textTo: "988",
                    textKeyword: nil,
                    url: "https://988lifeline.org",
                    description: "Immediate crisis support.",
                    available247: true,
                    type: "crisis"
                )
            ],
            disclaimer: disclaimer
        )
    }
}

private actor MockCareAPI: CareAPIProviding {
    private let safetyResourcesResponse: SafetyResourcesResponse?
    private let safetyResourcesError: Error?
    private let safetyPlanResponse: SafetyPlanResponse?
    private let notificationPreferencesResponse: NotificationPreferences
    private var safetyResourceRequests = 0

    init(
        safetyResourcesResponse: SafetyResourcesResponse?,
        safetyResourcesError: Error? = nil,
        safetyPlanResponse: SafetyPlanResponse? = nil,
        notificationPreferencesResponse: NotificationPreferences = NotificationPreferences(
            id: nil,
            dailyReminderEnabled: true,
            dailyReminderTime: "09:00",
            medicationReminderEnabled: true,
            streakNotifications: true,
            appointmentReminders: true,
            pushToken: nil,
            updatedAt: nil
        )
    ) {
        self.safetyResourcesResponse = safetyResourcesResponse
        self.safetyResourcesError = safetyResourcesError
        self.safetyPlanResponse = safetyPlanResponse
        self.notificationPreferencesResponse = notificationPreferencesResponse
    }

    func safetyResourceRequestCount() -> Int {
        safetyResourceRequests
    }

    func consentRecords() async throws -> [ConsentRecord] {
        []
    }

    func updateConsent(type: PatientConsentType, granted: Bool) async throws {}

    func safetyResources() async throws -> SafetyResourcesResponse {
        safetyResourceRequests += 1

        if let safetyResourcesError {
            throw safetyResourcesError
        }

        return safetyResourcesResponse ?? SafetyResourcesResponse(resources: [], disclaimer: nil)
    }

    func mySafetyPlan() async throws -> SafetyPlanResponse? {
        safetyPlanResponse
    }

    func notificationPreferences() async throws -> NotificationPreferences {
        notificationPreferencesResponse
    }

    func updateNotificationPreferences(_ update: NotificationPreferenceUpdate) async throws -> NotificationPreferences {
        notificationPreferencesResponse
    }

    func registerPushToken(_ token: String) async throws -> PushTokenRegistration {
        PushTokenRegistration(pushToken: token, updatedAt: nil)
    }
}

@MainActor
private final class MockNotificationRegistrationService: NotificationRegistrationProviding {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var deviceToken: String?
    var registrationError: String?
    private(set) var refreshCount = 0
    private(set) var requestAuthorizationCount = 0
    private(set) var registerForRemoteNotificationsCount = 0

    func refreshAuthorizationStatus() async {
        refreshCount += 1
    }

    func requestAuthorization() async -> Bool {
        requestAuthorizationCount += 1
        authorizationStatus = .authorized
        return true
    }

    func registerForRemoteNotifications() {
        registerForRemoteNotificationsCount += 1
    }
}
