import Foundation
@preconcurrency import COPEOpenAPI

struct AuthSession: Equatable {
    let userID: UUID
    let email: String
    let role: String
    let organizationID: UUID
    let patientID: UUID?
}

enum AuthFlowResult: Equatable {
    case authenticated(AuthSession)
    case mfaRequired(partialToken: String)
}

struct PatientRegistration: Equatable {
    let inviteToken: String
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let dateOfBirth: String
    let timezone: String
}

struct PatientIntakeUpdate: Equatable {
    let primaryConcern: String?
    let emergencyContactName: String?
    let emergencyContactPhone: String?
    let emergencyContactRelationship: String?
    let markComplete: Bool
}

enum MedicationFrequencyOption: String, CaseIterable, Identifiable {
    case onceDailyMorning = "once_daily_morning"
    case onceDailyEvening = "once_daily_evening"
    case onceDailyBedtime = "once_daily_bedtime"
    case twiceDaily = "twice_daily"
    case threeTimesDaily = "three_times_daily"
    case asNeeded = "as_needed"
    case weekly = "weekly"
    case other = "other"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .onceDailyMorning:
            return "Morning"
        case .onceDailyEvening:
            return "Evening"
        case .onceDailyBedtime:
            return "Bedtime"
        case .twiceDaily:
            return "Twice daily"
        case .threeTimesDaily:
            return "Three times daily"
        case .asNeeded:
            return "As needed"
        case .weekly:
            return "Weekly"
        case .other:
            return "Other"
        }
    }

    var apiValue: ApiV1MedicationsPostRequest.Frequency {
        switch self {
        case .onceDailyMorning:
            return .onceDailyMorning
        case .onceDailyEvening:
            return .onceDailyEvening
        case .onceDailyBedtime:
            return .onceDailyBedtime
        case .twiceDaily:
            return .twiceDaily
        case .threeTimesDaily:
            return .threeTimesDaily
        case .asNeeded:
            return .asNeeded
        case .weekly:
            return .weekly
        case .other:
            return .other
        }
    }
}

struct MedicationSetupDraft: Equatable {
    let medicationName: String
    let dose: Double?
    let doseUnit: String?
    let frequency: MedicationFrequencyOption
    let frequencyOther: String?
    let instructions: String?
}

struct OnboardingCatalogueItem: Equatable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let category: String?
    let isSafetySymptom: Bool
    let hasQualityRating: Bool
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

struct DailyEntryDraft: Codable, Equatable {
    let entryDate: String
    let moodScore: Int
    let sleepHours: Double?
    let anxietyScore: Int?
    let stressScore: Int?
    let suicidalIdeation: Int?
    let notes: String?

    private enum CodingKeys: String, CodingKey {
        case entryDate = "entry_date"
        case moodScore = "mood_score"
        case sleepHours = "sleep_hours"
        case anxietyScore = "anxiety_score"
        case stressScore = "stress_score"
        case suicidalIdeation = "suicidal_ideation"
        case notes
    }
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

enum PatientConsentType: String, CaseIterable, Identifiable {
    case shareWithClinician = "share_with_clinician"
    case shareJournalWithClinician = "share_journal_with_clinician"
    case researchParticipation = "research_participation"
    case dataExport = "data_export"
    case termsOfService = "terms_of_service"
    case privacyPolicy = "privacy_policy"
    case journalSharing = "journal_sharing"
    case dataResearch = "data_research"
    case aiInsights = "ai_insights"
    case emergencyContact = "emergency_contact"
    case pushNotifications = "push_notifications"

    var id: String { rawValue }
}

struct ConsentRecord: Equatable, Identifiable {
    let id: UUID
    let type: PatientConsentType?
    let rawType: String
    let granted: Bool
    let grantedAt: Date
    let expiresAt: Date?
    let revokedAt: Date?

    init(response: ApiV1ConsentGet200ResponseDataInner) {
        id = response.id
        rawType = response.consentType.rawValue
        type = PatientConsentType(rawValue: response.consentType.rawValue)
        granted = response.granted
        grantedAt = response.grantedAt
        expiresAt = response.expiresAt
        revokedAt = response.revokedAt
    }
}

struct SafetyResource: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let phone: String?
    let textTo: String?
    let textKeyword: String?
    let url: String?
    let description: String?
    let available247: Bool
    let type: String

    var urlValue: URL? {
        guard let url else { return nil }
        return URL(string: url)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case textTo = "text_to"
        case textKeyword = "text_keyword"
        case url
        case description
        case available247 = "available_24_7"
        case type
    }
}

struct SafetyResourcesResponse: Codable, Equatable {
    let resources: [SafetyResource]
    let disclaimer: String?
}

struct SafetyPlanContact: Decodable, Equatable, Hashable {
    let name: String?
    let phone: String?
    let relationship: String?
    let location: String?
    let note: String?

    private enum CodingKeys: String, CodingKey {
        case name
        case phone
        case relationship
        case location
        case note
    }
}

struct SafetyPlan: Decodable, Equatable, Identifiable {
    let id: String
    let warningSigns: [String]
    let internalCopingStrategies: [String]
    let supportContacts: [SafetyPlanContact]
    let socialDistractions: [SafetyPlanContact]
    let crisisLinePhone: String?
    let crisisLineName: String?
    let erAddress: String?
    let emergencySteps: String?
    let reasonsForLiving: [String]
    let patientSignatureAt: String?
    let clinicianSignatureAt: String?
    let updatedAt: String?

    var isAcknowledged: Bool {
        patientSignatureAt != nil
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case warningSigns = "warning_signs"
        case internalCopingStrategies = "internal_coping_strategies"
        case supportContacts = "support_contacts"
        case socialDistractions = "social_distractions"
        case crisisLinePhone = "crisis_line_phone"
        case crisisLineName = "crisis_line_name"
        case erAddress = "er_address"
        case emergencySteps = "emergency_steps"
        case reasonsForLiving = "reasons_for_living"
        case patientSignatureAt = "patient_signature_at"
        case clinicianSignatureAt = "clinician_signature_at"
        case updatedAt = "updated_at"
    }
}

struct SafetyPlanResponse: Decodable, Equatable {
    let plan: SafetyPlan
    let resources: [SafetyResource]
    let disclaimer: String?
}

struct SafetyPlanAcknowledgement: Equatable {
    let signedAt: Date
}

struct NotificationPreferences: Decodable, Equatable {
    let id: String?
    let dailyReminderEnabled: Bool
    let dailyReminderTime: String
    let medicationReminderEnabled: Bool
    let streakNotifications: Bool
    let appointmentReminders: Bool
    let pushToken: String?
    let updatedAt: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case dailyReminderEnabled = "daily_reminder_enabled"
        case dailyReminderTime = "daily_reminder_time"
        case medicationReminderEnabled = "medication_reminder_enabled"
        case streakNotifications = "streak_notifications"
        case appointmentReminders = "appointment_reminders"
        case pushToken = "push_token"
        case updatedAt = "updated_at"
    }
}

struct NotificationPreferenceUpdate: Equatable {
    let dailyReminderEnabled: Bool?
    let dailyReminderTime: String?
    let medicationReminderEnabled: Bool?
    let streakNotifications: Bool?
    let appointmentReminders: Bool?
    let pushToken: String?
}

struct PushTokenRegistration: Decodable, Equatable {
    let pushToken: String?
    let updatedAt: String?

    private enum CodingKeys: String, CodingKey {
        case pushToken = "push_token"
        case updatedAt = "updated_at"
    }
}

private struct APIResponseDataEnvelope<Value: Decodable>: Decodable {
    let data: Value
}

private struct AuthResponseEnvelope: Decodable {
    let success: Bool?
    let data: AuthResponseData?
    let error: AuthResponseError?
}

private struct AuthResponseError: Decodable {
    let code: String?
    let message: String?
}

private struct AuthResponseData: Decodable {
    let accessToken: String?
    let refreshToken: String?
    let patientId: UUID?
    let clinicianId: UUID?
    let orgId: UUID?
    let role: String?
    let mfaRequired: Bool?
    let partialToken: String?
    let mustChangePassword: Bool?
    let user: AuthResponseUser?

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case patientId = "patient_id"
        case clinicianId = "clinician_id"
        case orgId = "org_id"
        case role
        case mfaRequired = "mfa_required"
        case partialToken = "partial_token"
        case mustChangePassword = "must_change_password"
        case user
    }
}

private struct AuthResponseUser: Decodable {
    let id: UUID
    let email: String
    let role: String
    let orgId: UUID

    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case role
        case orgId = "org_id"
    }
}

protocol DailyEntryAPIProviding: Sendable {
    func todayDailyEntry() async throws -> DailyEntrySummary?
    func saveDailyEntry(_ draft: DailyEntryDraft) async throws -> DailyEntryWriteResult
    func submitDailyEntry(id: String) async throws -> DailyEntrySubmitResult
}

protocol CareAPIProviding: Sendable {
    func consentRecords() async throws -> [ConsentRecord]
    func updateConsent(type: PatientConsentType, granted: Bool) async throws
    func safetyResources() async throws -> SafetyResourcesResponse
    func mySafetyPlan() async throws -> SafetyPlanResponse?
    func signMySafetyPlan() async throws -> SafetyPlanAcknowledgement
    func notificationPreferences() async throws -> NotificationPreferences
    func updateNotificationPreferences(_ update: NotificationPreferenceUpdate) async throws -> NotificationPreferences
    func registerPushToken(_ token: String) async throws -> PushTokenRegistration
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

    func login(email: String, password: String) async throws -> AuthFlowResult {
        clearAuthorizationHeader()

        let request = ApiV1AuthLoginPostRequest(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )
        let data = try await performAuthRequest(
            path: "/api/v1/auth/login",
            body: request,
            acceptedStatusCodes: [200]
        )
        return try completeAuthResponse(data)
    }

    func register(_ registration: PatientRegistration) async throws -> AuthFlowResult {
        clearAuthorizationHeader()

        let request = ApiV1AuthRegisterPostRequest(
            inviteToken: registration.inviteToken.trimmingCharacters(in: .whitespacesAndNewlines),
            email: registration.email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: registration.password,
            firstName: registration.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: registration.lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            dateOfBirth: registration.dateOfBirth.trimmingCharacters(in: .whitespacesAndNewlines),
            timezone: registration.timezone
        )
        let data = try await performAuthRequest(
            path: "/api/v1/auth/register",
            body: request,
            acceptedStatusCodes: [201]
        )
        return try completeAuthResponse(data)
    }

    func verifyMFA(code: String, partialToken: String) async throws -> AuthSession {
        clearAuthorizationHeader()

        let request = ApiV1AuthMfaVerifyPostRequest(code: code.trimmingCharacters(in: .whitespacesAndNewlines))
        let data = try await performAuthRequest(
            path: "/api/v1/auth/mfa/verify",
            body: request,
            bearerToken: partialToken,
            acceptedStatusCodes: [200]
        )
        let result = try completeAuthResponse(data)

        guard case let .authenticated(session) = result else {
            throw APIClientError.invalidAuthResponse
        }

        return session
    }

    func currentPatient() async throws -> PatientProfileSummary {
        let response = try await executeAuthorized {
            try await PatientsAPI.apiV1PatientsMeGet()
        }

        return try Self.decodeData(from: response, as: PatientProfileSummary.self)
    }

    func updateIntake(_ update: PatientIntakeUpdate) async throws -> PatientProfileSummary {
        let request = ApiV1PatientsMeIntakePatchRequest(
            primaryConcern: update.primaryConcern,
            emergencyContactName: update.emergencyContactName,
            emergencyContactPhone: update.emergencyContactPhone,
            emergencyContactRelationship: update.emergencyContactRelationship,
            markComplete: update.markComplete
        )

        let response = try await executeAuthorized {
            try await PatientsAPI.apiV1PatientsMeIntakePatch(apiV1PatientsMeIntakePatchRequest: request)
        }

        _ = response
        return try await currentPatient()
    }

    func symptomCatalogue() async throws -> [OnboardingCatalogueItem] {
        let response = try await executeAuthorized {
            try await CataloguesAPI.apiV1CataloguesSymptomsGet()
        }

        return response.data.map {
            OnboardingCatalogueItem(
                id: $0.symptomId,
                name: $0.name,
                category: $0.category,
                isSafetySymptom: $0.isSafetySymptom,
                hasQualityRating: false
            )
        }
    }

    func triggerCatalogue() async throws -> [OnboardingCatalogueItem] {
        let response = try await executeAuthorized {
            try await CataloguesAPI.apiV1CataloguesTriggersGet()
        }

        return response.data.map {
            OnboardingCatalogueItem(
                id: $0.triggerId,
                name: $0.name,
                category: $0.category,
                isSafetySymptom: false,
                hasQualityRating: false
            )
        }
    }

    func strategyCatalogue() async throws -> [OnboardingCatalogueItem] {
        let response = try await executeAuthorized {
            try await CataloguesAPI.apiV1CataloguesStrategiesGet()
        }

        return response.data.map {
            OnboardingCatalogueItem(
                id: $0.strategyId,
                name: $0.name,
                category: $0.category,
                isSafetySymptom: false,
                hasQualityRating: $0.hasQualityRating
            )
        }
    }

    func addTrackedSymptom(id: UUID) async throws {
        let request = ApiV1PatientsMeSymptomsPostRequest(id: id)
        _ = try await executeAuthorized {
            try await PatientsAPI.apiV1PatientsMeSymptomsPost(apiV1PatientsMeSymptomsPostRequest: request)
        }
    }

    func addTrackedTrigger(id: UUID) async throws {
        let request = ApiV1PatientsMeSymptomsPostRequest(id: id)
        _ = try await executeAuthorized {
            try await PatientsAPI.apiV1PatientsMeTriggersPost(apiV1PatientsMeSymptomsPostRequest: request)
        }
    }

    func addTrackedStrategy(id: UUID) async throws {
        let request = ApiV1PatientsMeSymptomsPostRequest(id: id)
        _ = try await executeAuthorized {
            try await PatientsAPI.apiV1PatientsMeStrategiesPost(apiV1PatientsMeSymptomsPostRequest: request)
        }
    }

    func createMedication(_ medication: MedicationSetupDraft) async throws {
        let request = ApiV1MedicationsPostRequest(
            medicationName: medication.medicationName,
            dose: medication.dose,
            doseUnit: medication.doseUnit,
            frequency: medication.frequency.apiValue,
            frequencyOther: medication.frequencyOther,
            instructions: medication.instructions,
            prescribedAt: nil,
            showInApp: true
        )

        _ = try await executeAuthorized {
            try await MedicationsAPI.apiV1MedicationsPost(apiV1MedicationsPostRequest: request)
        }
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

    func consentRecords() async throws -> [ConsentRecord] {
        let response = try await executeAuthorized {
            try await ConsentAPI.apiV1ConsentGet()
        }

        return response.data.map(ConsentRecord.init(response:))
    }

    func updateConsent(type: PatientConsentType, granted: Bool) async throws {
        guard let consentType = ApiV1ConsentPostRequest.ConsentType(rawValue: type.rawValue) else {
            throw APIClientError.unsupportedConsentType
        }

        let request = ApiV1ConsentPostRequest(consentType: consentType, granted: granted)
        _ = try await executeAuthorized {
            try await ConsentAPI.apiV1ConsentPost(apiV1ConsentPostRequest: request)
        }
    }

    func safetyResources() async throws -> SafetyResourcesResponse {
        let response = try await SafetyAPI.apiV1SafetyResourcesGet()
        return try Self.decodeData(from: response, as: SafetyResourcesResponse.self)
    }

    func mySafetyPlan() async throws -> SafetyPlanResponse? {
        do {
            let response = try await executeAuthorized {
                try await SafetyAPI.apiV1SafetyMyPlanGet()
            }
            return try Self.decodeData(from: response, as: SafetyPlanResponse.self)
        } catch {
            if isStatus(error, 404) {
                return nil
            }
            throw error
        }
    }

    func signMySafetyPlan() async throws -> SafetyPlanAcknowledgement {
        let response = try await executeAuthorized {
            try await SafetyAPI.apiV1SafetyMyPlanSignPost()
        }

        return SafetyPlanAcknowledgement(signedAt: response.data.signedAt)
    }

    func notificationPreferences() async throws -> NotificationPreferences {
        let response = try await executeAuthorized {
            try await NotificationsAPI.apiV1NotificationsPrefsGet()
        }

        return try Self.decodeData(from: response, as: NotificationPreferences.self)
    }

    func updateNotificationPreferences(_ update: NotificationPreferenceUpdate) async throws -> NotificationPreferences {
        let request = ApiV1NotificationsPrefsPutRequest(
            dailyReminderEnabled: update.dailyReminderEnabled,
            dailyReminderTime: update.dailyReminderTime,
            medicationReminderEnabled: update.medicationReminderEnabled,
            streakNotifications: update.streakNotifications,
            appointmentReminders: update.appointmentReminders,
            pushToken: update.pushToken
        )

        let response = try await executeAuthorized {
            try await NotificationsAPI.apiV1NotificationsPrefsPut(apiV1NotificationsPrefsPutRequest: request)
        }

        return try Self.decodeData(from: response, as: NotificationPreferences.self)
    }

    func registerPushToken(_ token: String) async throws -> PushTokenRegistration {
        let request = ApiV1NotificationsPushTokenPostRequest(pushToken: token)
        let response = try await executeAuthorized {
            try await NotificationsAPI.apiV1NotificationsPushTokenPost(apiV1NotificationsPushTokenPostRequest: request)
        }

        return try Self.decodeData(from: response, as: PushTokenRegistration.self)
    }

    func logout() throws {
        clearAuthorizationHeader()
        try tokenStore.deleteTokens()
    }

    private func performAuthRequest<RequestBody: Encodable>(
        path: String,
        body: RequestBody,
        bearerToken: String? = nil,
        acceptedStatusCodes: Set<Int>
    ) async throws -> AuthResponseData {
        guard let url = URL(string: configuration.apiBaseURL.absoluteString + path) else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidAuthResponse
        }

        let envelope = try? JSONDecoder().decode(AuthResponseEnvelope.self, from: data)

        guard acceptedStatusCodes.contains(httpResponse.statusCode) else {
            throw APIClientError.serverMessage(
                envelope?.error?.message ?? "Authentication request failed."
            )
        }

        guard let payload = envelope?.data else {
            throw APIClientError.invalidAuthResponse
        }

        return payload
    }

    private func completeAuthResponse(_ data: AuthResponseData) throws -> AuthFlowResult {
        if data.mfaRequired == true {
            guard let partialToken = data.partialToken, !partialToken.isEmpty else {
                throw APIClientError.invalidAuthResponse
            }

            return .mfaRequired(partialToken: partialToken)
        }

        guard let accessToken = data.accessToken,
              let role = data.role,
              let organizationID = data.orgId,
              let user = data.user else {
            throw APIClientError.invalidAuthResponse
        }

        let tokens = AuthTokens(accessToken: accessToken, refreshToken: data.refreshToken)
        try tokenStore.saveTokens(tokens)
        applyAuthorizationHeader(accessToken: tokens.accessToken)

        return .authenticated(
            AuthSession(
                userID: user.id,
                email: user.email,
                role: role,
                organizationID: organizationID,
                patientID: data.patientId
            )
        )
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

    private static func decodeData<Response: Encodable, Value: Decodable>(from response: Response, as type: Value.Type) throws -> Value {
        let encoded = try JSONEncoder().encode(response)
        return try JSONDecoder().decode(APIResponseDataEnvelope<Value>.self, from: encoded).data
    }
}

extension APIClient: DailyEntryAPIProviding {}
extension APIClient: CareAPIProviding {}

enum APIClientError: Error, LocalizedError {
    case mfaRequired
    case missingSession
    case patientRoleRequired
    case invalidIdentifier
    case invalidAuthResponse
    case invalidURL
    case serverMessage(String)
    case missingMedicationName
    case invalidMedicationDose
    case missingMedicationFrequencyDetail
    case unsupportedAssessmentScale
    case unsupportedConsentType

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
        case .invalidAuthResponse:
            return "The authentication response could not be completed."
        case .invalidURL:
            return "The API URL is not valid."
        case let .serverMessage(message):
            return message
        case .missingMedicationName:
            return "Enter the medication name or turn off medication setup."
        case .invalidMedicationDose:
            return "Enter a medication dose greater than zero."
        case .missingMedicationFrequencyDetail:
            return "Enter the medication frequency details."
        case .unsupportedAssessmentScale:
            return "This assessment is not supported by the mobile contract yet."
        case .unsupportedConsentType:
            return "This consent option is not supported by the mobile contract yet."
        }
    }
}
