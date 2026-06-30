import Foundation

/// Presentation model for Medications (build bible §6.9).
public struct MedicationsModel: Sendable, Equatable {
    public var summaryNote: String
    public var groups: [MedGroup]

    public init(summaryNote: String, groups: [MedGroup]) {
        self.summaryNote = summaryNote
        self.groups = groups
    }

    public var allMeds: [Medication] { groups.flatMap(\.meds) }
    public var total: Int { allMeds.count }
}

public struct MedGroup: Identifiable, Sendable, Equatable {
    public var id: String
    public var time: String            // e.g. "Morning · 8:00 AM"
    public var meds: [Medication]
    public init(id: String, time: String, meds: [Medication]) {
        self.id = id; self.time = time; self.meds = meds
    }
}

public struct Medication: Identifiable, Sendable, Equatable {
    public var id: String
    public var name: String
    public var dose: String            // e.g. "200 mg · 1 tablet"
    public var isEvening: Bool         // clay tint when evening, else teal
    public var taken: Bool
    public init(id: String, name: String, dose: String, isEvening: Bool, taken: Bool) {
        self.id = id; self.name = name; self.dose = dose; self.isEvening = isEvening; self.taken = taken
    }
}

public extension MedicationsModel {
    static let sample = MedicationsModel(
        summaryNote: "Keeping a steady rhythm helps your levels stay even.",
        groups: [
            MedGroup(id: "morning", time: "Morning · 8:00 AM", meds: [
                Medication(id: "lam", name: "Lamotrigine", dose: "200 mg · 1 tablet", isEvening: false, taken: false),
                Medication(id: "ser", name: "Sertraline", dose: "100 mg · 1 tablet", isEvening: false, taken: true)
            ]),
            MedGroup(id: "evening", time: "Evening · 9:00 PM", meds: [
                Medication(id: "abi", name: "Aripiprazole", dose: "5 mg · 1 tablet", isEvening: true, taken: false)
            ])
        ]
    )
}
