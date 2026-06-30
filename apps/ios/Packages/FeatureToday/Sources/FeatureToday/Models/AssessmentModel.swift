import Foundation

/// Definition of a validated assessment (build bible §6.8/§13). Items/options
/// and framing come from the model; scoring + interpretation bands stay in the
/// view for now (move to CopeCore with golden tests later).
public struct AssessmentModel: Sendable, Equatable {
    public var scaleName: String
    public var introTitle: String
    public var introBody: String
    public var framingLead: String       // bolded clause, e.g. "Over the last 2 weeks,"
    public var framingBody: String
    public var items: [String]
    public var options: [String]
    public var maxScore: Int
    public var suicideItemIndex: Int?     // item that triggers the safety handoff
    public var sharedWith: String
    public var priorComparison: String

    public init(scaleName: String, introTitle: String, introBody: String, framingLead: String, framingBody: String, items: [String], options: [String], maxScore: Int, suicideItemIndex: Int?, sharedWith: String, priorComparison: String) {
        self.scaleName = scaleName; self.introTitle = introTitle; self.introBody = introBody
        self.framingLead = framingLead; self.framingBody = framingBody
        self.items = items; self.options = options; self.maxScore = maxScore
        self.suicideItemIndex = suicideItemIndex; self.sharedWith = sharedWith; self.priorComparison = priorComparison
    }
}

public extension AssessmentModel {
    static let phq9 = AssessmentModel(
        scaleName: "PHQ-9",
        introTitle: "A weekly check on your mood",
        introBody: "Dr. Alvarez asked for this so your care can stay tuned to how you're really doing. Nine questions, about five minutes.",
        framingLead: "Over the last 2 weeks,",
        framingBody: " how often have you been bothered by each of the following?",
        items: [
            "Little interest or pleasure in doing things",
            "Feeling down, depressed, or hopeless",
            "Trouble falling or staying asleep, or sleeping too much",
            "Feeling tired or having little energy",
            "Poor appetite or overeating",
            "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
            "Trouble concentrating on things, such as reading or watching television",
            "Moving or speaking so slowly that other people could have noticed — or being so restless that you have been moving around a lot more than usual",
            "Thoughts that you would be better off dead, or of hurting yourself in some way"
        ],
        options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
        maxScore: 27,
        suicideItemIndex: 8,
        sharedWith: "Dr. Alvarez",
        priorComparison: "Compared to 14 two weeks ago — you're trending toward milder symptoms."
    )
}

/// The data a completed check-in emits for persistence (the app maps this to the
/// daily-entry API + outbox).
public struct CheckInResult: Sendable, Equatable {
    public var mood: Int
    public var feelings: [String]
    public var sleepHours: Double
    public var sleepQuality: Int?
    public var energy: Int
    public var anhedonia: Int?
    public var anxiety: Int
    public var bodyRegions: [String]
    public var bodyAllOver: Bool
    public var mania: Int?
    public var triggers: [String]
    public var suicidalIdeation: Int?
    public var note: String

    public init(mood: Int, feelings: [String], sleepHours: Double, sleepQuality: Int?, energy: Int, anhedonia: Int?, anxiety: Int, bodyRegions: [String], bodyAllOver: Bool, mania: Int?, triggers: [String], suicidalIdeation: Int?, note: String) {
        self.mood = mood; self.feelings = feelings; self.sleepHours = sleepHours; self.sleepQuality = sleepQuality
        self.energy = energy; self.anhedonia = anhedonia; self.anxiety = anxiety
        self.bodyRegions = bodyRegions; self.bodyAllOver = bodyAllOver; self.mania = mania
        self.triggers = triggers; self.suicidalIdeation = suicidalIdeation; self.note = note
    }
}
