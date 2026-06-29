import Foundation

struct StoredDailyEntryDraft: Codable, Equatable {
    let draft: DailyEntryDraft
    let updatedAt: Date
    let pendingServerSave: Bool
}

actor DailyEntryDraftStore {
    static let shared = DailyEntryDraftStore()

    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadDraft(for entryDate: String) throws -> StoredDailyEntryDraft? {
        let url = try draftURL(for: entryDate)
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode(StoredDailyEntryDraft.self, from: data)
    }

    @discardableResult
    func saveDraft(_ draft: DailyEntryDraft, pendingServerSave: Bool) throws -> StoredDailyEntryDraft {
        let record = StoredDailyEntryDraft(
            draft: draft,
            updatedAt: Date(),
            pendingServerSave: pendingServerSave
        )
        let url = try draftURL(for: draft.entryDate)
        let data = try encoder.encode(record)

        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: [.atomic])
        try fileManager.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path)
        return record
    }

    func deleteDraft(for entryDate: String) throws {
        let url = try draftURL(for: entryDate)
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        try fileManager.removeItem(at: url)
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
