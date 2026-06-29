import Foundation
@preconcurrency import COPEOpenAPI

struct AuthSession: Equatable {
    let userID: UUID
    let email: String
    let role: String
    let organizationID: UUID
    let patientID: UUID?
}

struct PatientProfileSummary: Decodable, Equatable {
    let id: String
    let firstName: String
    let lastName: String
    let preferredName: String?
    let email: String?
    let status: String
    let riskLevel: String
    let trackingStreak: Int
    let longestStreak: Int
    let lastCheckinAt: String?
    let timezone: String
    let onboardingComplete: Bool
    let role: String

    var displayName: String {
        if let preferredName, !preferredName.isEmpty {
            return preferredName
        }
        return "\(firstName) \(lastName)"
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case preferredName = "preferred_name"
        case email
        case status
        case riskLevel = "risk_level"
        case trackingStreak = "tracking_streak"
        case longestStreak = "longest_streak"
        case lastCheckinAt = "last_checkin_at"
        case timezone
        case onboardingComplete = "onboarding_complete"
        case role
    }
}

struct DailyEntrySummary: Decodable, Equatable, Identifiable {
    let id: String
    let entryDate: String
    let mood: Int?
    let submittedAt: String?
    let completionPct: Int?
    let coreComplete: Bool?
    let wellnessComplete: Bool?
    let triggersComplete: Bool?
    let symptomsComplete: Bool?
    let journalComplete: Bool?

    var isSubmitted: Bool {
        submittedAt != nil
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case entryDate = "entry_date"
        case mood
        case submittedAt = "submitted_at"
        case completionPct = "completion_pct"
        case coreComplete = "core_complete"
        case wellnessComplete = "wellness_complete"
        case triggersComplete = "triggers_complete"
        case symptomsComplete = "symptoms_complete"
        case journalComplete = "journal_complete"
    }
}

struct DailyEntryWriteResult: Decodable, Equatable {
    let id: String
    let entryDate: String

    private enum CodingKeys: String, CodingKey {
        case id
        case entryDate = "entry_date"
    }
}

struct DailyEntrySubmitResult: Decodable, Equatable {
    let id: String
    let submittedAt: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case submittedAt = "submitted_at"
    }
}

struct DailyEntryDraft: Equatable {
    let entryDate: String
    let moodScore: Int
    let sleepHours: Double?
    let anxietyScore: Int?
    let stressScore: Int?
    let suicidalIdeation: Int?
    let notes: String?
}

struct PendingAssessment: Decodable, Equatable, Identifiable {
    let scale: String
    let daysOverdue: Int
    let intervalDays: Int

    var id: String { scale }

    private enum CodingKeys: String, CodingKey {
        case scale
        case daysOverdue = "days_overdue"
        case intervalDays = "interval_days"
    }
}

struct AssessmentSubmissionResult: Decodable, Equatable, Identifiable {
    let id: String
    let scale: String
    let score: Int
    let completedAt: String
    let loincCode: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case scale
        case score
        case completedAt = "completed_at"
        case loincCode = "loinc_code"
    }
}

private struct APIResponseDataEnvelope<Value: Decodable>: Decodable {
    let data: Value
}

actor APIClient {
    private let configuration: AppConfiguration
    private let tokenStore: TokenStore

    init(
        configuration: AppConfiguration = .current,
        tokenStore: TokenStore = KeychainTokenStore()
    ) {
        self.configuration = configuration
        self.tokenStore = tokenStore
        COPEOpenAPIAPI.basePath = configuration.apiBaseURL.absoluteString
        COPEOpenAPIAPI.apiResponseQueue = DispatchQueue(label: "app.cope.openapi.response")
    }

    func restoreSession() throws -> Bool {
        guard let tokens = try tokenStore.loadTokens() else {
            clearAuthorizationHeader()
            return false
        }

        applyAuthorizationHeader(accessToken: tokens.accessToken)
        return true
    }

    func login(email: String, password: String) async throws -> AuthSession {
        clearAuthorizationHeader()

        let request = ApiV1AuthLoginPostRequest(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )
        let response = try await AuthAPI.apiV1AuthLoginPost(apiV1AuthLoginPostRequest: request)
        let data = response.data

        if data.mfaRequired == true {
            throw APIClientError.mfaRequired
        }

        let tokens = AuthTokens(accessToken: data.accessToken, refreshToken: data.refreshToken)
        try tokenStore.saveTokens(tokens)
        applyAuthorizationHeader(accessToken: tokens.accessToken)

        return AuthSession(
            userID: data.user.id,
            email: data.user.email,
            role: data.user.role,
            organizationID: data.user.orgId,
            patientID: data.patientId
        )
    }

    func currentPatient() async throws -> PatientProfileSummary {
        let response = try await executeAuthorized {
            try await PatientsAPI.apiV1PatientsMeGet()
        }

        return try Self.decodeData(from: response, as: PatientProfileSummary.self)
    }

    func todayDailyEntry() async throws -> DailyEntrySummary? {
        do {
            let response = try await executeAuthorized {
                try await DailyEntriesAPI.apiV1DailyEntriesTodayGet()
            }
            return try Self.decodeData(from: response, as: DailyEntrySummary.self)
        } catch {
            if isStatus(error, 404) {
                return nil
            }
            throw error
        }
    }

    func saveDailyEntry(_ draft: DailyEntryDraft) async throws -> DailyEntryWriteResult {
        let request = ApiV1DailyEntriesPostRequest(
            entryDate: draft.entryDate,
            moodScore: draft.moodScore,
            sleepHours: draft.sleepHours,
            notes: draft.notes,
            anxietyScore: draft.anxietyScore,
            suicidalIdeation: draft.suicidalIdeation,
            stressScore: draft.stressScore
        )

        let response = try await executeAuthorized {
            try await DailyEntriesAPI.apiV1DailyEntriesPost(apiV1DailyEntriesPostRequest: request)
        }

        return try Self.decodeData(from: response, as: DailyEntryWriteResult.self)
    }

    func submitDailyEntry(id: String) async throws -> DailyEntrySubmitResult {
        guard let uuid = UUID(uuidString: id) else {
            throw APIClientError.invalidIdentifier
        }

        let response = try await executeAuthorized {
            try await DailyEntriesAPI.apiV1DailyEntriesIdSubmitPatch(id: uuid)
        }

        return try Self.decodeData(from: response, as: DailyEntrySubmitResult.self)
    }

    func pendingAssessments() async throws -> [PendingAssessment] {
        let response = try await executeAuthorized {
            try await AssessmentsAPI.apiV1AssessmentsPendingGet()
        }

        return try Self.decodeData(from: response, as: [PendingAssessment].self)
    }

    func submitAssessment(scale: String, score: Int, itemResponses: [String: Int], notes: String?) async throws -> AssessmentSubmissionResult {
        guard let apiScale = ApiV1AssessmentsPostRequest.Scale(rawValue: scale) else {
            throw APIClientError.unsupportedAssessmentScale
        }

        let request = ApiV1AssessmentsPostRequest(
            scale: apiScale,
            score: score,
            itemResponses: itemResponses,
            notes: notes
        )

        let response = try await executeAuthorized {
            try await AssessmentsAPI.apiV1AssessmentsPost(apiV1AssessmentsPostRequest: request)
        }

        return try Self.decodeData(from: response, as: AssessmentSubmissionResult.self)
    }

    func logout() throws {
        clearAuthorizationHeader()
        try tokenStore.deleteTokens()
    }

    private func executeAuthorized<T>(_ operation: () async throws -> T) async throws -> T {
        guard let tokens = try tokenStore.loadTokens() else {
            throw APIClientError.missingSession
        }

        applyAuthorizationHeader(accessToken: tokens.accessToken)

        do {
            return try await operation()
        } catch {
            guard isUnauthorized(error), let refreshToken = tokens.refreshToken else {
                throw error
            }

            let refreshed = try await refreshTokens(refreshToken: refreshToken)
            applyAuthorizationHeader(accessToken: refreshed.accessToken)
            return try await operation()
        }
    }

    private func refreshTokens(refreshToken: String) async throws -> AuthTokens {
        clearAuthorizationHeader()

        let request = ApiV1AuthRefreshPostRequest(refreshToken: refreshToken)
        let response = try await AuthAPI.apiV1AuthRefreshPost(apiV1AuthRefreshPostRequest: request)
        let data = response.data
        let tokens = AuthTokens(accessToken: data.accessToken, refreshToken: data.refreshToken ?? refreshToken)

        try tokenStore.saveTokens(tokens)
        return tokens
    }

    private func applyAuthorizationHeader(accessToken: String) {
        COPEOpenAPIAPI.customHeaders["Authorization"] = "Bearer \(accessToken)"
    }

    private func clearAuthorizationHeader() {
        COPEOpenAPIAPI.customHeaders.removeValue(forKey: "Authorization")
    }

    private func isUnauthorized(_ error: Error) -> Bool {
        isStatus(error, 401)
    }

    private func isStatus(_ error: Error, _ statusCode: Int) -> Bool {
        guard case let ErrorResponse.error(status, _, _, _) = error else {
            return false
        }
        return status == statusCode
    }

    private static func decodeData<T: Decodable>(from response: ApiV1PatientsMeGet200Response, as type: T.Type) throws -> T {
        let encoded = try JSONEncoder().encode(response)
        return try JSONDecoder().decode(APIResponseDataEnvelope<T>.self, from: encoded).data
    }
}

enum APIClientError: Error, LocalizedError {
    case mfaRequired
    case missingSession
    case patientRoleRequired
    case invalidIdentifier
    case unsupportedAssessmentScale

    var errorDescription: String? {
        switch self {
        case .mfaRequired:
            return "This account requires multi-factor verification before mobile sign-in can continue."
        case .missingSession:
            return "Sign in again to continue."
        case .patientRoleRequired:
            return "The iOS app currently supports patient accounts only."
        case .invalidIdentifier:
            return "The selected record is no longer valid."
        case .unsupportedAssessmentScale:
            return "This assessment is not supported by the mobile contract yet."
        }
    }
}
