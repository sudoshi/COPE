import CryptoKit
import Foundation
import XCTest
@testable import COPE

final class LocalPersistenceTests: XCTestCase {
    func testEncryptedStoreMigratesPlaintextDraftAndRewritesEncryptedPayload() async throws {
        let root = try makeTemporaryDirectory()
        let (secureStore, keyStore) = makeSecureStore()
        let draftStore = DailyEntryDraftStore(
            secureStore: secureStore,
            baseDirectory: root
        )
        let draft = makeDraft(notes: "plaintext migration note")
        let stored = StoredDailyEntryDraft(
            draft: draft,
            updatedAt: Date(timeIntervalSince1970: 1_780_000_000),
            pendingServerSave: true
        )
        let draftURL = root
            .appendingPathComponent("COPE", isDirectory: true)
            .appendingPathComponent("DailyEntryDrafts", isDirectory: true)
            .appendingPathComponent("\(draft.entryDate).json", isDirectory: false)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let plaintext = try encoder.encode(stored)

        try FileManager.default.createDirectory(
            at: draftURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try plaintext.write(to: draftURL, options: [.atomic])

        let restoredPlaintextDraft = try await draftStore.loadDraft(for: draft.entryDate)
        let migrated = try XCTUnwrap(restoredPlaintextDraft)
        XCTAssertEqual(migrated.draft, draft)
        XCTAssertTrue(migrated.pendingServerSave)

        let rewrittenData = try Data(contentsOf: draftURL)
        XCTAssertNotEqual(rewrittenData, plaintext)
        XCTAssertNil(rewrittenData.range(of: Data("plaintext migration note".utf8)))

        try keyStore.deleteKey()
        XCTAssertThrowsError(
            try secureStore.load(StoredDailyEntryDraft.self, from: draftURL, allowPlaintextMigration: false)
        )
    }

    func testDailyEntryDraftStorePersistsEncryptedDraftAndDeletesDraftDirectory() async throws {
        let root = try makeTemporaryDirectory()
        let (secureStore, _) = makeSecureStore()
        let draftStore = DailyEntryDraftStore(
            secureStore: secureStore,
            baseDirectory: root
        )
        let draft = makeDraft(notes: "private saved note")

        let saved = try await draftStore.saveDraft(draft, pendingServerSave: true)
        XCTAssertEqual(saved.draft, draft)
        XCTAssertTrue(saved.pendingServerSave)

        let restoredDraft = try await draftStore.loadDraft(for: draft.entryDate)
        let loaded = try XCTUnwrap(restoredDraft)
        XCTAssertEqual(loaded.draft, draft)
        XCTAssertTrue(loaded.pendingServerSave)

        let draftURL = root
            .appendingPathComponent("COPE", isDirectory: true)
            .appendingPathComponent("DailyEntryDrafts", isDirectory: true)
            .appendingPathComponent("\(draft.entryDate).json", isDirectory: false)
        let encryptedData = try Data(contentsOf: draftURL)
        XCTAssertNil(encryptedData.range(of: Data("private saved note".utf8)))

        try await draftStore.deleteAllDrafts()
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: draftURL.deletingLastPathComponent().path)
        )
    }

    func testOutboxStoreUpsertsOrdersAndDeletesEncryptedOperations() async throws {
        let root = try makeTemporaryDirectory()
        let (secureStore, _) = makeSecureStore()
        let outboxStore = LocalOutboxStore(
            secureStore: secureStore,
            baseDirectory: root
        )
        let firstDraft = makeDraft(notes: "first queued note")
        let updatedDraft = makeDraft(notes: "updated queued note")

        let firstSave = try await outboxStore.enqueueDailyEntrySave(firstDraft)
        let updatedSave = try await outboxStore.enqueueDailyEntrySave(
            updatedDraft,
            lastError: "offline"
        )
        let saveThenSubmit = try await outboxStore.enqueueDailyEntrySaveAndSubmit(updatedDraft)
        _ = try await outboxStore.enqueueDailyEntrySubmit(
            entryID: "BE390C0B-5AA2-47C6-A7BA-11C915F7DBBA",
            entryDate: updatedDraft.entryDate,
            lastError: "submit offline"
        )

        XCTAssertEqual(firstSave.id, updatedSave.id)
        XCTAssertEqual(updatedSave.attemptCount, 1)

        let pending = try await outboxStore.pendingOperations()
        XCTAssertEqual(pending.count, 3)
        XCTAssertEqual(Set(pending.map(\.kind)), [.dailyEntrySave, .dailyEntrySaveAndSubmit, .dailyEntrySubmit])

        let saveOperation = try XCTUnwrap(pending.first { $0.kind == .dailyEntrySave })
        XCTAssertEqual(saveOperation.draft, updatedDraft)
        XCTAssertEqual(saveOperation.lastError, "offline")

        let outboxURL = root
            .appendingPathComponent("COPE", isDirectory: true)
            .appendingPathComponent("Outbox", isDirectory: true)
            .appendingPathComponent("operations.json", isDirectory: false)
        let encryptedData = try Data(contentsOf: outboxURL)
        XCTAssertNil(encryptedData.range(of: Data("updated queued note".utf8)))

        try await outboxStore.deleteOperations(kind: .dailyEntrySave, entryDate: updatedDraft.entryDate)
        let pendingAfterSaveDelete = try await outboxStore.pendingOperations()
        XCTAssertEqual(pendingAfterSaveDelete.count, 2)

        try await outboxStore.deleteOperation(id: saveThenSubmit.id)
        let pendingAfterOperationDelete = try await outboxStore.pendingOperations()
        XCTAssertEqual(pendingAfterOperationDelete.map(\.kind), [.dailyEntrySubmit])
    }

    func testLocalPatientDataWiperDeletesDraftsOutboxAndEncryptionKey() async throws {
        let root = try makeTemporaryDirectory()
        let (secureStore, keyStore) = makeSecureStore()
        let draftStore = DailyEntryDraftStore(
            secureStore: secureStore,
            baseDirectory: root
        )
        let outboxStore = LocalOutboxStore(
            secureStore: secureStore,
            baseDirectory: root
        )
        let draft = makeDraft(notes: "wipe me")

        _ = try await draftStore.saveDraft(draft, pendingServerSave: true)
        _ = try await outboxStore.enqueueDailyEntrySave(draft)
        let keyBeforeWipe = try keyData(from: keyStore)

        let wiper = LocalPatientDataWiper(
            draftStore: draftStore,
            outboxStore: outboxStore
        )
        await wiper.wipe()

        let copeDirectory = root.appendingPathComponent("COPE", isDirectory: true)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: copeDirectory.appendingPathComponent("DailyEntryDrafts", isDirectory: true).path
            )
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: copeDirectory.appendingPathComponent("Outbox", isDirectory: true).path
            )
        )
        let pendingAfterWipe = try await outboxStore.pendingOperations()
        XCTAssertEqual(pendingAfterWipe, [])

        let keyAfterWipe = try keyData(from: keyStore)
        XCTAssertNotEqual(keyBeforeWipe, keyAfterWipe)
    }

    private func makeTemporaryDirectory(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("COPELocalPersistenceTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }
        return directory
    }

    private func makeSecureStore() -> (EncryptedLocalFileStore, LocalEncryptionKeyStore) {
        let keyStore = LocalEncryptionKeyStore(
            service: "com.cope.tests.local-persistence.\(UUID().uuidString)",
            account: "test-key"
        )
        addTeardownBlock {
            try? keyStore.deleteKey()
        }
        return (EncryptedLocalFileStore(keyStore: keyStore), keyStore)
    }

    private func makeDraft(notes: String?) -> DailyEntryDraft {
        DailyEntryDraft(
            entryDate: "2026-06-29",
            moodScore: 7,
            sleepHours: 6.5,
            anxietyScore: 3,
            stressScore: 4,
            suicidalIdeation: 0,
            notes: notes
        )
    }

    private func keyData(from keyStore: LocalEncryptionKeyStore) throws -> Data {
        try keyStore.loadOrCreateKey().withUnsafeBytes { Data($0) }
    }
}
