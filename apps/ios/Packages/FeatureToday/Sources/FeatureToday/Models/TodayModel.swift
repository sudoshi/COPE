import Foundation

/// Presentation model for the Today dashboard. The app layer maps API responses
/// into this; views render it. `.sample` is the demo content used for previews
/// and the mock build until real data is wired.
public struct TodayModel: Sendable, Equatable {
    public var greeting: String          // e.g. "Tuesday · Good morning"
    public var name: String              // e.g. "Maya"
    public var heroLabel: String         // e.g. "Morning check-in"
    public var heroQuestion: String
    public var heroSubtitle: String
    public var streakDays: Int
    public var streakDetail: String      // e.g. "days · 1 freeze left"
    public var weekMoods: [Int]          // 7 values, 1...10
    public var tasks: [TodayTask]

    public init(
        greeting: String,
        name: String,
        heroLabel: String,
        heroQuestion: String,
        heroSubtitle: String,
        streakDays: Int,
        streakDetail: String,
        weekMoods: [Int],
        tasks: [TodayTask]
    ) {
        self.greeting = greeting
        self.name = name
        self.heroLabel = heroLabel
        self.heroQuestion = heroQuestion
        self.heroSubtitle = heroSubtitle
        self.streakDays = streakDays
        self.streakDetail = streakDetail
        self.weekMoods = weekMoods
        self.tasks = tasks
    }

    public var avatarInitial: String { String(name.first ?? "·") }
}

public struct TodayTask: Identifiable, Sendable, Equatable {
    public enum Kind: Sendable, Equatable { case medications, assessment, message, preVisit }

    public var id: String
    public var kind: Kind
    public var title: String
    public var subtitle: String
    public var badge: String?
    public var showsUnread: Bool

    public init(id: String, kind: Kind, title: String, subtitle: String, badge: String? = nil, showsUnread: Bool = false) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.showsUnread = showsUnread
    }
}

public extension TodayModel {
    static let sample = TodayModel(
        greeting: "Tuesday · Good morning",
        name: "Maya",
        heroLabel: "Morning check-in",
        heroQuestion: "How are you feeling today?",
        heroSubtitle: "A gentle 2-minute reflection. Just where you are — no right answers.",
        streakDays: 11,
        streakDetail: "days · 1 freeze left",
        weekMoods: [3, 5, 4, 7, 6, 8, 7],
        tasks: [
            TodayTask(id: "meds", kind: .medications, title: "Morning medications",
                      subtitle: "Lamotrigine · Sertraline · 1 of 3 taken", badge: "2 due"),
            TodayTask(id: "phq9", kind: .assessment, title: "Weekly PHQ-9 check",
                      subtitle: "From Dr. Alvarez · 5 minutes · due today"),
            TodayTask(id: "msg", kind: .message, title: "Dr. Alvarez replied",
                      subtitle: "“So glad the new dose is settling in…”", showsUnread: true),
            TodayTask(id: "previsit", kind: .preVisit, title: "Visit Thursday — let's prepare",
                      subtitle: "Pick what to talk about with Dr. Alvarez")
        ]
    )
}
