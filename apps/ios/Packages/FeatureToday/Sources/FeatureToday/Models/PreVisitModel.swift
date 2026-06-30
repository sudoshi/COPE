import Foundation

/// Presentation model for Pre-visit prep (build bible §6.12).
public struct PreVisitModel: Sendable, Equatable {
    public var clinician: String
    public var appointment: String       // "Thursday, Jun 26 · 2:00 PM · Telehealth"
    public var intro: String
    public var stats: [PreVisitStat]      // expects 3: mood, sleep, PHQ-9
    public var flagTitle: String
    public var agenda: [PreVisitItem]

    public init(clinician: String, appointment: String, intro: String, stats: [PreVisitStat], flagTitle: String, agenda: [PreVisitItem]) {
        self.clinician = clinician; self.appointment = appointment; self.intro = intro
        self.stats = stats; self.flagTitle = flagTitle; self.agenda = agenda
    }
}

public struct PreVisitStat: Identifiable, Sendable, Equatable {
    public var id: String
    public var title: String
    public var value: String
    public var note: String
    public var notePositive: Bool        // teal note when true, muted otherwise
    public init(id: String, title: String, value: String, note: String, notePositive: Bool) {
        self.id = id; self.title = title; self.value = value; self.note = note; self.notePositive = notePositive
    }
}

public struct PreVisitItem: Identifiable, Sendable, Equatable {
    public var id: String
    public var label: String
    public var sub: String
    public var includedByDefault: Bool
    public init(id: String, label: String, sub: String, includedByDefault: Bool) {
        self.id = id; self.label = label; self.sub = sub; self.includedByDefault = includedByDefault
    }
}

public extension PreVisitModel {
    static let sample = PreVisitModel(
        clinician: "Dr. Alvarez",
        appointment: "Thursday, Jun 26 · 2:00 PM · Telehealth",
        intro: "A quiet summary of your two weeks. Choose what you want to make sure you talk about — it'll be ready before you meet, so you don't have to find the words in the moment.",
        stats: [
            PreVisitStat(id: "mood", title: "Mood", value: "4.8→6.4", note: "↑ trending up", notePositive: true),
            PreVisitStat(id: "sleep", title: "Sleep", value: "6.8h", note: "steadier than before", notePositive: false),
            PreVisitStat(id: "phq9", title: "PHQ-9", value: "14→9", note: "↓ improving", notePositive: true)
        ],
        flagTitle: "Anxiety still spikes midweek",
        agenda: [
            PreVisitItem(id: "dose", label: "The new dose & my mornings", sub: "You noted mornings feel lighter", includedByDefault: true),
            PreVisitItem(id: "anx", label: "Anxiety midweek", sub: "Spikes around Wednesdays", includedByDefault: true),
            PreVisitItem(id: "sleep", label: "Sleep still uneven", sub: "Avg 6.8h · a few restless nights", includedByDefault: false),
            PreVisitItem(id: "side", label: "A side effect to mention", sub: "Optional — add if it comes up", includedByDefault: false)
        ]
    )
}
