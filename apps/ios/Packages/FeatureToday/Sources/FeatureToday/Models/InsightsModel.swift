import Foundation

/// Presentation model for the Insights tab (build bible §6.7).
public struct InsightsModel: Sendable, Equatable {
    public var mood: [Double]            // ~14 points, 0...10
    public var moodStartLabel: String    // e.g. "Jun 8"
    public var moodEndLabel: String      // e.g. "Today"
    public var correlationLead: String
    public var correlationHighlight: String
    public var correlationTail: String
    public var sleepAvg: String          // e.g. "6.8"
    public var sleepBars: [Double]       // relative heights 0...1
    public var phq9Score: String         // e.g. "9"
    public var phq9Delta: String         // e.g. "↓ from 14"
    public var phq9Note: String
    public var aiReflection: String

    public init(
        mood: [Double], moodStartLabel: String, moodEndLabel: String,
        correlationLead: String, correlationHighlight: String, correlationTail: String,
        sleepAvg: String, sleepBars: [Double],
        phq9Score: String, phq9Delta: String, phq9Note: String,
        aiReflection: String
    ) {
        self.mood = mood
        self.moodStartLabel = moodStartLabel
        self.moodEndLabel = moodEndLabel
        self.correlationLead = correlationLead
        self.correlationHighlight = correlationHighlight
        self.correlationTail = correlationTail
        self.sleepAvg = sleepAvg
        self.sleepBars = sleepBars
        self.phq9Score = phq9Score
        self.phq9Delta = phq9Delta
        self.phq9Note = phq9Note
        self.aiReflection = aiReflection
    }
}

public extension InsightsModel {
    static let sample = InsightsModel(
        mood: [4.8, 4.5, 5.0, 4.6, 5.4, 5.0, 5.8, 6.0, 5.6, 6.4, 6.2, 6.6, 6.4, 7.0],
        moodStartLabel: "Jun 8",
        moodEndLabel: "Today",
        correlationLead: "On days you moved your body, your mood the next morning was ",
        correlationHighlight: "+1.8 higher",
        correlationTail: " on average.",
        sleepAvg: "6.8",
        sleepBars: [0.6, 0.8, 0.5, 0.9, 0.7, 0.85],
        phq9Score: "9",
        phq9Delta: "↓ from 14",
        phq9Note: "Moving from moderate toward mild",
        aiReflection: "Your sleep steadied this week and your mornings trended brighter. Anxiety still rises midweek — worth a word with Dr. Alvarez."
    )
}
