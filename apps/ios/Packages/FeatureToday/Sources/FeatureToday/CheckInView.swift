import SwiftUI
import DesignSystem

/// The daily check-in hero (build bible §6.4): a full-screen, one-question-per-
/// screen flow over the design system. 10 adaptive steps with the C-SSRS safety
/// branch + escalation. Submission wiring (draft/outbox/API) comes next.
public struct CheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var model: CheckInViewModel
    @State private var showSafety = false

    public init(isBipolar: Bool = true) {
        let viewModel = CheckInViewModel(isBipolar: isBipolar)
        #if DEBUG
        // Lets the Simulator jump to a step / preset answers for screenshots,
        // since there's no tap automation available here.
        let env = ProcessInfo.processInfo.environment
        if let raw = env["COPE_CHECKIN_STEP"], let index = Int(raw) {
            viewModel.stepIndex = min(max(0, index), viewModel.steps.count - 1)
        }
        if let raw = env["COPE_CHECKIN_SI"], let value = Int(raw) {
            viewModel.suicidalIdeation = value
        }
        #endif
        _model = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            topBar
            ScrollView {
                stepContent
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id(model.stepIndex) // re-trigger entrance animation per step
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            footer
        }
        .background(CopeColor.canvas.ignoresSafeArea())
        .copeFullCover(isPresented: $showSafety) { SafetyPlanView() }
    }

    // MARK: Chrome

    private var topBar: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                circleButton("chevron.left") { if model.goBack() { dismiss() } }
                CopeProgressBar(progress: model.progress)
                circleButton("xmark") { dismiss() }
            }
            Text(model.stepLabel)
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

    private var footer: some View {
        Button(model.ctaTitle) {
            withAnimation(.easeOut(duration: 0.25)) {
                if model.advance() { dismiss() }
            }
        }
        .buttonStyle(.copePrimary)
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 20)
        .background(CopeColor.canvas)
    }

    // MARK: Step router

    @ViewBuilder
    private var stepContent: some View {
        switch model.currentStep {
        case .mood: moodStep
        case .feelings: feelingsStep
        case .sleep: sleepStep
        case .energy: energyStep
        case .anxiety: anxietyStep
        case .body: bodyStep
        case .mania: maniaStep
        case .triggers: triggersStep
        case .safety: safetyStep
        case .reflection: reflectionStep
        }
    }

    private func prompt(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(CopeFont.question)
                .foregroundStyle(CopeColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(CopeFont.body)
                .foregroundStyle(CopeColor.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Steps

    private var moodStep: some View {
        @Bindable var model = model
        return VStack(alignment: .leading, spacing: 0) {
            prompt("Where's your mood right now?", "Drag to the place that feels most true. There's no wrong answer.")
            MoodDial(value: model.moodValue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            Text(CopeMood.word(for: model.moodValue))
                .font(CopeFont.numberMedium).foregroundStyle(CopeColor.ink)
                .frame(maxWidth: .infinity)
            Text("\(model.moodValue) out of 10")
                .font(CopeFont.figtree(13)).foregroundStyle(CopeColor.ink3)
                .frame(maxWidth: .infinity).padding(.top, 4).padding(.bottom, 20)
            GradientSlider.mood(value: $model.mood)
            endLabels("Really low", "Really good")
        }
    }

    private var feelingsStep: some View {
        @Bindable var model = model
        return VStack(alignment: .leading, spacing: 14) {
            prompt("When you sit with it, what's there?", "Pick any words that fit — even ones that seem to contradict. Naming it helps your team understand.")
            FlowLayout(spacing: 9) {
                ForEach(CheckInViewModel.feelingWords, id: \.self) { word in
                    ChoiceChip(word, isSelected: model.feelings.contains(word)) { toggle(word, in: \.feelings) }
                }
            }
            hint("Can't find the word? You can write it your own way at the end.")
        }
    }

    private var sleepStep: some View {
        @Bindable var model = model
        return VStack(alignment: .leading, spacing: 14) {
            prompt("How did you sleep?", "Sleep is one of the strongest signals for how the days ahead may go.")
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Hours slept").font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                    Spacer()
                    Text(sleepText).font(CopeFont.numberMedium).foregroundStyle(CopeColor.teal)
                }
                GradientSlider.teal(value: $model.sleepHours, in: 0...12, step: 0.5)
            }
            .copeCard(padding: 20)
            VStack(alignment: .leading, spacing: 14) {
                Text("Sleep quality").font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                SegmentedChoice([(1, "Restless"), (2, "Okay"), (3, "Restful")], selection: $model.sleepQuality)
            }
            .copeCard(padding: 20)
        }
    }

    private var energyStep: some View {
        @Bindable var model = model
        return VStack(alignment: .leading, spacing: 14) {
            prompt("Energy & interest", "How much do things feel within reach today?")
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Energy").font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                    Spacer()
                    Text(model.energyWord).font(CopeFont.body).foregroundStyle(CopeColor.ink2)
                }
                GradientSlider.teal(value: $model.energy, in: 0...10, step: 1)
            }
            .copeCard(padding: 20)
            VStack(alignment: .leading, spacing: 12) {
                Text("Did things you usually enjoy still feel good?")
                    .font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                SegmentedChoice([(0, "Yes, mostly"), (1, "A little less"), (2, "Not really")], selection: $model.anhedonia)
            }
            .copeCard(padding: 20)
        }
    }

    private var anxietyStep: some View {
        @Bindable var model = model
        return VStack(alignment: .leading, spacing: 14) {
            prompt("How anxious are you feeling?", "Including any worry, restlessness, or tension in your body.")
            VStack(spacing: 20) {
                Text(model.anxietyWord)
                    .font(CopeFont.numberMedium).foregroundStyle(CopeColor.ink)
                    .frame(maxWidth: .infinity)
                GradientSlider.clay(value: $model.anxiety, in: 0...10, step: 1)
                endLabels("Calm", "Very anxious")
            }
            .copeCard(padding: 22)
        }
    }

    private var bodyStep: some View {
        @Bindable var model = model
        return VStack(alignment: .leading, spacing: 14) {
            prompt("Where do you feel it?", "Hard feelings often live in the body. Tap anywhere you notice tension, heaviness, or unease.")
            BodyMapView(selected: $model.bodyRegions)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            Text(model.bodySummary)
                .font(CopeFont.bodyStrong).foregroundStyle(CopeColor.tealInk)
                .frame(maxWidth: .infinity)
            HStack {
                Spacer()
                ChoiceChip("It's all over", isSelected: model.bodyAllOver) { model.bodyAllOver.toggle() }
                Spacer()
            }
            .padding(.top, 6)
        }
    }

    private var maniaStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tailored to your care plan")
                .font(CopeFont.figtree(11.5, .semibold))
                .foregroundStyle(CopeColor.clay)
                .padding(.horizontal, 11).padding(.vertical, 5)
                .background(CopeColor.claySoft)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            prompt("Any racing or speeding up?", "Thoughts moving fast, less need for sleep, or feeling unusually energized.")
            VStack(spacing: 10) {
                StackedOption("Not at all", subtitle: "Steady, like usual", isSelected: model.mania == 0) { model.mania = 0 }
                StackedOption("A little", subtitle: "Noticing some speed", isSelected: model.mania == 1) { model.mania = 1 }
                StackedOption("Quite a bit", subtitle: "Hard to slow down", isSelected: model.mania == 2) { model.mania = 2 }
            }
        }
    }

    private var triggersStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            prompt("What's weighing on today?", "Tap anything present. This stays between you and your care team.")
            FlowLayout(spacing: 9) {
                ForEach(CheckInViewModel.triggerWords, id: \.self) { word in
                    ChoiceChip(word, isSelected: model.triggers.contains(word)) { toggle(word, in: \.triggers) }
                }
            }
        }
    }

    private var safetyStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            prompt("One gentle, important question", "Over the past day, have you had thoughts that you'd be better off not alive, or of hurting yourself?")
            VStack(spacing: 9) {
                StackedOption("Not at all", isSelected: model.suicidalIdeation == 0) { model.suicidalIdeation = 0 }
                StackedOption("Fleeting, passing thoughts", isSelected: model.suicidalIdeation == 1) { model.suicidalIdeation = 1 }
                StackedOption("Some of the time", isSelected: model.suicidalIdeation == 2) { model.suicidalIdeation = 2 }
                StackedOption("A lot of the time", isSelected: model.suicidalIdeation == 3) { model.suicidalIdeation = 3 }
            }
            if model.siElevated {
                escalationCard
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.25), value: model.siElevated)
    }

    private var escalationCard: some View {
        FeatureCard(tint: .clay) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Thank you for telling us.")
                        .font(CopeFont.sectionTitle).foregroundStyle(CopeColor.ink)
                    Text("You're not alone in this. Your safety plan and people who can help are right here.")
                        .font(CopeFont.callout).foregroundStyle(CopeColor.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button("Open my safety plan") { showSafety = true }
                    .buttonStyle(.plain)
                    .font(CopeFont.bodyStrong).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(CopeColor.clay)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                Button("Call or text 988 now") { openURL(URL(string: "tel://988")!) }
                    .buttonStyle(.plain)
                    .font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(CopeColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).strokeBorder(CopeColor.line, lineWidth: 1))
            }
        }
    }

    private var reflectionStep: some View {
        @Bindable var model = model
        return VStack(alignment: .leading, spacing: 18) {
            prompt("Anything you want to add?", "Optional. A sentence, a feeling, a moment from your day.")
            VStack(alignment: .leading, spacing: 12) {
                TextField("Today felt a little lighter than yesterday…", text: $model.note, axis: .vertical)
                    .font(CopeFont.body).foregroundStyle(CopeColor.ink)
                    .lineLimit(3...6)
                    .textFieldStyle(.plain)
                Divider().overlay(CopeColor.line2)
                Label("Speak instead", systemImage: "mic.fill")
                    .font(CopeFont.figtree(12.5, .semibold)).foregroundStyle(CopeColor.tealInk)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(CopeColor.tealSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
            .copeCard(padding: 16)
            recapCard
        }
    }

    private var recapCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your check-in").copeSectionLabel(CopeColor.ink3)
            recapRow("Mood") {
                HStack(spacing: 8) {
                    Circle().fill(CopeMood.color(for: model.moodValue)).frame(width: 13, height: 13)
                    Text("\(model.moodValue) · \(CopeMood.word(for: model.moodValue))")
                        .font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                }
            }
            recapRow("Sleep") { Text(sleepText).font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink) }
            recapRow("Anxiety") { Text(model.anxietyWord).font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink) }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CopeColor.surface2)
        .clipShape(RoundedRectangle(cornerRadius: CopeRadius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: CopeRadius.card, style: .continuous).strokeBorder(CopeColor.line, lineWidth: 1))
    }

    private func recapRow<Trailing: View>(_ label: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack {
            Text(label).font(CopeFont.body).foregroundStyle(CopeColor.ink2)
            Spacer()
            trailing()
        }
    }

    // MARK: Bits

    private func endLabels(_ left: String, _ right: String) -> some View {
        HStack {
            Text(left)
            Spacer()
            Text(right)
        }
        .font(CopeFont.figtree(11.5))
        .foregroundStyle(CopeColor.ink3)
        .padding(.top, 10)
    }

    private func hint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "square.and.pencil").font(.system(size: 13))
            Text(text).fixedSize(horizontal: false, vertical: true)
        }
        .font(CopeFont.caption).foregroundStyle(CopeColor.ink3)
        .padding(.top, 10)
    }

    private var sleepText: String {
        let h = model.sleepHours
        return h.rounded() == h ? "\(Int(h))h" : String(format: "%.1fh", h)
    }

    private func toggle(_ value: String, in keyPath: ReferenceWritableKeyPath<CheckInViewModel, Set<String>>) {
        if model[keyPath: keyPath].contains(value) {
            model[keyPath: keyPath].remove(value)
        } else {
            model[keyPath: keyPath].insert(value)
        }
    }
}

#Preview {
    CheckInView()
}
