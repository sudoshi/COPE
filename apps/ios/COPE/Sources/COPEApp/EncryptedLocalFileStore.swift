import CryptoKit
import Foundation
import Security

final class LocalEncryptionKeyStore {
    private let service: String
    private let account: String

    init(
        service: String = "\(Bundle.main.bundleIdentifier ?? "com.cope.app").local-encryption",
        account: String = "cope.local.persistence.key"
    ) {
        self.service = service
        self.account = account
    }

    func loadOrCreateKey() throws -> SymmetricKey {
        if let storedKey = try loadKeyData() {
            return SymmetricKey(data: storedKey)
        }

        var bytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            throw LocalPersistenceError.keyGenerationFailed
        }

        let data = Data(bytes)
        try saveKeyData(data)
        return SymmetricKey(data: data)
    }

    func deleteKey() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw LocalPersistenceError.keychainStatus(status)
        }
    }

    private func loadKeyData() throws -> Data? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw LocalPersistenceError.keychainStatus(status)
        }

        guard let data = result as? Data, data.count == 32 else {
            throw LocalPersistenceError.invalidKeyData
        }

        return data
    }

    private func saveKeyData(_ data: Data) throws {
        var attributes = baseQuery
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let updateStatus = SecItemUpdate(
                baseQuery as CFDictionary,
                [kSecValueData as String: data] as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw LocalPersistenceError.keychainStatus(updateStatus)
            }
            return
        }

        guard status == errSecSuccess else {
            throw LocalPersistenceError.keychainStatus(status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

final class EncryptedLocalFileStore {
    private let fileManager: FileManager
    private let keyStore: LocalEncryptionKeyStore
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileManager: FileManager = .default,
        keyStore: LocalEncryptionKeyStore = LocalEncryptionKeyStore()
    ) {
        self.fileManager = fileManager
        self.keyStore = keyStore
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func load<Value: Codable>(_ type: Value.Type, from url: URL, allowPlaintextMigration: Bool = true) throws -> Value? {
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        let storedData = try Data(contentsOf: url)
        do {
            let decrypted = try decrypt(storedData)
            return try decoder.decode(type, from: decrypted)
        } catch {
            guard allowPlaintextMigration else {
                throw error
            }

            let value = try decoder.decode(type, from: storedData)
            try save(value, to: url)
            return value
        }
    }

    func save<Value: Encodable>(_ value: Value, to url: URL) throws {
        let data = try encoder.encode(value)
        let encrypted = try encrypt(data)

        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try encrypted.write(to: url, options: [.atomic])
        try fileManager.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path)
    }

    func deleteFile(at url: URL) throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        try fileManager.removeItem(at: url)
    }

    func deleteDirectory(at url: URL) throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        try fileManager.removeItem(at: url)
    }

    func deleteEncryptionKey() throws {
        try keyStore.deleteKey()
    }

    private func encrypt(_ data: Data) throws -> Data {
        let key = try keyStore.loadOrCreateKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw LocalPersistenceError.encryptionFailed
        }
        return combined
    }

    private func decrypt(_ data: Data) throws -> Data {
        let key = try keyStore.loadOrCreateKey()
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
}

enum LocalPersistenceError: Error, LocalizedError {
    case encryptionFailed
    case keyGenerationFailed
    case invalidKeyData
    case keychainStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "Local data could not be encrypted."
        case .keyGenerationFailed:
            return "A local encryption key could not be created."
        case .invalidKeyData:
            return "The local encryption key is invalid."
        case let .keychainStatus(status):
            return "Keychain returned status \(status)."
        }
    }
}
