import SwiftUI
import FeatureToday

/// Fetches the authenticated patient's data from the API, maps it into the
/// gold-standard presentation models, and persists check-ins. Today is wired to
/// real data (name, streak, greeting, check-in status, pending assessments);
/// other screens use sample content until their endpoints land.
@MainActor
final class PatientHomeStore: ObservableObject {
    @Published private(set) var today: TodayModel
    @Published private(set) var profile: ProfileModel

    private let apiClient: APIClient
    private let patient: PatientProfileSummary

    init(apiClient: APIClient, patient: PatientProfileSummary) {
        self.apiClient = apiClient
        self.patient = patient
        self.today = Self.baseToday(patient)
        self.profile = Self.profileModel(patient)
    }

    func load() async {
        let todayEntry = try? await apiClient.todayDailyEntry()
        let pending = (try? await apiClient.pendingAssessments()) ?? []

        var model = Self.baseToday(patient)
        var tasks: [TodayTask] = pending.map { assessment in
            TodayTask(
                id: "assessment-\(assessment.scale)",
                kind: .assessment,
                title: "\(assessment.scale) check",
                subtitle: "From your care team · about \(assessment.intervalDays == 7 ? "5 minutes" : "a few minutes")"
            )
        }
        // Entry points to screens not yet backed by live data.
        tasks.append(TodayTask(id: "meds", kind: .medications, title: "Today's medications",
                               subtitle: "Tap to review and log your doses"))
        tasks.append(TodayTask(id: "previsit", kind: .preVisit, title: "Before your next visit",
                               subtitle: "Choose what to talk about"))
        model.tasks = tasks

        if let entry = todayEntry, entry.isSubmitted {
            model.heroLabel = "Today's check-in"
            model.heroQuestion = "You've checked in today."
            model.heroSubtitle = "Thank you for showing up for yourself. Tap to revisit or add a note."
        }
        today = model
    }

    func submitCheckIn(_ result: CheckInResult) async {
        let draft = DailyEntryDraft(
            entryDate: Self.todayString(),
            moodScore: result.mood,
            sleepHours: result.sleepHours,
            anxietyScore: result.anxiety,
            stressScore: nil,
            suicidalIdeation: result.suicidalIdeation,
            notes: result.note.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
        do {
            let saved = try await apiClient.saveDailyEntry(draft)
            _ = try? await apiClient.submitDailyEntry(id: saved.id)
            await load()
        } catch {
            // Submission failures are non-fatal here; the dedicated outbox path
            // (TodayViewModel) handles offline queueing.
        }
    }

    // MARK: Mapping

    private static func baseToday(_ patient: PatientProfileSummary) -> TodayModel {
        var model = TodayModel.sample
        model.name = patient.displayName.split(separator: " ").first.map(String.init) ?? patient.displayName
        model.greeting = greetingLine()
        model.streakDays = patient.trackingStreak
        return model
    }

    private static func profileModel(_ patient: PatientProfileSummary) -> ProfileModel {
        var model = ProfileModel.sample
        model.name = patient.displayName
        return model
    }

    private static func greetingLine() -> String {
        let now = Date()
        let weekday = now.formatted(.dateTime.weekday(.wide))
        let hour = Calendar.current.component(.hour, from: now)
        let timeOfDay = hour < 12 ? "Good morning" : (hour < 17 ? "Good afternoon" : "Good evening")
        return "\(weekday) · \(timeOfDay)"
    }

    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

struct AuthenticatedHomeView: View {
    @StateObject private var store: PatientHomeStore

    init(apiClient: APIClient, patient: PatientProfileSummary) {
        _store = StateObject(wrappedValue: PatientHomeStore(apiClient: apiClient, patient: patient))
    }

    var body: some View {
        MainShellView(
            today: store.today,
            profile: store.profile,
            onCheckInSubmit: { result in Task { await store.submitCheckIn(result) } }
        )
        .task { await store.load() }
    }
}
