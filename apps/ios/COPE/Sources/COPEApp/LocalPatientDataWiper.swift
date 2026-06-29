import Foundation

struct LocalPatientDataWiper {
    static let shared = LocalPatientDataWiper()

    private let draftStore: DailyEntryDraftStore
    private let outboxStore: LocalOutboxStore

    init(
        draftStore: DailyEntryDraftStore = .shared,
        outboxStore: LocalOutboxStore = .shared
    ) {
        self.draftStore = draftStore
        self.outboxStore = outboxStore
    }

    func wipe() async {
        try? await draftStore.deleteAllDrafts()
        try? await outboxStore.deleteAll()
        try? await outboxStore.deleteEncryptionKey()
    }
}
