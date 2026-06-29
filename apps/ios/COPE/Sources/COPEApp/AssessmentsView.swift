import SwiftUI

@MainActor
final class AssessmentsViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitting = false
    @Published private(set) var pending: [PendingAssessment] = []
    @Published private(set) var lastSubmission: AssessmentSubmissionResult?
    @Published var selectedScale = "PHQ-9"
    @Published var itemResponses: [Int] = Array(repeating: 0, count: 9)
    @Published var notes = ""
    @Published var errorMessage: String?

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    var score: Int {
        itemResponses.reduce(0, +)
    }

    var itemCount: Int {
        Self.itemCount(for: selectedScale)
    }

    var itemRange: ClosedRange<Int> {
        Self.itemRange(for: selectedScale)
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            pending = try await apiClient.pendingAssessments()
            if let first = pending.first {
                select(scale: first.scale)
            }
        } catch {
            errorMessage = SessionViewModel.message(for: error)
        }

        isLoading = false
    }

    func select(scale: String) {
        selectedScale = scale
        itemResponses = Array(repeating: 0, count: Self.itemCount(for: scale))
        lastSubmission = nil
    }

    func submit() async {
        isSubmitting = true
        errorMessage = nil

        let responses = Dictionary(
            uniqueKeysWithValues: itemResponses.enumerated().map { index, value in
                ("item_\(index + 1)", value)
            }
        )

        do {
            lastSubmission = try await apiClient.submitAssessment(
                scale: selectedScale,
                score: score,
                itemResponses: responses,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            )
            pending.removeAll { $0.scale == selectedScale }
        } catch {
            errorMessage = SessionViewModel.message(for: error)
        }

        isSubmitting = false
    }

    private static func itemCount(for scale: String) -> Int {
        switch scale {
        case "PHQ-9": return 9
        case "GAD-7": return 7
        case "ASRM": return 5
        case "C-SSRS": return 6
        case "ISI": return 7
        case "QIDS-SR": return 16
        case "WHODAS": return 12
        default: return 7
        }
    }

    private static func itemRange(for scale: String) -> ClosedRange<Int> {
        switch scale {
        case "ASRM": return 0...4
        default: return 0...3
        }
    }
}

struct AssessmentsView: View {
    @StateObject private var model: AssessmentsViewModel

    init(apiClient: APIClient) {
        _model = StateObject(wrappedValue: AssessmentsViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    pendingList
                    responseForm

                    if let lastSubmission = model.lastSubmission {
                        Text("\(lastSubmission.scale) submitted with score \(lastSubmission.score).")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(CopeColor.success)
                    }

                    if let errorMessage = model.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(CopeColor.danger)
                    }
                }
                .padding(20)
            }
            .background(CopeColor.background)
            .navigationTitle("Assessments")
            .toolbar {
                Button {
                    Task { await model.load() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh assessments")
            }
        }
        .task {
            await model.load()
        }
    }

    private var pendingList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Due")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(CopeColor.text)
                Spacer()
                if model.isLoading {
                    ProgressView()
                        .tint(CopeColor.primary)
                }
            }

            if model.pending.isEmpty {
                Text("No assessments due")
                    .font(.system(size: 15))
                    .foregroundStyle(CopeColor.textMuted)
                    .padding(.vertical, 10)
            } else {
                ForEach(model.pending) { assessment in
                    Button {
                        model.select(scale: assessment.scale)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(assessment.scale)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(CopeColor.text)
                                Text("Every \(assessment.intervalDays)d")
                                    .font(.system(size: 13))
                                    .foregroundStyle(CopeColor.textMuted)
                            }
                            Spacer()
                            Image(systemName: model.selectedScale == assessment.scale ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(model.selectedScale == assessment.scale ? CopeColor.primary : CopeColor.textMuted)
                        }
                        .padding(14)
                        .background(CopeColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var responseForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(model.selectedScale)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(CopeColor.text)
                Spacer()
                Text("Score \(model.score)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.primary)
            }

            ForEach(model.itemResponses.indices, id: \.self) { index in
                AssessmentItemStepper(
                    title: "Item \(index + 1)",
                    value: $model.itemResponses[index],
                    range: model.itemRange
                )
            }

            TextField("Notes", text: $model.notes, axis: .vertical)
                .lineLimit(2...5)
                .textFieldStyle(.plain)
                .padding(14)
                .background(CopeColor.surface)
                .foregroundStyle(CopeColor.text)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(CopeColor.border, lineWidth: 1)
                )

            Button {
                Task { await model.submit() }
            } label: {
                Label(model.isSubmitting ? "Submitting" : "Submit Assessment", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(CopeColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .disabled(model.isSubmitting)
        }
        .padding(16)
        .background(CopeColor.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct AssessmentItemStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        Stepper(value: $value, in: range) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(CopeColor.text)
                Spacer()
                Text("\(value)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopeColor.text)
            }
        }
    }
}

#Preview {
    AssessmentsView(apiClient: APIClient())
}
