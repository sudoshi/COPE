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

        return try Self.decodePatientProfile(from: response)
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
        if case let ErrorResponse.error(status, _, _, _) = error {
            return status == 401
        }
        return false
    }

    private static func decodePatientProfile(from response: ApiV1PatientsMeGet200Response) throws -> PatientProfileSummary {
        struct Envelope: Decodable {
            let data: PatientProfileSummary
        }

        let encoded = try JSONEncoder().encode(response)
        return try JSONDecoder().decode(Envelope.self, from: encoded).data
    }
}

enum APIClientError: Error, LocalizedError {
    case mfaRequired
    case missingSession
    case patientRoleRequired

    var errorDescription: String? {
        switch self {
        case .mfaRequired:
            return "This account requires multi-factor verification before mobile sign-in can continue."
        case .missingSession:
            return "Sign in again to continue."
        case .patientRoleRequired:
            return "The iOS app currently supports patient accounts only."
        }
    }
}
