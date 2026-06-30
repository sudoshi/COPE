import Foundation
import Observation

/// Step-machine for the daily check-in hero (build bible §6.4). One question per
/// screen; the mania step is adaptive (shown only for bipolar-flagged patients).
@MainActor
@Observable
final class CheckInViewModel {
    enum Step: CaseIterable {
        case mood, feelings, sleep, energy, anxiety, body, mania, triggers, safety, reflection
    }

    // MARK: Inputs
    var stepIndex = 0
    var mood: Double = 6
    var feelings: Set<String> = []
    var sleepHours: Double = 7
    var sleepQuality: Int? = nil          // 1 restless · 2 okay · 3 restful
    var energy: Double = 6
    var anhedonia: Int? = nil             // 0 yes, mostly · 1 a little less · 2 not really
    var anxiety: Double = 3
    var bodyRegions: Set<String> = []
    var bodyAllOver = false
    var mania: Int? = nil                 // 0 not at all · 1 a little · 2 quite a bit
    var triggers: Set<String> = []
    var suicidalIdeation: Int? = nil      // 0…3 (C-SSRS gentle)
    var note: String = ""

    /// Adaptive: bipolar-flagged care plans see the mania (energy regulation) step.
    let isBipolar: Bool

    init(isBipolar: Bool = true) {
        self.isBipolar = isBipolar
    }

    // MARK: Flow
    var steps: [Step] {
        Step.allCases.filter { $0 != .mania || isBipolar }
    }
    var currentStep: Step { steps[min(stepIndex, steps.count - 1)] }
    var isLastStep: Bool { stepIndex >= steps.count - 1 }
    var progress: Double { Double(stepIndex + 1) / Double(steps.count) }
    var ctaTitle: String { isLastStep ? "Complete check-in" : "Continue" }
    var stepLabel: String { "Step \(stepIndex + 1) of \(steps.count) · \(currentStep.title)" }

    /// Advance; returns true when the flow is complete (caller should dismiss/submit).
    func advance() -> Bool {
        guard !isLastStep else { return true }
        stepIndex += 1
        return false
    }

    /// Go back; returns true when at the first step (caller should dismiss).
    func goBack() -> Bool {
        guard stepIndex > 0 else { return true }
        stepIndex -= 1
        return false
    }

    // MARK: Display helpers
    var moodValue: Int { Int(mood.rounded()) }
    var energyValue: Int { Int(energy.rounded()) }
    var anxietyValue: Int { Int(anxiety.rounded()) }
    var siElevated: Bool { (suicidalIdeation ?? 0) >= 2 }

    /// The collected check-in, for the app to persist (daily-entry API + outbox).
    var result: CheckInResult {
        CheckInResult(
            mood: moodValue,
            feelings: feelings.sorted(),
            sleepHours: sleepHours,
            sleepQuality: sleepQuality,
            energy: energyValue,
            anhedonia: anhedonia,
            anxiety: anxietyValue,
            bodyRegions: bodyRegions.sorted(),
            bodyAllOver: bodyAllOver,
            mania: mania,
            triggers: triggers.sorted(),
            suicidalIdeation: suicidalIdeation,
            note: note
        )
    }

    var energyWord: String { Self.energyWords[clamp(energyValue, Self.energyWords.count)] }
    var anxietyWord: String { Self.anxietyWords[clamp(anxietyValue, Self.anxietyWords.count)] }

    var bodySummary: String {
        var parts = Self.bodyOrder.filter { bodyRegions.contains($0.key) }.map(\.label)
        if bodyAllOver { parts.append("All over") }
        return parts.isEmpty ? "Tap wherever you notice it" : parts.joined(separator: " · ")
    }

    private func clamp(_ value: Int, _ count: Int) -> Int { min(max(0, value), count - 1) }

    static let energyWords = ["Depleted", "Very low", "Low", "Limited", "Building", "Some", "Steady", "Good", "High", "Very high", "Abundant"]
    static let anxietyWords = ["Calm", "Calm", "Mostly settled", "A little tense", "Tense", "Noticeably anxious", "Anxious", "Quite anxious", "Very anxious", "Very anxious", "Overwhelmed"]
    static let feelingWords = ["Numb", "On edge", "Heavy", "Hollow", "Wired but tired", "Foggy", "Restless", "Overwhelmed", "Irritable", "Disconnected", "Lonely", "Ashamed", "Hopeful", "Calm"]
    static let triggerWords = ["Work / school", "Relationships", "Sleep", "Money", "Health", "Substance use", "Feeling alone"]
    static let bodyOrder: [(key: String, label: String)] = [
        ("head", "Head"), ("chest", "Chest"), ("stomach", "Stomach"), ("arms", "Arms"), ("legs", "Legs")
    ]
}

extension CheckInViewModel.Step {
    var title: String {
        switch self {
        case .mood: return "Mood"
        case .feelings: return "In words"
        case .sleep: return "Sleep"
        case .energy: return "Energy & interest"
        case .anxiety: return "Anxiety"
        case .body: return "Where you feel it"
        case .mania: return "Energy regulation"
        case .triggers: return "What's present"
        case .safety: return "Safety"
        case .reflection: return "Reflection"
        }
    }
}
