import SwiftUI
import DesignSystem

/// A taste of the daily check-in hero (build bible §6.4, steps 0–1): the mood
/// dial + gradient slider, then the feeling-words picker. Not the full 10-step
/// flow yet — enough to feel the warmth and interactivity in the Simulator.
public struct CheckInTasteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mood: Double = 6
    @State private var feelings: Set<String> = []

    private let feelingWords = [
        "Numb", "On edge", "Heavy", "Hollow", "Wired but tired", "Foggy", "Restless",
        "Overwhelmed", "Irritable", "Disconnected", "Lonely", "Ashamed", "Hopeful", "Calm"
    ]

    public init() {}

    private var moodValue: Int { Int(mood.rounded()) }

    public var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    moodStep
                    Divider().overlay(CopeColor.line)
                    feelingStep
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            footer
        }
        .background(CopeColor.canvas.ignoresSafeArea())
    }

    // MARK: Top bar

    private var topBar: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                circleButton("chevron.left") { dismiss() }
                CopeProgressBar(progress: 0.2)
                circleButton("xmark") { dismiss() }
            }
            Text("Step 1 of 10 · Mood")
                .copeSectionLabel(CopeColor.ink3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 12)
    }

    private func circleButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(CopeColor.ink)
                .frame(width: 38, height: 38)
                .background(CopeColor.surface)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(CopeColor.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: Mood step

    private var moodStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Where's your mood right now?")
                .font(CopeFont.question)
                .foregroundStyle(CopeColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Drag to the place that feels most true. There's no wrong answer.")
                .font(CopeFont.body)
                .foregroundStyle(CopeColor.ink2)
                .padding(.top, 6)
                .fixedSize(horizontal: false, vertical: true)

            MoodDial(value: moodValue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

            Text(CopeMood.word(for: moodValue))
                .font(CopeFont.numberMedium)
                .foregroundStyle(CopeColor.ink)
                .frame(maxWidth: .infinity)
            Text("\(moodValue) out of 10")
                .font(CopeFont.figtree(13))
                .foregroundStyle(CopeColor.ink3)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
                .padding(.bottom, 20)

            GradientSlider.mood(value: $mood)
            HStack {
                Text("Really low")
                Spacer()
                Text("Really good")
            }
            .font(CopeFont.figtree(11.5))
            .foregroundStyle(CopeColor.ink3)
            .padding(.top, 10)
        }
    }

    // MARK: Feeling words

    private var feelingStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("When you sit with it, what's there?")
                .font(CopeFont.sectionTitle)
                .foregroundStyle(CopeColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            FlowLayout(spacing: 9) {
                ForEach(feelingWords, id: \.self) { word in
                    ChoiceChip(word, isSelected: feelings.contains(word)) {
                        if feelings.contains(word) { feelings.remove(word) } else { feelings.insert(word) }
                    }
                }
            }
        }
    }

    // MARK: Footer

    private var footer: some View {
        Button("Continue") { dismiss() }
            .buttonStyle(.copePrimary)
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .padding(.bottom, 20)
            .background(CopeColor.canvas)
    }
}

#Preview {
    CheckInTasteView()
}
