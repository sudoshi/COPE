import Foundation
import SwiftUI

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var isRestoring = true
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = false
    @Published private(set) var profile: PatientProfileSummary?
    @Published private(set) var pendingMFAToken: String?
    @Published private(set) var pendingInviteToken: String?
    @Published private(set) var requiredConsentsSatisfied: Bool?
    @Published private(set) var grantedRequiredConsentTypes: Set<PatientConsentType> = []
    @Published var errorMessage: String?

    let apiClient: APIClient

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
                await refreshRequiredConsentStatus()
            }
        } catch {
            try? await apiClient.logout()
            isAuthenticated = false
            profile = nil
            requiredConsentsSatisfied = nil
            grantedRequiredConsentTypes = []
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
            let result = try await apiClient.login(email: trimmedEmail, password: password)
            try await completeAuthentication(result)
        } catch {
            isAuthenticated = false
            profile = nil
            errorMessage = Self.message(for: error)
        }

        isLoading = false
    }

    func register(_ registration: PatientRegistration) async {
        guard !registration.inviteToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Enter your invite code."
            return
        }

        guard !registration.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !registration.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !registration.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !registration.dateOfBirth.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !registration.password.isEmpty else {
            errorMessage = "Complete every required registration field."
            return
        }

        guard registration.password.count >= 12 else {
            errorMessage = "Use a password with at least 12 characters."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await apiClient.register(registration)
            pendingInviteToken = nil
            try await completeAuthentication(result)
        } catch {
            isAuthenticated = false
            profile = nil
            errorMessage = Self.message(for: error)
        }

        isLoading = false
    }

    func verifyMFA(code: String) async {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedCode.count == 6, trimmedCode.allSatisfy(\.isNumber) else {
            errorMessage = "Enter the 6-digit verification code."
            return
        }

        guard let pendingMFAToken else {
            errorMessage = "Start sign-in again to request a verification code."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let session = try await apiClient.verifyMFA(code: trimmedCode, partialToken: pendingMFAToken)
            try await completePatientSession(session)
        } catch {
            isAuthenticated = false
            profile = nil
            errorMessage = Self.message(for: error)
        }

        isLoading = false
    }

    func cancelMFA() {
        pendingMFAToken = nil
        errorMessage = nil
    }

    func completeIntake(
        primaryConcern: String,
        emergencyContactName: String,
        emergencyContactPhone: String,
        emergencyContactRelationship: String,
        addMedication: Bool = false,
        medicationName: String = "",
        medicationDose: String = "",
        medicationDoseUnit: String = "mg",
        medicationFrequency: MedicationFrequencyOption = .onceDailyMorning,
        medicationFrequencyOther: String = "",
        medicationInstructions: String = "",
        selectedSymptomIDs: Set<UUID> = [],
        selectedTriggerIDs: Set<UUID> = [],
        selectedStrategyIDs: Set<UUID> = [],
        dailyReminderEnabled: Bool = true,
        medicationReminderEnabled: Bool = true
    ) async {
        let trimmedConcern = primaryConcern.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedConcern.isEmpty else {
            errorMessage = "Describe your primary concern before continuing."
            return
        }

        let medicationDraft: MedicationSetupDraft?
        if addMedication {
            let trimmedMedicationName = medicationName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedMedicationName.isEmpty else {
                errorMessage = APIClientError.missingMedicationName.localizedDescription
                return
            }

            let trimmedDose = medicationDose.trimmingCharacters(in: .whitespacesAndNewlines)
            let dose: Double?
            if trimmedDose.isEmpty {
                dose = nil
            } else if let parsedDose = Double(trimmedDose), parsedDose > 0 {
                dose = parsedDose
            } else {
                errorMessage = APIClientError.invalidMedicationDose.localizedDescription
                return
            }

            let trimmedFrequencyOther = medicationFrequencyOther.trimmingCharacters(in: .whitespacesAndNewlines)
            guard medicationFrequency != .other || !trimmedFrequencyOther.isEmpty else {
                errorMessage = APIClientError.missingMedicationFrequencyDetail.localizedDescription
                return
            }

            medicationDraft = MedicationSetupDraft(
                medicationName: trimmedMedicationName,
                dose: dose,
                doseUnit: medicationDoseUnit.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "mg",
                frequency: medicationFrequency,
                frequencyOther: trimmedFrequencyOther.nilIfEmpty,
                instructions: medicationInstructions.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            )
        } else {
            medicationDraft = nil
        }

        isLoading = true
        errorMessage = nil

        do {
            if let medicationDraft {
                try await apiClient.createMedication(medicationDraft)
            }

            for id in selectedSymptomIDs.sorted(by: { $0.uuidString < $1.uuidString }) {
                try await apiClient.addTrackedSymptom(id: id)
            }

            for id in selectedTriggerIDs.sorted(by: { $0.uuidString < $1.uuidString }) {
                try await apiClient.addTrackedTrigger(id: id)
            }

            for id in selectedStrategyIDs.sorted(by: { $0.uuidString < $1.uuidString }) {
                try await apiClient.addTrackedStrategy(id: id)
            }

            _ = try await apiClient.updateNotificationPreferences(
                NotificationPreferenceUpdate(
                    dailyReminderEnabled: dailyReminderEnabled,
                    dailyReminderTime: nil,
                    medicationReminderEnabled: medicationReminderEnabled,
                    streakNotifications: nil,
                    appointmentReminders: nil,
                    pushToken: nil
                )
            )

            profile = try await apiClient.updateIntake(
                PatientIntakeUpdate(
                    primaryConcern: trimmedConcern,
                    emergencyContactName: emergencyContactName.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                    emergencyContactPhone: emergencyContactPhone.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                    emergencyContactRelationship: emergencyContactRelationship.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                    markComplete: true
                )
            )
        } catch {
            errorMessage = Self.message(for: error)
        }

        isLoading = false
    }

    func refreshRequiredConsentStatus() async {
        errorMessage = nil

        do {
            let records = try await apiClient.consentRecords()
            let grantedTypes = Set(
                records.compactMap { record -> PatientConsentType? in
                    guard record.granted else {
                        return nil
                    }
                    return record.type
                }
            )

            grantedRequiredConsentTypes = grantedTypes.intersection(PatientConsentType.requiredOnboardingConsents)
            requiredConsentsSatisfied = PatientConsentType.requiredOnboardingConsents.allSatisfy {
                grantedTypes.contains($0)
            }
        } catch {
            requiredConsentsSatisfied = false
            grantedRequiredConsentTypes = []
            errorMessage = Self.message(for: error)
        }
    }

    func grantRequiredConsents(acceptedTypes: Set<PatientConsentType>) async {
        let requiredTypes = Set(PatientConsentType.requiredOnboardingConsents)
        guard requiredTypes.isSubset(of: acceptedTypes) else {
            errorMessage = "Accept the required consent items to continue."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            for type in PatientConsentType.requiredOnboardingConsents where !grantedRequiredConsentTypes.contains(type) {
                try await apiClient.updateConsent(type: type, granted: true)
            }
            await refreshRequiredConsentStatus()
        } catch {
            errorMessage = Self.message(for: error)
        }

        isLoading = false
    }

    func handleOpenURL(_ url: URL) {
        guard url.scheme?.lowercased() == "cope" else {
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        let isInviteURL = components.host?.lowercased() == "invite" ||
            components.path.lowercased().contains("invite")
        guard isInviteURL else {
            return
        }

        let token = components.queryItems?
            .first(where: { $0.name == "token" || $0.name == "invite_token" })?
            .value?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let token, !token.isEmpty {
            pendingInviteToken = token
        }
    }

    func refreshProfile() async throws {
        errorMessage = nil
        profile = try await apiClient.currentPatient()
    }

    func signOut() async {
        try? await apiClient.logout()
        isAuthenticated = false
        profile = nil
        pendingMFAToken = nil
        requiredConsentsSatisfied = nil
        grantedRequiredConsentTypes = []
        errorMessage = nil
    }

    private func completeAuthentication(_ result: AuthFlowResult) async throws {
        switch result {
        case let .authenticated(session):
            try await completePatientSession(session)
        case let .mfaRequired(partialToken):
            isAuthenticated = false
            profile = nil
            pendingMFAToken = partialToken
        }
    }

    private func completePatientSession(_ session: AuthSession) async throws {
        guard session.role == "patient" else {
            try? await apiClient.logout()
            throw APIClientError.patientRoleRequired
        }

        pendingMFAToken = nil
        isAuthenticated = true
        try await refreshProfile()
        await refreshRequiredConsentStatus()
    }

    static func message(for error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }
        return "The request could not be completed."
    }
}
