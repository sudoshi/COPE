import Foundation

enum LocalOutboxOperationKind: String, Codable, Equatable {
    case dailyEntrySave
    case dailyEntrySaveAndSubmit
    case dailyEntrySubmit
}

struct LocalOutboxOperation: Codable, Equatable, Identifiable {
    let id: UUID
    let kind: LocalOutboxOperationKind
    let entryDate: String
    let draft: DailyEntryDraft?
    let entryID: String?
    let createdAt: Date
    let updatedAt: Date
    let attemptCount: Int
    let lastError: String?
}

actor LocalOutboxStore {
    static let shared = LocalOutboxStore()

    private let fileManager: FileManager
    private let secureStore: EncryptedLocalFileStore
    private let baseDirectory: URL?

    init(
        fileManager: FileManager = .default,
        secureStore: EncryptedLocalFileStore = EncryptedLocalFileStore(),
        baseDirectory: URL? = nil
    ) {
        self.fileManager = fileManager
        self.secureStore = secureStore
        self.baseDirectory = baseDirectory
    }

    func pendingOperations() throws -> [LocalOutboxOperation] {
        try loadOperations().sorted { first, second in
            if first.createdAt == second.createdAt {
                return first.id.uuidString < second.id.uuidString
            }
            return first.createdAt < second.createdAt
        }
    }

    @discardableResult
    func enqueueDailyEntrySave(_ draft: DailyEntryDraft, lastError: String? = nil) throws -> LocalOutboxOperation {
        try upsertOperation(
            kind: .dailyEntrySave,
            entryDate: draft.entryDate,
            draft: draft,
            entryID: nil,
            lastError: lastError
        )
    }

    @discardableResult
    func enqueueDailyEntrySaveAndSubmit(_ draft: DailyEntryDraft, lastError: String? = nil) throws -> LocalOutboxOperation {
        try upsertOperation(
            kind: .dailyEntrySaveAndSubmit,
            entryDate: draft.entryDate,
            draft: draft,
            entryID: nil,
            lastError: lastError
        )
    }

    @discardableResult
    func enqueueDailyEntrySubmit(entryID: String, entryDate: String, lastError: String? = nil) throws -> LocalOutboxOperation {
        try upsertOperation(
            kind: .dailyEntrySubmit,
            entryDate: entryDate,
            draft: nil,
            entryID: entryID,
            lastError: lastError
        )
    }

    func deleteOperations(kind: LocalOutboxOperationKind, entryDate: String) throws {
        let remaining = try loadOperations().filter {
            !($0.kind == kind && $0.entryDate == entryDate)
        }
        try saveOperations(remaining)
    }

    func deleteOperation(id: UUID) throws {
        let remaining = try loadOperations().filter { $0.id != id }
        try saveOperations(remaining)
    }

    func deleteAll() throws {
        try secureStore.deleteDirectory(at: storageDirectory())
    }

    func deleteEncryptionKey() throws {
        try secureStore.deleteEncryptionKey()
    }

    private func upsertOperation(
        kind: LocalOutboxOperationKind,
        entryDate: String,
        draft: DailyEntryDraft?,
        entryID: String?,
        lastError: String?
    ) throws -> LocalOutboxOperation {
        var operations = try loadOperations()
        let now = Date()

        if let index = operations.firstIndex(where: { $0.kind == kind && $0.entryDate == entryDate }) {
            let existing = operations[index]
            let updated = LocalOutboxOperation(
                id: existing.id,
                kind: kind,
                entryDate: entryDate,
                draft: draft ?? existing.draft,
                entryID: entryID ?? existing.entryID,
                createdAt: existing.createdAt,
                updatedAt: now,
                attemptCount: existing.attemptCount + 1,
                lastError: lastError
            )
            operations[index] = updated
            try saveOperations(operations)
            return updated
        }

        let operation = LocalOutboxOperation(
            id: UUID(),
            kind: kind,
            entryDate: entryDate,
            draft: draft,
            entryID: entryID,
            createdAt: now,
            updatedAt: now,
            attemptCount: 0,
            lastError: lastError
        )
        operations.append(operation)
        try saveOperations(operations)
        return operation
    }

    private func loadOperations() throws -> [LocalOutboxOperation] {
        try secureStore.load([LocalOutboxOperation].self, from: outboxURL()) ?? []
    }

    private func saveOperations(_ operations: [LocalOutboxOperation]) throws {
        try secureStore.save(operations, to: outboxURL())
    }

    private func outboxURL() throws -> URL {
        try storageDirectory().appendingPathComponent("operations.json", isDirectory: false)
    }

    private func storageDirectory() throws -> URL {
        let supportDirectory = try supportDirectory()
        let directory = supportDirectory
            .appendingPathComponent("COPE", isDirectory: true)
            .appendingPathComponent("Outbox", isDirectory: true)

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try fileManager.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: directory.path)
        return directory
    }

    private func supportDirectory() throws -> URL {
        if let baseDirectory {
            return baseDirectory
        }

        return try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }
}
