import Combine
import SwiftUI
import UserNotifications

@MainActor
final class CareViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var updatingConsentType: PatientConsentType?
    @Published private(set) var isUpdatingNotifications = false
    @Published private(set) var isRegisteringNotifications = false
    @Published private(set) var consentRecords: [ConsentRecord] = []
    @Published private(set) var safetyPlan: SafetyPlan?
    @Published private(set) var safetyResources: [SafetyResource] = []
    @Published private(set) var safetyDisclaimer: String?
    @Published private(set) var safetyResourceCacheMessage: String?
    @Published private(set) var notificationPreferences: NotificationPreferences?
    @Published private(set) var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var deviceToken: String?
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let apiClient: any CareAPIProviding
    private let notificationService: any NotificationRegistrationProviding
    private let safetyResourceCache: SafetyResourceCacheStore

    init(
        apiClient: any CareAPIProviding,
        notificationService: any NotificationRegistrationProviding = NotificationRegistrationService.shared,
        safetyResourceCache: SafetyResourceCacheStore = .shared
    ) {
        self.apiClient = apiClient
        self.notificationService = notificationService
        self.safetyResourceCache = safetyResourceCache
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        safetyResourceCacheMessage = nil

        await notificationService.refreshAuthorizationStatus()
        notificationAuthorizationStatus = notificationService.authorizationStatus
        deviceToken = notificationService.deviceToken

        var firstError: String?
        let restoredCachedResources = await restoreCachedSafetyResources()

        do {
            consentRecords = try await apiClient.consentRecords()
        } catch {
            firstError = firstError ?? SessionViewModel.message(for: error)
        }

        do {
            let resources = try await apiClient.safetyResources()
            applySafetyResources(resources)
            await saveCachedSafetyResources(resources)
            safetyResourceCacheMessage = nil
        } catch {
            if restoredCachedResources {
                safetyResourceCacheMessage = "Network unavailable. Showing saved crisis resources."
            } else {
                firstError = firstError ?? SessionViewModel.message(for: error)
            }
        }

        do {
            let response = try await apiClient.mySafetyPlan()
            safetyPlan = response?.plan
            if let response {
                if !response.resources.isEmpty {
                    let resources = SafetyResourcesResponse(
                        resources: response.resources,
                        disclaimer: response.disclaimer ?? safetyDisclaimer
                    )
                    applySafetyResources(resources)
                    await saveCachedSafetyResources(resources)
                    safetyResourceCacheMessage = nil
                }
                safetyDisclaimer = response.disclaimer ?? safetyDisclaimer
            }
        } catch {
            firstError = firstError ?? SessionViewModel.message(for: error)
        }

        do {
            notificationPreferences = try await apiClient.notificationPreferences()
        } catch {
            firstError = firstError ?? SessionViewModel.message(for: error)
        }

        if let registrationError = notificationService.registrationError {
            firstError = firstError ?? registrationError
        }

        errorMessage = firstError
        isLoading = false
    }

    private func restoreCachedSafetyResources() async -> Bool {
        do {
            guard let cached = try await safetyResourceCache.loadResources() else {
                return false
            }

            applySafetyResources(cached.response)
            safetyResourceCacheMessage = "Showing saved crisis resources."
            return true
        } catch {
            return false
        }
    }

    private func saveCachedSafetyResources(_ resources: SafetyResourcesResponse) async {
        guard !resources.resources.isEmpty else {
            return
        }

        _ = try? await safetyResourceCache.saveResources(resources)
    }

    private func applySafetyResources(_ resources: SafetyResourcesResponse) {
        safetyResources = resources.resources
        safetyDisclaimer = resources.disclaimer
    }

    func isConsentGranted(_ type: PatientConsentType) -> Bool {
        consentRecords.first { $0.type == type }?.granted == true
    }

    func setConsent(_ type: PatientConsentType, granted: Bool) async {
        updatingConsentType = type
        errorMessage = nil
        successMessage = nil

        do {
            try await apiClient.updateConsent(type: type, granted: granted)
            consentRecords = try await apiClient.consentRecords()
            successMessage = "\(type.title) updated."
        } catch {
            errorMessage = SessionViewModel.message(for: error)
        }

        updatingConsentType = nil
    }

    func updateNotificationPreferences(
        dailyReminderEnabled: Bool? = nil,
        medicationReminderEnabled: Bool? = nil,
        streakNotifications: Bool? = nil,
        appointmentReminders: Bool? = nil
    ) async {
        isUpdatingNotifications = true
        errorMessage = nil
        successMessage = nil

        do {
            notificationPreferences = try await apiClient.updateNotificationPreferences(
                NotificationPreferenceUpdate(
                    dailyReminderEnabled: dailyReminderEnabled,
                    dailyReminderTime: nil,
                    medicationReminderEnabled: medicationReminderEnabled,
                    streakNotifications: streakNotifications,
                    appointmentReminders: appointmentReminders,
                    pushToken: nil
                )
            )
            successMessage = "Notification preferences updated."
        } catch {
            errorMessage = SessionViewModel.message(for: error)
        }

        isUpdatingNotifications = false
    }

    func enableNotifications() async {
        isRegisteringNotifications = true
        errorMessage = nil
        successMessage = nil

        let granted = await notificationService.requestAuthorization()
        notificationAuthorizationStatus = notificationService.authorizationStatus

        guard granted else {
            errorMessage = "Notification permission was not granted."
            isRegisteringNotifications = false
            return
        }

        notificationService.registerForRemoteNotifications()

        if let token = notificationService.deviceToken {
            await registerDeviceToken(token)
        } else {
            successMessage = "Notifications are allowed. This device will register after iOS returns a token."
        }

        isRegisteringNotifications = false
    }

    func registerDeviceToken(_ token: String) async {
        guard !token.isEmpty else {
            return
        }

        isRegisteringNotifications = true
        errorMessage = nil

        do {
            _ = try await apiClient.registerPushToken(token)
            notificationPreferences = try await apiClient.notificationPreferences()
            try await apiClient.updateConsent(type: .pushNotifications, granted: true)
            consentRecords = try await apiClient.consentRecords()
            deviceToken = token
            successMessage = "Notifications enabled for this device."
        } catch {
            errorMessage = SessionViewModel.message(for: error)
        }

        isRegisteringNotifications = false
    }
}

struct CareView: View {
    @StateObject private var model: CareViewModel

    init(apiClient: any CareAPIProviding) {
        _model = StateObject(wrappedValue: CareViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    safetySection
                    consentSection
                    notificationSection
                    messageSection
                }
                .padding(20)
            }
            .background(CopeColor.background)
            .navigationTitle("Care")
            .toolbar {
                Button {
                    Task { await model.load() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(model.isLoading)
                .accessibilityLabel("Refresh care")
            }
        }
        .task {
            await model.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: .copeRemoteNotificationTokenDidChange)) { notification in
            guard let token = notification.object as? String else {
                return
            }
            Task {
                await model.registerDeviceToken(token)
            }
        }
    }

    private var safetySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Safety", systemImage: "cross.case.fill", isLoading: model.isLoading)

            if let safetyPlan = model.safetyPlan {
                SafetyPlanCard(plan: safetyPlan)
            } else {
                EmptyStateRow(
                    systemImage: "doc.text.magnifyingglass",
                    title: "No safety plan on file",
                    subtitle: "Ask your care team to create one."
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(model.safetyResources) { resource in
                    SafetyResourceRow(resource: resource)
                }
            }

            if let cacheMessage = model.safetyResourceCacheMessage {
                Label(cacheMessage, systemImage: "icloud.slash")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CopeColor.warning)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let disclaimer = model.safetyDisclaimer {
                Text(disclaimer)
                    .font(.system(size: 13))
                    .foregroundStyle(CopeColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var consentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Consent", systemImage: "checkmark.shield.fill", isLoading: false)

            VStack(spacing: 12) {
                ForEach(PatientConsentType.appControls) { type in
                    ConsentToggleRow(
                        type: type,
                        isOn: Binding(
                            get: { model.isConsentGranted(type) },
                            set: { isGranted in
                                Task {
                                    await model.setConsent(type, granted: isGranted)
                                }
                            }
                        ),
                        isUpdating: model.updatingConsentType == type
                    )
                }
            }
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Notifications", systemImage: "bell.badge.fill", isLoading: false)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(model.notificationAuthorizationStatus.displayLabel)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(CopeColor.text)

                        Text(model.notificationPreferences?.pushToken == nil ? "No device token registered" : "Device token registered")
                            .font(.system(size: 13))
                            .foregroundStyle(CopeColor.textMuted)
                    }

                    Spacer()

                    Button {
                        Task { await model.enableNotifications() }
                    } label: {
                        Label(model.isRegisteringNotifications ? "Working" : "Enable", systemImage: "bell.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .background(CopeColor.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(model.isRegisteringNotifications)
                }

                Divider()
                    .overlay(CopeColor.border)

                NotificationToggleRow(
                    title: "Daily reminders",
                    systemImage: "calendar.badge.clock",
                    isOn: Binding(
                        get: { model.notificationPreferences?.dailyReminderEnabled ?? true },
                        set: { value in
                            Task { await model.updateNotificationPreferences(dailyReminderEnabled: value) }
                        }
                    ),
                    isDisabled: model.isUpdatingNotifications
                )

                NotificationToggleRow(
                    title: "Medication reminders",
                    systemImage: "pills.fill",
                    isOn: Binding(
                        get: { model.notificationPreferences?.medicationReminderEnabled ?? true },
                        set: { value in
                            Task { await model.updateNotificationPreferences(medicationReminderEnabled: value) }
                        }
                    ),
                    isDisabled: model.isUpdatingNotifications
                )

                NotificationToggleRow(
                    title: "Streak notices",
                    systemImage: "flame.fill",
                    isOn: Binding(
                        get: { model.notificationPreferences?.streakNotifications ?? true },
                        set: { value in
                            Task { await model.updateNotificationPreferences(streakNotifications: value) }
                        }
                    ),
                    isDisabled: model.isUpdatingNotifications
                )

                NotificationToggleRow(
                    title: "Appointments",
                    systemImage: "person.2.wave.2.fill",
                    isOn: Binding(
                        get: { model.notificationPreferences?.appointmentReminders ?? true },
                        set: { value in
                            Task { await model.updateNotificationPreferences(appointmentReminders: value) }
                        }
                    ),
                    isDisabled: model.isUpdatingNotifications
                )
            }
            .padding(16)
            .background(CopeColor.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    @ViewBuilder
    private var messageSection: some View {
        if let successMessage = model.successMessage {
            Text(successMessage)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(CopeColor.success)
        }

        if let errorMessage = model.errorMessage {
            Text(errorMessage)
                .font(.system(size: 14))
                .foregroundStyle(CopeColor.danger)
        }
    }
}

private struct SectionHeader: View {
    let title: String
    let systemImage: String
    let isLoading: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(CopeColor.primary)
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(CopeColor.text)
            Spacer()
            if isLoading {
                ProgressView()
                    .tint(CopeColor.primary)
            }
        }
    }
}

private struct EmptyStateRow: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(CopeColor.textMuted)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(CopeColor.text)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(CopeColor.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(CopeColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(CopeColor.border, lineWidth: 1)
        )
    }
}

private struct SafetyPlanCard: View {
    let plan: SafetyPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Safety Plan")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(CopeColor.text)

                    Text(plan.isAcknowledged ? "Acknowledged" : "Needs acknowledgement")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(plan.isAcknowledged ? CopeColor.success : CopeColor.warning)
                }

                Spacer()

                if let updatedAt = plan.updatedAt {
                    Text(updatedAt)
                        .font(.system(size: 12))
                        .foregroundStyle(CopeColor.textMuted)
                        .lineLimit(1)
                }
            }

            SafetyPlanList(title: "Warning signs", values: plan.warningSigns)
            SafetyPlanList(title: "Coping strategies", values: plan.internalCopingStrategies)
            SafetyPlanList(title: "Reasons for living", values: plan.reasonsForLiving)

            if !plan.supportContacts.isEmpty {
                SafetyContactList(title: "Support contacts", contacts: plan.supportContacts)
            }

            if let emergencySteps = plan.emergencySteps, !emergencySteps.isEmpty {
                TextBlock(title: "Emergency steps", value: emergencySteps)
            }

            if let erAddress = plan.erAddress, !erAddress.isEmpty {
                TextBlock(title: "Emergency room", value: erAddress)
            }
        }
        .padding(16)
        .background(CopeColor.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct SafetyPlanList: View {
    let title: String
    let values: [String]

    var body: some View {
        if !values.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CopeColor.textMuted)

                ForEach(values, id: \.self) { value in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "smallcircle.filled.circle.fill")
                            .font(.system(size: 7))
                            .foregroundStyle(CopeColor.primary)
                            .padding(.top, 6)
                        Text(value)
                            .font(.system(size: 14))
                            .foregroundStyle(CopeColor.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

private struct SafetyContactList: View {
    let title: String
    let contacts: [SafetyPlanContact]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CopeColor.textMuted)

            ForEach(Array(contacts.enumerated()), id: \.offset) { _, contact in
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name ?? contact.relationship ?? contact.location ?? "Contact")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(CopeColor.text)

                    Text(contact.details)
                        .font(.system(size: 13))
                        .foregroundStyle(CopeColor.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(CopeColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

private struct TextBlock: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CopeColor.textMuted)
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(CopeColor.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct SafetyResourceRow: View {
    let resource: SafetyResource

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: resource.available247 ? "phone.badge.waveform.fill" : "phone.fill")
                    .foregroundStyle(CopeColor.primary)
                    .frame(width: 26)

                VStack(alignment: .leading, spacing: 5) {
                    Text(resource.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CopeColor.text)

                    if let description = resource.description {
                        Text(description)
                            .font(.system(size: 13))
                            .foregroundStyle(CopeColor.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer()
            }

            HStack(spacing: 10) {
                if let phoneURL = resource.phoneURL, let phone = resource.phone {
                    Link(destination: phoneURL) {
                        Label(phone, systemImage: "phone.fill")
                    }
                }

                if let textURL = resource.textURL, let textTo = resource.textTo {
                    Link(destination: textURL) {
                        Label(textTo, systemImage: "message.fill")
                    }
                }

                if let url = resource.urlValue {
                    Link(destination: url) {
                        Image(systemName: "safari.fill")
                            .accessibilityLabel("Open website")
                    }
                }
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(CopeColor.primary)
        }
        .padding(16)
        .background(CopeColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(CopeColor.border, lineWidth: 1)
        )
    }
}

private struct ConsentToggleRow: View {
    let type: PatientConsentType
    @Binding var isOn: Bool
    let isUpdating: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: type.systemImage)
                    .foregroundStyle(CopeColor.primary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CopeColor.text)

                    Text(type.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(CopeColor.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .toggleStyle(.switch)
        .tint(CopeColor.primary)
        .disabled(isUpdating)
        .padding(16)
        .background(CopeColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(CopeColor.border, lineWidth: 1)
        )
    }
}

private struct NotificationToggleRow: View {
    let title: String
    let systemImage: String
    @Binding var isOn: Bool
    let isDisabled: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(CopeColor.text)
        }
        .toggleStyle(.switch)
        .tint(CopeColor.primary)
        .disabled(isDisabled)
    }
}

private extension SafetyPlanContact {
    var details: String {
        [relationship, phone, location, note]
            .compactMap { $0?.nilIfEmpty }
            .joined(separator: " | ")
            .nilIfEmpty ?? "No details listed"
    }
}

private extension SafetyResource {
    var phoneURL: URL? {
        guard let phone else { return nil }
        let digits = phone.filter { $0.isNumber || $0 == "+" }
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel://\(digits)")
    }

    var textURL: URL? {
        guard let textTo else { return nil }
        let digits = textTo.filter { $0.isNumber || $0 == "+" }
        guard !digits.isEmpty else { return nil }
        return URL(string: "sms://\(digits)")
    }
}

private extension UNAuthorizationStatus {
    var displayLabel: String {
        switch self {
        case .notDetermined:
            return "Notifications not requested"
        case .denied:
            return "Notifications disabled"
        case .authorized:
            return "Notifications allowed"
        case .provisional:
            return "Notifications provisional"
        case .ephemeral:
            return "Notifications temporary"
        @unknown default:
            return "Notification status unknown"
        }
    }
}

#Preview {
    CareView(apiClient: APIClient())
}
