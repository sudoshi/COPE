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
    @Published private(set) var journal: JournalModel = .sample
    @Published private(set) var medications: MedicationsModel = .sample

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

        if let medItems = try? await apiClient.medicationsToday() {
            medications = Self.medicationsModel(medItems)
        }
        if let journalItems = try? await apiClient.journalEntries() {
            journal = Self.journalModel(journalItems)
        }

        var model = Self.baseToday(patient)
        var tasks: [TodayTask] = pending.map { assessment in
            TodayTask(
                id: "assessment-\(assessment.scale)",
                kind: .assessment,
                title: "\(assessment.scale) check",
                subtitle: "From your care team · about \(assessment.intervalDays == 7 ? "5 minutes" : "a few minutes")"
            )
        }
        let totalMeds = medications.total
        let takenMeds = medications.allMeds.filter(\.taken).count
        if totalMeds > 0 {
            tasks.append(TodayTask(id: "meds", kind: .medications, title: "Today's medications",
                                   subtitle: "\(takenMeds) of \(totalMeds) taken · tap to log"))
        }
        // Entry point to a screen not yet backed by live data.
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
        dayFormatter("yyyy-MM-dd").string(from: Date())
    }

    private static func dayFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter
    }

    // MARK: Medications

    private struct MedBucket { let id: String; let time: String; let isEvening: Bool; let order: Int }

    private static func bucket(for frequency: String) -> MedBucket {
        switch frequency {
        case "once_daily_morning", "morning": return MedBucket(id: "morning", time: "Morning", isEvening: false, order: 0)
        case "once_daily_midday", "midday": return MedBucket(id: "midday", time: "Midday", isEvening: false, order: 1)
        case "twice_daily", "three_times_daily": return MedBucket(id: "daily", time: "Through the day", isEvening: false, order: 2)
        case "once_daily_evening", "evening": return MedBucket(id: "evening", time: "Evening", isEvening: true, order: 3)
        case "bedtime", "once_daily_bedtime": return MedBucket(id: "bedtime", time: "Bedtime", isEvening: true, order: 4)
        case "as_needed": return MedBucket(id: "prn", time: "As needed", isEvening: false, order: 5)
        default: return MedBucket(id: "other", time: "Other", isEvening: false, order: 6)
        }
    }

    private static func formatDose(_ dose: String, unit: String) -> String {
        if let value = Double(dose) {
            let number = value == value.rounded() ? String(Int(value)) : String(value)
            return "\(number) \(unit)"
        }
        return "\(dose) \(unit)"
    }

    private static func medicationsModel(_ items: [MedicationTodayDTO]) -> MedicationsModel {
        var byBucket: [String: (bucket: MedBucket, meds: [Medication])] = [:]
        for item in items {
            let b = bucket(for: item.frequency)
            let med = Medication(
                id: item.id,
                name: item.name,
                dose: formatDose(item.dose, unit: item.doseUnit),
                isEvening: b.isEvening,
                taken: item.taken ?? false
            )
            byBucket[b.id, default: (b, [])].meds.append(med)
        }
        let groups = byBucket.values
            .sorted { $0.bucket.order < $1.bucket.order }
            .map { MedGroup(id: $0.bucket.id, time: $0.bucket.time, meds: $0.meds) }
        return MedicationsModel(summaryNote: MedicationsModel.sample.summaryNote, groups: groups)
    }

    // MARK: Journal

    private static func journalModel(_ items: [JournalEntryDTO]) -> JournalModel {
        let parser = dayFormatter("yyyy-MM-dd")
        let entries = items.map { item -> JournalEntry in
            let date = parser.date(from: item.entryDate)
            let title = date.map { dayFormatter("EEEE, MMM d").string(from: $0) } ?? item.entryDate
            let meta = date.map { dayFormatter("MMM d, yyyy").string(from: $0) } ?? item.entryDate
            return JournalEntry(
                id: item.id,
                moodHex: 0xA9B5A0,                 // mood not returned by the list endpoint
                meta: meta,
                shared: item.sharedWithClinician,
                voice: false,
                title: title,
                excerpt: "\(item.wordCount)-word entry"
            )
        }
        return JournalModel(prompt: JournalModel.sample.prompt, entries: entries)
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
            medications: store.medications,
            journal: store.journal,
            onCheckInSubmit: { result in Task { await store.submitCheckIn(result) } }
        )
        .task {
            await store.load()
            #if DEBUG
            // QA hook: persist a sample check-in so the submission path can be
            // verified in the Simulator without driving the 10-step flow.
            if ProcessInfo.processInfo.environment["COPE_TEST_SUBMIT_CHECKIN"] == "1" {
                await store.submitCheckIn(CheckInResult(
                    mood: 6, feelings: ["calm"], sleepHours: 7, sleepQuality: 3, energy: 5,
                    anhedonia: 1, anxiety: 3, bodyRegions: [], bodyAllOver: false, mania: 0,
                    triggers: [], suicidalIdeation: 0, note: "Automated QA check-in"))
            }
            #endif
        }
    }
}
