import Foundation

/// Presentation model for Care / secure messaging (build bible §6.6).
public struct CareModel: Sendable, Equatable {
    public var teamInitials: [String]      // overlapped avatars, e.g. ["A", "S"]
    public var teamName: String
    public var statusLine: String
    public var dayLabel: String
    public var escalation: Escalation?
    public var messages: [CareMessage]

    public init(teamInitials: [String], teamName: String, statusLine: String, dayLabel: String, escalation: Escalation?, messages: [CareMessage]) {
        self.teamInitials = teamInitials; self.teamName = teamName; self.statusLine = statusLine
        self.dayLabel = dayLabel; self.escalation = escalation; self.messages = messages
    }

    public struct Escalation: Sendable, Equatable {
        public var title: String
        public var body: String
        public init(title: String, body: String) { self.title = title; self.body = body }
    }
}

public struct CareMessage: Identifiable, Sendable, Equatable {
    public enum Role: Sendable, Equatable { case clinician, patient, prompt }
    public var id: String
    public var role: Role
    public var text: String                // bubble body, or the prompt question
    public var time: String                // bubble timestamp (empty for prompts)
    public var promptLabel: String?        // e.g. "Quick check-in"
    public var replies: [String]           // structured quick replies

    public init(id: String, role: Role, text: String, time: String = "", promptLabel: String? = nil, replies: [String] = []) {
        self.id = id; self.role = role; self.text = text; self.time = time
        self.promptLabel = promptLabel; self.replies = replies
    }
}

public extension CareModel {
    static let sample = CareModel(
        teamInitials: ["A", "S"],
        teamName: "Your care team",
        statusLine: "Usually replies within 1 business day",
        dayLabel: "Tuesday",
        escalation: Escalation(
            title: "Your team is looking out for you",
            body: "After this morning's check-in, Sam was notified and will reach out today. You don't need to do anything."
        ),
        messages: [
            CareMessage(id: "1", role: .clinician,
                        text: "So glad the new dose is settling in. How have your mornings felt since we adjusted it?",
                        time: "Dr. Alvarez · 9:02"),
            CareMessage(id: "2", role: .prompt, text: "How are mornings feeling on the new dose?",
                        promptLabel: "Quick check-in", replies: ["Better", "Same", "Worse"]),
            CareMessage(id: "3", role: .patient,
                        text: "Better, honestly. Waking up feels less heavy. Still a rough patch around Wednesdays.",
                        time: "You · 9:14 · Read")
        ]
    )
}
