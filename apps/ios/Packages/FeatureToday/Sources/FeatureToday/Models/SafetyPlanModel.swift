import Foundation

/// Presentation model for the Stanley-Brown safety plan (build bible §6.5).
public struct SafetyPlanModel: Sendable, Equatable {
    public var crisisHeadline: String
    public var crisisSubtitle: String
    public var builtWith: String
    public var warningSigns: String
    public var copingStrategies: String
    public var reasons: [String]
    public var contacts: [SafetyContact]
    public var saferSpace: String

    public init(crisisHeadline: String, crisisSubtitle: String, builtWith: String, warningSigns: String, copingStrategies: String, reasons: [String], contacts: [SafetyContact], saferSpace: String) {
        self.crisisHeadline = crisisHeadline; self.crisisSubtitle = crisisSubtitle; self.builtWith = builtWith
        self.warningSigns = warningSigns; self.copingStrategies = copingStrategies; self.reasons = reasons
        self.contacts = contacts; self.saferSpace = saferSpace
    }
}

public struct SafetyContact: Identifiable, Sendable, Equatable {
    public var id: String
    public var initial: String
    public var name: String
    public var subtitle: String
    public init(id: String, initial: String, name: String, subtitle: String) {
        self.id = id; self.initial = initial; self.name = name; self.subtitle = subtitle
    }
}

public extension SafetyPlanModel {
    static let sample = SafetyPlanModel(
        crisisHeadline: "If you're in crisis right now",
        crisisSubtitle: "You deserve support this moment.",
        builtWith: "Built with Dr. Alvarez · Stanley-Brown safety plan",
        warningSigns: "Racing thoughts late at night · Skipping meals · Pulling away from friends",
        copingStrategies: "Walk by the water · Cold shower · Box breathing · Playlist “anchor”",
        reasons: ["My sister Nora", "Finishing my degree", "Pico (my dog)"],
        contacts: [SafetyContact(id: "nora", initial: "N", name: "Nora (sister)", subtitle: "Tap to call")],
        saferSpace: "Medications stored with Nora · Crisis numbers saved to favorites"
    )
}
