import Foundation

struct CachedSafetyResources: Codable, Equatable {
    let response: SafetyResourcesResponse
    let updatedAt: Date
}

actor SafetyResourceCacheStore {
    static let shared = SafetyResourceCacheStore()

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

    func loadResources() throws -> CachedSafetyResources? {
        try secureStore.load(CachedSafetyResources.self, from: resourcesURL())
    }

    @discardableResult
    func saveResources(_ response: SafetyResourcesResponse) throws -> CachedSafetyResources {
        let record = CachedSafetyResources(response: response, updatedAt: Date())
        try secureStore.save(record, to: resourcesURL())
        return record
    }

    func deleteResources() throws {
        try secureStore.deleteFile(at: resourcesURL())
    }

    private func resourcesURL() throws -> URL {
        try storageDirectory().appendingPathComponent("resources.json", isDirectory: false)
    }

    private func storageDirectory() throws -> URL {
        let supportDirectory = try supportDirectory()
        let directory = supportDirectory
            .appendingPathComponent("COPE", isDirectory: true)
            .appendingPathComponent("SafetyResources", isDirectory: true)

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
