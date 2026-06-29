import SwiftUI

struct OnboardingIntakeView: View {
    @EnvironmentObject private var session: SessionViewModel
    @State private var primaryConcern = ""
    @State private var emergencyContactName = ""
    @State private var emergencyContactPhone = ""
    @State private var emergencyContactRelationship = ""
    @State private var addMedication = false
    @State private var medicationName = ""
    @State private var medicationDose = ""
    @State private var medicationDoseUnit = "mg"
    @State private var medicationFrequency: MedicationFrequencyOption = .onceDailyMorning
    @State private var medicationFrequencyOther = ""
    @State private var medicationInstructions = ""
    @State private var symptomOptions: [OnboardingCatalogueItem] = []
    @State private var triggerOptions: [OnboardingCatalogueItem] = []
    @State private var strategyOptions: [OnboardingCatalogueItem] = []
    @State private var selectedSymptomIDs = Set<UUID>()
    @State private var selectedTriggerIDs = Set<UUID>()
    @State private var selectedStrategyIDs = Set<UUID>()
    @State private var isLoadingCatalogues = false
    @State private var hasLoadedCatalogues = false
    @State private var catalogueError: String?
    @State private var dailyReminderEnabled = true
    @State private var medicationReminderEnabled = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    primaryConcernSection
                    emergencyContactSection
                    medicationSection
                    preferencesSection
                    remindersSection
                    messageSection
                    submitButton
                }
                .padding(24)
                .frame(maxWidth: 640, alignment: .leading)
            }
            .background(CopeColor.background)
            .task {
                await loadCataloguesIfNeeded()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        Task {
                            await session.signOut()
                        }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                    .accessibilityLabel("Sign out")
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Intake")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(CopeColor.text)

            Text(session.profile?.displayName ?? "Patient profile")
                .font(.system(size: 15))
                .foregroundStyle(CopeColor.textMuted)
        }
    }

    private var primaryConcernSection: some View {
        OnboardingSection(title: "Primary Concern", systemImage: "stethoscope") {
            ZStack(alignment: .topLeading) {
                if primaryConcern.isEmpty {
                    Text("What would you like your care team to know first?")
                        .font(.system(size: 15))
                        .foregroundStyle(CopeColor.textMuted)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $primaryConcern)
                    .font(.system(size: 15))
                    .foregroundStyle(CopeColor.text)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 132)
            }
            .padding(10)
            .background(CopeColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(CopeColor.border, lineWidth: 1)
            )
        }
    }

    private var emergencyContactSection: some View {
        OnboardingSection(title: "Emergency Contact", systemImage: "phone.fill") {
            VStack(alignment: .leading, spacing: 12) {
                IntakeTextField(title: "Name", text: $emergencyContactName, contentType: .name)
                IntakeTextField(title: "Phone", text: $emergencyContactPhone, contentType: .telephoneNumber, keyboardType: .phonePad)
                IntakeTextField(title: "Relationship", text: $emergencyContactRelationship)
            }
        }
    }

    private var medicationSection: some View {
        OnboardingSection(title: "Medication Setup", systemImage: "pills.fill") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Add a medication now", isOn: $addMedication)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.text)
                    .tint(CopeColor.primary)

                if addMedication {
                    IntakeTextField(title: "Medication name", text: $medicationName)

                    HStack(spacing: 10) {
                        IntakeTextField(title: "Dose", text: $medicationDose, keyboardType: .decimalPad)
                        IntakeTextField(title: "Unit", text: $medicationDoseUnit)
                            .frame(maxWidth: 120)
                    }

                    Menu {
                        ForEach(MedicationFrequencyOption.allCases) { option in
                            Button(option.label) {
                                medicationFrequency = option
                            }
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Frequency")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(CopeColor.textMuted)
                                Text(medicationFrequency.label)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(CopeColor.text)
                            }

                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(CopeColor.primary)
                        }
                        .padding(14)
                        .background(CopeColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(CopeColor.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    if medicationFrequency == .other {
                        IntakeTextField(title: "Frequency details", text: $medicationFrequencyOther)
                    }

                    IntakeTextField(title: "Instructions", text: $medicationInstructions)
                }
            }
        }
    }

    private var preferencesSection: some View {
        OnboardingSection(title: "Preferences", systemImage: "slider.horizontal.3") {
            VStack(alignment: .leading, spacing: 18) {
                if isLoadingCatalogues {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(CopeColor.primary)
                        Text("Loading options")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(CopeColor.textMuted)
                    }
                }

                if let catalogueError {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(catalogueError)
                            .font(.system(size: 14))
                            .foregroundStyle(CopeColor.danger)
                            .fixedSize(horizontal: false, vertical: true)

                        Button {
                            Task {
                                await reloadCatalogues()
                            }
                        } label: {
                            Label("Retry", systemImage: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(CopeColor.primary)
                    }
                }

                CataloguePicker(
                    title: "Symptoms",
                    systemImage: "heart.text.square.fill",
                    options: symptomOptions,
                    selectedIDs: $selectedSymptomIDs,
                    emptyText: "No symptom options available.",
                    badgeProvider: { $0.isSafetySymptom ? "Safety" : $0.category }
                )

                CataloguePicker(
                    title: "Triggers",
                    systemImage: "bolt.heart.fill",
                    options: triggerOptions,
                    selectedIDs: $selectedTriggerIDs,
                    emptyText: "No trigger options available.",
                    badgeProvider: { $0.category }
                )

                CataloguePicker(
                    title: "Wellness Strategies",
                    systemImage: "figure.mind.and.body",
                    options: strategyOptions,
                    selectedIDs: $selectedStrategyIDs,
                    emptyText: "No strategy options available.",
                    badgeProvider: { $0.hasQualityRating ? "Quality" : $0.category }
                )
            }
        }
    }

    private var remindersSection: some View {
        OnboardingSection(title: "Reminders", systemImage: "bell.badge.fill") {
            VStack(alignment: .leading, spacing: 12) {
                ReminderToggleRow(
                    title: "Daily check-in",
                    systemImage: "calendar.badge.clock",
                    isOn: $dailyReminderEnabled
                )

                ReminderToggleRow(
                    title: "Medication",
                    systemImage: "pills.fill",
                    isOn: $medicationReminderEnabled
                )
            }
        }
    }

    @ViewBuilder
    private var messageSection: some View {
        if let errorMessage = session.errorMessage {
            Text(errorMessage)
                .font(.system(size: 14))
                .foregroundStyle(CopeColor.danger)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var submitButton: some View {
        Button {
            Task {
                await session.completeIntake(
                    primaryConcern: primaryConcern,
                    emergencyContactName: emergencyContactName,
                    emergencyContactPhone: emergencyContactPhone,
                    emergencyContactRelationship: emergencyContactRelationship,
                    addMedication: addMedication,
                    medicationName: medicationName,
                    medicationDose: medicationDose,
                    medicationDoseUnit: medicationDoseUnit,
                    medicationFrequency: medicationFrequency,
                    medicationFrequencyOther: medicationFrequencyOther,
                    medicationInstructions: medicationInstructions,
                    selectedSymptomIDs: selectedSymptomIDs,
                    selectedTriggerIDs: selectedTriggerIDs,
                    selectedStrategyIDs: selectedStrategyIDs,
                    dailyReminderEnabled: dailyReminderEnabled,
                    medicationReminderEnabled: medicationReminderEnabled
                )
            }
        } label: {
            Label(session.isLoading ? "Saving Intake" : "Complete Intake", systemImage: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(session.isLoading ? CopeColor.primaryDark : CopeColor.primary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .disabled(session.isLoading)
    }

    @MainActor
    private func loadCataloguesIfNeeded() async {
        guard !hasLoadedCatalogues, !isLoadingCatalogues else {
            return
        }

        isLoadingCatalogues = true
        catalogueError = nil

        do {
            async let symptoms = session.apiClient.symptomCatalogue()
            async let triggers = session.apiClient.triggerCatalogue()
            async let strategies = session.apiClient.strategyCatalogue()

            symptomOptions = try await symptoms
            triggerOptions = try await triggers
            strategyOptions = try await strategies
            hasLoadedCatalogues = true
        } catch {
            catalogueError = SessionViewModel.message(for: error)
        }

        isLoadingCatalogues = false
    }

    @MainActor
    private func reloadCatalogues() async {
        hasLoadedCatalogues = false
        await loadCataloguesIfNeeded()
    }
}

private struct OnboardingSection<Content: View>: View {
    let title: String
    let systemImage: String
    private let content: Content

    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.primary)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.text)
            }

            content
        }
        .padding(16)
        .background(CopeColor.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(CopeColor.border, lineWidth: 1)
        )
    }
}

private struct CataloguePicker: View {
    let title: String
    let systemImage: String
    let options: [OnboardingCatalogueItem]
    @Binding var selectedIDs: Set<UUID>
    let emptyText: String
    let badgeProvider: (OnboardingCatalogueItem) -> String?

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CopeColor.primary)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CopeColor.text)

                Spacer()

                Text("\(selectedIDs.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(CopeColor.textMuted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(CopeColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if options.isEmpty {
                Text(emptyText)
                    .font(.system(size: 13))
                    .foregroundStyle(CopeColor.textMuted)
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                    ForEach(options) { option in
                        CatalogueOptionButton(
                            item: option,
                            isSelected: selectedIDs.contains(option.id),
                            badge: badgeProvider(option)
                        ) {
                            toggle(option.id)
                        }
                    }
                }
            }
        }
    }

    private func toggle(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
}

private struct CatalogueOptionButton: View {
    let item: OnboardingCatalogueItem
    let isSelected: Bool
    let badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? CopeColor.primary : CopeColor.textMuted)

                    Text(item.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(CopeColor.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let badge, !badge.isEmpty {
                    Text(badge)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(CopeColor.textMuted)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 62, alignment: .topLeading)
            .padding(10)
            .background(isSelected ? CopeColor.surfaceElevated : CopeColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? CopeColor.primary : CopeColor.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ReminderToggleRow: View {
    let title: String
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.primary)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.text)
            }
        }
        .tint(CopeColor.primary)
        .padding(14)
        .background(CopeColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(CopeColor.border, lineWidth: 1)
        )
    }
}

private struct IntakeTextField: View {
    let title: String
    @Binding var text: String
    var contentType: UITextContentType?
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(title, text: $text)
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .textFieldStyle(.plain)
            .padding(14)
            .background(CopeColor.surface)
            .foregroundStyle(CopeColor.text)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(CopeColor.border, lineWidth: 1)
            )
    }
}

#Preview {
    OnboardingIntakeView()
        .environmentObject(SessionViewModel())
}
