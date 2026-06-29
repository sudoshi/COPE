import Foundation

struct StoredDailyEntryDraft: Codable, Equatable {
    let draft: DailyEntryDraft
    let updatedAt: Date
    let pendingServerSave: Bool
}

actor DailyEntryDraftStore {
    static let shared = DailyEntryDraftStore()

    private let fileManager: FileManager
    private let secureStore: EncryptedLocalFileStore

    init(
        fileManager: FileManager = .default,
        secureStore: EncryptedLocalFileStore = EncryptedLocalFileStore()
    ) {
        self.fileManager = fileManager
        self.secureStore = secureStore
    }

    func loadDraft(for entryDate: String) throws -> StoredDailyEntryDraft? {
        let url = try draftURL(for: entryDate)
        return try secureStore.load(StoredDailyEntryDraft.self, from: url)
    }

    @discardableResult
    func saveDraft(_ draft: DailyEntryDraft, pendingServerSave: Bool) throws -> StoredDailyEntryDraft {
        let record = StoredDailyEntryDraft(
            draft: draft,
            updatedAt: Date(),
            pendingServerSave: pendingServerSave
        )
        let url = try draftURL(for: draft.entryDate)

        try secureStore.save(record, to: url)
        return record
    }

    func deleteDraft(for entryDate: String) throws {
        let url = try draftURL(for: entryDate)
        try secureStore.deleteFile(at: url)
    }

    func deleteAllDrafts() throws {
        try secureStore.deleteDirectory(at: storageDirectory())
    }

    private func draftURL(for entryDate: String) throws -> URL {
        try storageDirectory().appendingPathComponent("\(entryDate).json", isDirectory: false)
    }

    private func storageDirectory() throws -> URL {
        let supportDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = supportDirectory
            .appendingPathComponent("COPE", isDirectory: true)
            .appendingPathComponent("DailyEntryDrafts", isDirectory: true)

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try fileManager.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: directory.path)
        return directory
    }
}
