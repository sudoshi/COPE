import SwiftUI

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published private(set) var entry: DailyEntrySummary?
    @Published private(set) var localDraftMessage: String?
    @Published private(set) var localDraftNeedsSync = false
    @Published private(set) var queuedOperationCount = 0
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var moodScore = 6
    @Published var sleepHours = 7.0
    @Published var anxietyScore = 4
    @Published var stressScore = 4
    @Published var suicidalIdeation = 0
    @Published var notes = ""

    private let apiClient: APIClient
    private let draftStore: DailyEntryDraftStore
    private let outboxStore: LocalOutboxStore

    init(
        apiClient: APIClient,
        draftStore: DailyEntryDraftStore = .shared,
        outboxStore: LocalOutboxStore = .shared
    ) {
        self.apiClient = apiClient
        self.draftStore = draftStore
        self.outboxStore = outboxStore
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        let restoredLocalDraft = await restoreLocalDraft()
        await refreshOutboxStatus()
        await flushPendingOutbox()

        do {
            entry = try await apiClient.todayDailyEntry()
            if let entry, entry.isSubmitted {
                try? await draftStore.deleteDraft(for: entry.entryDate)
                localDraftMessage = nil
                localDraftNeedsSync = false
            } else if !restoredLocalDraft, let entry, let mood = entry.mood {
                moodScore = mood
            }
        } catch {
            errorMessage = restoredLocalDraft
                ? "Network unavailable. Your saved local draft is still on this device."
                : SessionViewModel.message(for: error)
        }

        isLoading = false
    }

    func saveDraft() async {
        isSaving = true
        errorMessage = nil
        successMessage = nil
        let draft = currentDraft
        let localSaved = await saveLocalDraft(draft, pendingServerSave: true)
        await enqueueSaveOperation(draft)

        do {
            let result = try await apiClient.saveDailyEntry(draft)
            entry = DailyEntrySummary(
                id: result.id,
                entryDate: result.entryDate,
                mood: moodScore,
                submittedAt: nil,
                completionPct: entry?.completionPct,
                coreComplete: true,
                wellnessComplete: entry?.wellnessComplete,
                triggersComplete: entry?.triggersComplete,
                symptomsComplete: entry?.symptomsComplete,
                journalComplete: entry?.journalComplete
            )
            _ = await saveLocalDraft(draft, pendingServerSave: false)
            await deleteOutboxOperations(kind: .dailyEntrySave, entryDate: draft.entryDate)
            successMessage = "Draft saved."
        } catch {
            errorMessage = localSaved
                ? "Saved locally. Connect to sync this draft with your care record."
                : SessionViewModel.message(for: error)
        }

        isSaving = false
    }

    func submit() async {
        isSaving = true
        errorMessage = nil
        successMessage = nil

        if entry == nil {
            let createdEntry = await createEntryForSubmit()
            if !createdEntry {
                isSaving = false
                return
            }
        }

        guard let entry else {
            isSaving = false
            return
        }

        do {
            let result = try await apiClient.submitDailyEntry(id: entry.id)
            self.entry = DailyEntrySummary(
                id: entry.id,
                entryDate: entry.entryDate,
                mood: entry.mood ?? moodScore,
                submittedAt: result.submittedAt,
                completionPct: entry.completionPct,
                coreComplete: entry.coreComplete,
                wellnessComplete: entry.wellnessComplete,
                triggersComplete: entry.triggersComplete,
                symptomsComplete: entry.symptomsComplete,
                journalComplete: entry.journalComplete
            )
            try? await draftStore.deleteDraft(for: entry.entryDate)
            await deleteOutboxOperations(kind: .dailyEntrySubmit, entryDate: entry.entryDate)
            localDraftMessage = nil
            localDraftNeedsSync = false
            successMessage = "Check-in submitted."
        } catch {
            await enqueueSubmitOperation(entryID: entry.id, entryDate: entry.entryDate, error: error)
            localDraftNeedsSync = true
            localDraftMessage = "Submission queued locally; waiting to sync."
            errorMessage = "Saved locally. Connect to sync this check-in submission."
        }

        isSaving = false
    }

    private var currentDraft: DailyEntryDraft {
        DailyEntryDraft(
            entryDate: Self.todayString(),
            moodScore: moodScore,
            sleepHours: sleepHours,
            anxietyScore: anxietyScore,
            stressScore: stressScore,
            suicidalIdeation: suicidalIdeation,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
    }

    private func restoreLocalDraft() async -> Bool {
        do {
            guard let stored = try await draftStore.loadDraft(for: Self.todayString()) else {
                localDraftMessage = nil
                localDraftNeedsSync = false
                return false
            }

            apply(stored.draft)
            updateLocalDraftStatus(from: stored, verb: "Restored")
            return true
        } catch {
            errorMessage = "Saved draft could not be restored."
            return false
        }
    }

    private func saveLocalDraft(_ draft: DailyEntryDraft, pendingServerSave: Bool) async -> Bool {
        do {
            let stored = try await draftStore.saveDraft(draft, pendingServerSave: pendingServerSave)
            updateLocalDraftStatus(from: stored, verb: pendingServerSave ? "Saved locally" : "Synced locally")
            return true
        } catch {
            errorMessage = "Draft could not be saved on this device."
            return false
        }
    }

    private func apply(_ draft: DailyEntryDraft) {
        moodScore = draft.moodScore
        sleepHours = draft.sleepHours ?? sleepHours
        anxietyScore = draft.anxietyScore ?? anxietyScore
        stressScore = draft.stressScore ?? stressScore
        suicidalIdeation = draft.suicidalIdeation ?? suicidalIdeation
        notes = draft.notes ?? ""
    }

    private func updateLocalDraftStatus(from stored: StoredDailyEntryDraft, verb: String) {
        localDraftNeedsSync = stored.pendingServerSave
        let syncState = stored.pendingServerSave ? "waiting to sync" : "synced"
        localDraftMessage = "\(verb) at \(Self.timeString(stored.updatedAt)); \(syncState)."
    }

    private func createEntryForSubmit() async -> Bool {
        let draft = currentDraft
        let localSaved = await saveLocalDraft(draft, pendingServerSave: true)
        let queued = await enqueueSaveAndSubmitOperation(draft)

        do {
            let result = try await apiClient.saveDailyEntry(draft)
            entry = DailyEntrySummary(
                id: result.id,
                entryDate: result.entryDate,
                mood: moodScore,
                submittedAt: nil,
                completionPct: entry?.completionPct,
                coreComplete: true,
                wellnessComplete: entry?.wellnessComplete,
                triggersComplete: entry?.triggersComplete,
                symptomsComplete: entry?.symptomsComplete,
                journalComplete: entry?.journalComplete
            )
            _ = await saveLocalDraft(draft, pendingServerSave: false)
            await deleteOutboxOperations(kind: .dailyEntrySaveAndSubmit, entryDate: draft.entryDate)
            return true
        } catch {
            localDraftNeedsSync = localSaved || queued
            localDraftMessage = queued
                ? "Submission queued locally; waiting to sync."
                : "Submission saved locally, but could not be queued for sync."
            errorMessage = localSaved
                ? "Saved locally. Connect to sync this check-in submission."
                : SessionViewModel.message(for: error)
            return false
        }
    }

    private func enqueueSaveOperation(_ draft: DailyEntryDraft, error: Error? = nil) async {
        do {
            _ = try await outboxStore.enqueueDailyEntrySave(draft, lastError: error.map(SessionViewModel.message(for:)))
            await refreshOutboxStatus()
        } catch {
            errorMessage = "Draft was saved locally, but the sync queue could not be updated."
        }
    }

    @discardableResult
    private func enqueueSaveAndSubmitOperation(_ draft: DailyEntryDraft, error: Error? = nil) async -> Bool {
        do {
            _ = try await outboxStore.enqueueDailyEntrySaveAndSubmit(
                draft,
                lastError: error.map(SessionViewModel.message(for:))
            )
            await refreshOutboxStatus()
            return true
        } catch {
            errorMessage = "Submission could not be added to the sync queue."
            return false
        }
    }

    private func enqueueSubmitOperation(entryID: String, entryDate: String, error: Error? = nil) async {
        do {
            _ = try await outboxStore.enqueueDailyEntrySubmit(
                entryID: entryID,
                entryDate: entryDate,
                lastError: error.map(SessionViewModel.message(for:))
            )
            await refreshOutboxStatus()
        } catch {
            errorMessage = "Submission could not be added to the sync queue."
        }
    }

    private func deleteOutboxOperations(kind: LocalOutboxOperationKind, entryDate: String) async {
        do {
            try await outboxStore.deleteOperations(kind: kind, entryDate: entryDate)
            await refreshOutboxStatus()
        } catch {
            errorMessage = "The local sync queue could not be updated."
        }
    }

    private func refreshOutboxStatus() async {
        do {
            queuedOperationCount = try await outboxStore.pendingOperations().count
            if queuedOperationCount > 0 {
                localDraftNeedsSync = true
            }
        } catch {
            queuedOperationCount = 0
        }
    }

    private func flushPendingOutbox() async {
        do {
            let operations = try await outboxStore.pendingOperations()
            guard !operations.isEmpty else {
                return
            }

            for operation in operations {
                switch operation.kind {
                case .dailyEntrySave:
                    guard let draft = operation.draft else {
                        try await outboxStore.deleteOperation(id: operation.id)
                        continue
                    }

                    let result = try await apiClient.saveDailyEntry(draft)
                    try await outboxStore.deleteOperation(id: operation.id)
                    if draft.entryDate == Self.todayString() {
                        entry = DailyEntrySummary(
                            id: result.id,
                            entryDate: result.entryDate,
                            mood: draft.moodScore,
                            submittedAt: nil,
                            completionPct: entry?.completionPct,
                            coreComplete: true,
                            wellnessComplete: entry?.wellnessComplete,
                            triggersComplete: entry?.triggersComplete,
                            symptomsComplete: entry?.symptomsComplete,
                            journalComplete: entry?.journalComplete
                        )
                        _ = await saveLocalDraft(draft, pendingServerSave: false)
                    }

                case .dailyEntrySaveAndSubmit:
                    guard let draft = operation.draft else {
                        try await outboxStore.deleteOperation(id: operation.id)
                        continue
                    }

                    let savedEntry = try await apiClient.saveDailyEntry(draft)
                    let submittedEntry = try await apiClient.submitDailyEntry(id: savedEntry.id)
                    try await outboxStore.deleteOperation(id: operation.id)
                    if draft.entryDate == Self.todayString() {
                        entry = DailyEntrySummary(
                            id: savedEntry.id,
                            entryDate: savedEntry.entryDate,
                            mood: draft.moodScore,
                            submittedAt: submittedEntry.submittedAt,
                            completionPct: entry?.completionPct,
                            coreComplete: true,
                            wellnessComplete: entry?.wellnessComplete,
                            triggersComplete: entry?.triggersComplete,
                            symptomsComplete: entry?.symptomsComplete,
                            journalComplete: entry?.journalComplete
                        )
                        try? await draftStore.deleteDraft(for: draft.entryDate)
                    }

                case .dailyEntrySubmit:
                    guard let entryID = operation.entryID else {
                        try await outboxStore.deleteOperation(id: operation.id)
                        continue
                    }

                    let result = try await apiClient.submitDailyEntry(id: entryID)
                    try await outboxStore.deleteOperation(id: operation.id)
                    if operation.entryDate == Self.todayString() {
                        entry = DailyEntrySummary(
                            id: entryID,
                            entryDate: operation.entryDate,
                            mood: entry?.mood ?? moodScore,
                            submittedAt: result.submittedAt,
                            completionPct: entry?.completionPct,
                            coreComplete: entry?.coreComplete,
                            wellnessComplete: entry?.wellnessComplete,
                            triggersComplete: entry?.triggersComplete,
                            symptomsComplete: entry?.symptomsComplete,
                            journalComplete: entry?.journalComplete
                        )
                        try? await draftStore.deleteDraft(for: operation.entryDate)
                    }
                }
            }

            await refreshOutboxStatus()
            if queuedOperationCount == 0 {
                localDraftNeedsSync = false
                localDraftMessage = nil
                successMessage = "Local changes synced."
            }
        } catch {
            await refreshOutboxStatus()
            if queuedOperationCount > 0 {
                localDraftNeedsSync = true
                localDraftMessage = "\(queuedOperationCount) local change\(queuedOperationCount == 1 ? "" : "s") waiting to sync."
            }
        }
    }

    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private static func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TodayView: View {
    @StateObject private var model: TodayViewModel

    init(apiClient: APIClient) {
        _model = StateObject(wrappedValue: TodayViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    statusHeader
                    checkInControls
                    statusMessages

                    if let errorMessage = model.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(CopeColor.danger)
                    }
                }
                .padding(20)
            }
            .background(CopeColor.background)
            .navigationTitle("Today")
            .toolbar {
                Button {
                    Task { await model.load() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh today")
            }
        }
        .task {
            await model.load()
        }
    }

    private var statusHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(model.entry?.isSubmitted == true ? "Submitted" : "Check-in")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(CopeColor.text)

                Spacer()

                if model.isLoading {
                    ProgressView()
                        .tint(CopeColor.primary)
                }
            }

            Text(model.entry?.entryDate ?? Date.now.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 15))
                .foregroundStyle(CopeColor.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var statusMessages: some View {
        if let localDraftMessage = model.localDraftMessage {
            Label(
                localDraftMessage,
                systemImage: model.localDraftNeedsSync ? "icloud.and.arrow.up" : "checkmark.icloud.fill"
            )
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(model.localDraftNeedsSync ? CopeColor.warning : CopeColor.success)
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        if model.queuedOperationCount > 0 {
            Label(
                "\(model.queuedOperationCount) queued sync operation\(model.queuedOperationCount == 1 ? "" : "s")",
                systemImage: "arrow.triangle.2.circlepath"
            )
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(CopeColor.warning)
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        if let successMessage = model.successMessage {
            Label(successMessage, systemImage: "checkmark.circle.fill")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CopeColor.success)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var checkInControls: some View {
        VStack(alignment: .leading, spacing: 18) {
            ScoreSlider(title: "Mood", value: $model.moodScore, range: 1...10, systemImage: "heart.fill")
            ScoreSlider(title: "Anxiety", value: $model.anxietyScore, range: 1...10, systemImage: "waveform.path.ecg")
            ScoreSlider(title: "Stress", value: $model.stressScore, range: 1...10, systemImage: "bolt.heart.fill")
            ScoreSlider(title: "Suicidal ideation", value: $model.suicidalIdeation, range: 0...3, systemImage: "exclamationmark.triangle.fill")

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundStyle(CopeColor.primary)
                    Text("Sleep")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(CopeColor.text)
                    Spacer()
                    Text("\(model.sleepHours, specifier: "%.1f")h")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(CopeColor.text)
                }

                Slider(value: $model.sleepHours, in: 0...14, step: 0.5)
                    .tint(CopeColor.primary)
            }

            TextField("Notes", text: $model.notes, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.plain)
                .padding(14)
                .background(CopeColor.surface)
                .foregroundStyle(CopeColor.text)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(CopeColor.border, lineWidth: 1)
                )

            HStack(spacing: 12) {
                Button {
                    Task { await model.saveDraft() }
                } label: {
                    Label(model.isSaving ? "Saving" : "Save", systemImage: "tray.and.arrow.down.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .foregroundStyle(CopeColor.text)
                .background(CopeColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(CopeColor.border, lineWidth: 1)
                )
                .disabled(model.isSaving)

                Button {
                    Task { await model.submit() }
                } label: {
                    Label("Submit", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(CopeColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .disabled(model.isSaving)
            }
        }
        .padding(16)
        .background(CopeColor.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ScoreSlider: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(CopeColor.primary)
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.text)
                Spacer()
                Text("\(value)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.text)
            }

            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0.rounded()) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: 1
            )
            .tint(CopeColor.primary)
        }
    }
}

#Preview {
    TodayView(apiClient: APIClient())
}
