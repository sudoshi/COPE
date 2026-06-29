import Foundation
import XCTest
@testable import COPE

@MainActor
final class TodayViewModelTests: XCTestCase {
    func testLoadReplaysQueuedDraftSaveAndMarksLocalDraftSynced() async throws {
        let harness = try makeHarness()
        let offlineAPI = MockDailyEntryAPI()
        await offlineAPI.setSaveShouldFail(true)
        let offlineModel = TodayViewModel(
            apiClient: offlineAPI,
            draftStore: harness.draftStore,
            outboxStore: harness.outboxStore,
            now: { Date(timeIntervalSince1970: 1_782_755_200) }
        )

        offlineModel.moodScore = 8
        offlineModel.sleepHours = 6.5
        offlineModel.anxietyScore = 3
        offlineModel.stressScore = 5
        offlineModel.suicidalIdeation = 0
        offlineModel.notes = "queued save replay"

        await offlineModel.saveDraft()

        XCTAssertEqual(offlineModel.queuedOperationCount, 1)
        XCTAssertTrue(offlineModel.localDraftNeedsSync)
        XCTAssertEqual(offlineModel.errorMessage, "Saved locally. Connect to sync this draft with your care record.")
        let pendingOfflineOperations = try await harness.outboxStore.pendingOperations()
        XCTAssertEqual(pendingOfflineOperations.map(\.kind), [.dailyEntrySave])

        let onlineAPI = MockDailyEntryAPI()
        let replayModel = TodayViewModel(
            apiClient: onlineAPI,
            draftStore: harness.draftStore,
            outboxStore: harness.outboxStore,
            now: { Date(timeIntervalSince1970: 1_782_755_200) }
        )

        await replayModel.load()

        let savedDrafts = await onlineAPI.savedDrafts()
        let submittedIDs = await onlineAPI.submittedIDs()
        let pendingReplayOperations = try await harness.outboxStore.pendingOperations()
        let syncedDraftRecord = try await harness.draftStore.loadDraft(for: fixedEntryDate)
        let syncedDraft = try XCTUnwrap(syncedDraftRecord)

        XCTAssertEqual(savedDrafts, [expectedDraft(notes: "queued save replay")])
        XCTAssertEqual(submittedIDs, [])
        XCTAssertEqual(replayModel.entry?.mood, 8)
        XCTAssertEqual(replayModel.entry?.entryDate, fixedEntryDate)
        XCTAssertFalse(replayModel.localDraftNeedsSync)
        XCTAssertEqual(replayModel.queuedOperationCount, 0)
        XCTAssertEqual(replayModel.successMessage, "Local changes synced.")
        XCTAssertEqual(pendingReplayOperations, [])
        XCTAssertEqual(syncedDraft.draft, expectedDraft(notes: "queued save replay"))
        XCTAssertFalse(syncedDraft.pendingServerSave)
    }

    func testLoadReplaysQueuedSaveAndSubmitAndClearsLocalDraft() async throws {
        let harness = try makeHarness()
        let offlineAPI = MockDailyEntryAPI()
        await offlineAPI.setSaveShouldFail(true)
        let offlineModel = TodayViewModel(
            apiClient: offlineAPI,
            draftStore: harness.draftStore,
            outboxStore: harness.outboxStore,
            now: { Date(timeIntervalSince1970: 1_782_755_200) }
        )

        offlineModel.moodScore = 9
        offlineModel.sleepHours = 7.5
        offlineModel.anxietyScore = 2
        offlineModel.stressScore = 3
        offlineModel.suicidalIdeation = 0
        offlineModel.notes = "queued submit replay"

        await offlineModel.submit()

        XCTAssertEqual(offlineModel.queuedOperationCount, 1)
        XCTAssertTrue(offlineModel.localDraftNeedsSync)
        XCTAssertEqual(offlineModel.errorMessage, "Saved locally. Connect to sync this check-in submission.")
        let pendingOfflineOperations = try await harness.outboxStore.pendingOperations()
        let offlineDraft = try await harness.draftStore.loadDraft(for: fixedEntryDate)
        XCTAssertEqual(pendingOfflineOperations.map(\.kind), [.dailyEntrySaveAndSubmit])
        XCTAssertNotNil(offlineDraft)

        let onlineAPI = MockDailyEntryAPI()
        let replayModel = TodayViewModel(
            apiClient: onlineAPI,
            draftStore: harness.draftStore,
            outboxStore: harness.outboxStore,
            now: { Date(timeIntervalSince1970: 1_782_755_200) }
        )

        await replayModel.load()

        let savedDrafts = await onlineAPI.savedDrafts()
        let submittedIDs = await onlineAPI.submittedIDs()
        let pendingReplayOperations = try await harness.outboxStore.pendingOperations()
        let replayDraft = try await harness.draftStore.loadDraft(for: fixedEntryDate)

        XCTAssertEqual(savedDrafts, [expectedDraft(
            moodScore: 9,
            sleepHours: 7.5,
            anxietyScore: 2,
            stressScore: 3,
            notes: "queued submit replay"
        )])
        XCTAssertEqual(submittedIDs, [MockDailyEntryAPI.entryID])
        XCTAssertEqual(replayModel.entry?.id, MockDailyEntryAPI.entryID)
        XCTAssertEqual(replayModel.entry?.entryDate, fixedEntryDate)
        XCTAssertEqual(replayModel.entry?.mood, 9)
        XCTAssertTrue(replayModel.entry?.isSubmitted == true)
        XCTAssertFalse(replayModel.localDraftNeedsSync)
        XCTAssertEqual(replayModel.queuedOperationCount, 0)
        XCTAssertEqual(replayModel.successMessage, "Local changes synced.")
        XCTAssertEqual(pendingReplayOperations, [])
        XCTAssertNil(replayDraft)
    }

    private struct Harness {
        let draftStore: DailyEntryDraftStore
        let outboxStore: LocalOutboxStore
    }

    private var fixedEntryDate: String {
        "2026-06-29"
    }

    private func makeHarness(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Harness {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("COPETodayViewModelTests-\(UUID().uuidString)", isDirectory: true)
        let keyStore = LocalEncryptionKeyStore(
            service: "com.cope.tests.today-view-model.\(UUID().uuidString)",
            account: "test-key"
        )
        let secureStore = EncryptedLocalFileStore(keyStore: keyStore)

        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: root)
            try? keyStore.deleteKey()
        }

        return Harness(
            draftStore: DailyEntryDraftStore(secureStore: secureStore, baseDirectory: root),
            outboxStore: LocalOutboxStore(secureStore: secureStore, baseDirectory: root)
        )
    }

    private func expectedDraft(
        moodScore: Int = 8,
        sleepHours: Double = 6.5,
        anxietyScore: Int = 3,
        stressScore: Int = 5,
        suicidalIdeation: Int = 0,
        notes: String
    ) -> DailyEntryDraft {
        DailyEntryDraft(
            entryDate: fixedEntryDate,
            moodScore: moodScore,
            sleepHours: sleepHours,
            anxietyScore: anxietyScore,
            stressScore: stressScore,
            suicidalIdeation: suicidalIdeation,
            notes: notes
        )
    }
}

private actor MockDailyEntryAPI: DailyEntryAPIProviding {
    static let entryID = "BE390C0B-5AA2-47C6-A7BA-11C915F7DBBA"
    private static let submittedAt = "2026-06-29T16:15:00.000Z"

    private var saveShouldFail = false
    private var submitShouldFail = false
    private var todayShouldFail = false
    private var saved: [DailyEntryDraft] = []
    private var submitted: [String] = []
    private var currentEntry: DailyEntrySummary?

    func setSaveShouldFail(_ shouldFail: Bool) {
        saveShouldFail = shouldFail
    }

    func setSubmitShouldFail(_ shouldFail: Bool) {
        submitShouldFail = shouldFail
    }

    func setTodayShouldFail(_ shouldFail: Bool) {
        todayShouldFail = shouldFail
    }

    func savedDrafts() -> [DailyEntryDraft] {
        saved
    }

    func submittedIDs() -> [String] {
        submitted
    }

    func todayDailyEntry() async throws -> DailyEntrySummary? {
        if todayShouldFail {
            throw APIClientError.serverMessage("offline")
        }

        return currentEntry
    }

    func saveDailyEntry(_ draft: DailyEntryDraft) async throws -> DailyEntryWriteResult {
        if saveShouldFail {
            throw APIClientError.serverMessage("offline")
        }

        saved.append(draft)
        currentEntry = DailyEntrySummary(
            id: Self.entryID,
            entryDate: draft.entryDate,
            mood: draft.moodScore,
            submittedAt: nil,
            completionPct: currentEntry?.completionPct,
            coreComplete: true,
            wellnessComplete: currentEntry?.wellnessComplete,
            triggersComplete: currentEntry?.triggersComplete,
            symptomsComplete: currentEntry?.symptomsComplete,
            journalComplete: currentEntry?.journalComplete
        )

        return DailyEntryWriteResult(id: Self.entryID, entryDate: draft.entryDate)
    }

    func submitDailyEntry(id: String) async throws -> DailyEntrySubmitResult {
        if submitShouldFail {
            throw APIClientError.serverMessage("offline")
        }

        submitted.append(id)
        if let currentEntry {
            self.currentEntry = DailyEntrySummary(
                id: currentEntry.id,
                entryDate: currentEntry.entryDate,
                mood: currentEntry.mood,
                submittedAt: Self.submittedAt,
                completionPct: currentEntry.completionPct,
                coreComplete: currentEntry.coreComplete,
                wellnessComplete: currentEntry.wellnessComplete,
                triggersComplete: currentEntry.triggersComplete,
                symptomsComplete: currentEntry.symptomsComplete,
                journalComplete: currentEntry.journalComplete
            )
        }

        return DailyEntrySubmitResult(id: id, submittedAt: Self.submittedAt)
    }
}
