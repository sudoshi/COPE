import Foundation

/// Presentation model for Journal (build bible §6.10).
public struct JournalModel: Sendable, Equatable {
    public var prompt: String
    public var entries: [JournalEntry]
    public init(prompt: String, entries: [JournalEntry]) {
        self.prompt = prompt; self.entries = entries
    }
}

public struct JournalEntry: Identifiable, Sendable, Equatable {
    public var id: String
    public var moodHex: UInt32         // mood dot color, e.g. 0x8FC08C
    public var meta: String            // "Yesterday · 9:40 PM"
    public var shared: Bool
    public var voice: Bool
    public var title: String
    public var excerpt: String
    public init(id: String, moodHex: UInt32, meta: String, shared: Bool, voice: Bool, title: String, excerpt: String) {
        self.id = id; self.moodHex = moodHex; self.meta = meta
        self.shared = shared; self.voice = voice; self.title = title; self.excerpt = excerpt
    }
}

public extension JournalModel {
    static let sample = JournalModel(
        prompt: "What's one small thing that felt okay today?",
        entries: [
            JournalEntry(id: "1", moodHex: 0x8FC08C, meta: "Yesterday · 9:40 PM", shared: true, voice: false,
                         title: "A better Tuesday",
                         excerpt: "Got out for a walk before the rain. Felt the first bit of lightness in a while…"),
            JournalEntry(id: "2", moodHex: 0xE3A93F, meta: "Sunday · 8:12 AM", shared: false, voice: true,
                         title: "Couldn't sleep again",
                         excerpt: "Mind wouldn't settle. Tried the breathing thing Sam showed me…")
        ]
    )
}
