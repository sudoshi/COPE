import SwiftUI

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published private(set) var entry: DailyEntrySummary?
    @Published var errorMessage: String?
    @Published var moodScore = 6
    @Published var sleepHours = 7.0
    @Published var anxietyScore = 4
    @Published var stressScore = 4
    @Published var suicidalIdeation = 0
    @Published var notes = ""

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            entry = try await apiClient.todayDailyEntry()
            if let entry, let mood = entry.mood {
                moodScore = mood
            }
        } catch {
            errorMessage = SessionViewModel.message(for: error)
        }

        isLoading = false
    }

    func saveDraft() async {
        isSaving = true
        errorMessage = nil

        do {
            let result = try await apiClient.saveDailyEntry(currentDraft)
            entry = DailyEntrySummary(
                id: result.id,
                entryDate: result.entryDate,
                mood: moodScore,
                submittedAt: nil,
                completionPct: entry?.completionPct,
                coreComplete: true,
                wellnessComplete: entry?.wellnessComplete,
                triggersComplete: entry?.triggersComplete,
                symptomsComplete: entry?.symptomsComplete,
                journalComplete: entry?.journalComplete
            )
        } catch {
            errorMessage = SessionViewModel.message(for: error)
        }

        isSaving = false
    }

    func submit() async {
        if entry == nil {
            await saveDraft()
        }

        guard let entry else {
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            let result = try await apiClient.submitDailyEntry(id: entry.id)
            self.entry = DailyEntrySummary(
                id: entry.id,
                entryDate: entry.entryDate,
                mood: entry.mood ?? moodScore,
                submittedAt: result.submittedAt,
                completionPct: entry.completionPct,
                coreComplete: entry.coreComplete,
                wellnessComplete: entry.wellnessComplete,
                triggersComplete: entry.triggersComplete,
                symptomsComplete: entry.symptomsComplete,
                journalComplete: entry.journalComplete
            )
        } catch {
            errorMessage = SessionViewModel.message(for: error)
        }

        isSaving = false
    }

    private var currentDraft: DailyEntryDraft {
        DailyEntryDraft(
            entryDate: Self.todayString(),
            moodScore: moodScore,
            sleepHours: sleepHours,
            anxietyScore: anxietyScore,
            stressScore: stressScore,
            suicidalIdeation: suicidalIdeation,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
    }

    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

struct TodayView: View {
    @StateObject private var model: TodayViewModel

    init(apiClient: APIClient) {
        _model = StateObject(wrappedValue: TodayViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    statusHeader
                    checkInControls

                    if let errorMessage = model.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(CopeColor.danger)
                    }
                }
                .padding(20)
            }
            .background(CopeColor.background)
            .navigationTitle("Today")
            .toolbar {
                Button {
                    Task { await model.load() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh today")
            }
        }
        .task {
            await model.load()
        }
    }

    private var statusHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(model.entry?.isSubmitted == true ? "Submitted" : "Check-in")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(CopeColor.text)

                Spacer()

                if model.isLoading {
                    ProgressView()
                        .tint(CopeColor.primary)
                }
            }

            Text(model.entry?.entryDate ?? Date.now.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 15))
                .foregroundStyle(CopeColor.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var checkInControls: some View {
        VStack(alignment: .leading, spacing: 18) {
            ScoreSlider(title: "Mood", value: $model.moodScore, range: 1...10, systemImage: "heart.fill")
            ScoreSlider(title: "Anxiety", value: $model.anxietyScore, range: 1...10, systemImage: "waveform.path.ecg")
            ScoreSlider(title: "Stress", value: $model.stressScore, range: 1...10, systemImage: "bolt.heart.fill")
            ScoreSlider(title: "Suicidal ideation", value: $model.suicidalIdeation, range: 0...3, systemImage: "exclamationmark.triangle.fill")

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundStyle(CopeColor.primary)
                    Text("Sleep")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(CopeColor.text)
                    Spacer()
                    Text("\(model.sleepHours, specifier: "%.1f")h")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(CopeColor.text)
                }

                Slider(value: $model.sleepHours, in: 0...14, step: 0.5)
                    .tint(CopeColor.primary)
            }

            TextField("Notes", text: $model.notes, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.plain)
                .padding(14)
                .background(CopeColor.surface)
                .foregroundStyle(CopeColor.text)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(CopeColor.border, lineWidth: 1)
                )

            HStack(spacing: 12) {
                Button {
                    Task { await model.saveDraft() }
                } label: {
                    Label(model.isSaving ? "Saving" : "Save", systemImage: "tray.and.arrow.down.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .foregroundStyle(CopeColor.text)
                .background(CopeColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(CopeColor.border, lineWidth: 1)
                )
                .disabled(model.isSaving)

                Button {
                    Task { await model.submit() }
                } label: {
                    Label("Submit", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(CopeColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .disabled(model.isSaving)
            }
        }
        .padding(16)
        .background(CopeColor.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ScoreSlider: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(CopeColor.primary)
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.text)
                Spacer()
                Text("\(value)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.text)
            }

            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0.rounded()) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: 1
            )
            .tint(CopeColor.primary)
        }
    }
}

#Preview {
    TodayView(apiClient: APIClient())
}
