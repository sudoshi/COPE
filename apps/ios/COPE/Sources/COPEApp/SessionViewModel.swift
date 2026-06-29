import Foundation
import SwiftUI

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var isRestoring = true
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = false
    @Published private(set) var profile: PatientProfileSummary?
    @Published var errorMessage: String?

    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func restoreSession() async {
        isRestoring = true
        errorMessage = nil

        do {
            let hasSession = try await apiClient.restoreSession()
            isAuthenticated = hasSession

            if hasSession {
                try await refreshProfile()
            }
        } catch {
            try? await apiClient.logout()
            isAuthenticated = false
            profile = nil
        }

        isRestoring = false
    }

    func signIn(email: String, password: String) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Enter your email and password."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let session = try await apiClient.login(email: trimmedEmail, password: password)
            guard session.role == "patient" else {
                try? await apiClient.logout()
                throw APIClientError.patientRoleRequired
            }

            isAuthenticated = true
            try await refreshProfile()
        } catch {
            isAuthenticated = false
            profile = nil
            errorMessage = Self.message(for: error)
        }

        isLoading = false
    }

    func refreshProfile() async throws {
        errorMessage = nil
        profile = try await apiClient.currentPatient()
    }

    func signOut() async {
        try? await apiClient.logout()
        isAuthenticated = false
        profile = nil
        errorMessage = nil
    }

    private static func message(for error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }
        return "The request could not be completed."
    }
}
