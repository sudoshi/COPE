import SwiftUI
import DesignSystem

/// PHQ-9 assessment (build bible §6.8): warm intro → one question per screen with
/// validated wording + auto-advance → result with interpretation band + prior
/// comparison. Item-9 > 0 triggers the safety handoff (§7). Generic engine for
/// the other instruments comes next; scoring will move to CopeCore.
public struct AssessmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phase = -1                 // -1 intro · 0…8 questions · 9 result
    @State private var answers = Array(repeating: -1, count: 9)
    @State private var showSafety = false

    public init() {
        #if DEBUG
        // Lets the Simulator jump straight to the result for screenshots.
        if ProcessInfo.processInfo.environment["COPE_ASSESS"] == "result" {
            _phase = State(initialValue: 9)
            _answers = State(initialValue: [1, 1, 1, 1, 1, 1, 1, 1, 1])
        }
        #endif
    }

    private static let items = [
        "Little interest or pleasure in doing things",
        "Feeling down, depressed, or hopeless",
        "Trouble falling or staying asleep, or sleeping too much",
        "Feeling tired or having little energy",
        "Poor appetite or overeating",
        "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
        "Trouble concentrating on things, such as reading or watching television",
        "Moving or speaking so slowly that other people could have noticed — or being so restless that you have been moving around a lot more than usual",
        "Thoughts that you would be better off dead, or of hurting yourself in some way"
    ]
    private static let options = ["Not at all", "Several days", "More than half the days", "Nearly every day"]

    private var score: Int { answers.map { max(0, $0) }.reduce(0, +) }
    private var interpretation: String {
        switch score {
        case ..<5: return "Minimal"
        case ..<10: return "Mild"
        case ..<15: return "Moderate"
        case ..<20: return "Moderately severe"
        default: return "Severe"
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            topBar
            switch phase {
            case -1: intro
            case 9: result
            default: question
            }
        }
        .background(CopeColor.canvas.ignoresSafeArea())
        .copeFullCover(isPresented: $showSafety) { SafetyPlanView() }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { back() } label: {
                Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)).foregroundStyle(CopeColor.ink)
                    .frame(width: 38, height: 38).background(CopeColor.surface).clipShape(Circle())
                    .overlay(Circle().strokeBorder(CopeColor.line, lineWidth: 1))
            }.buttonStyle(.plain)
            Text("PHQ-9").font(CopeFont.sectionTitle).foregroundStyle(CopeColor.ink)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 15, weight: .semibold)).foregroundStyle(CopeColor.ink2)
                    .frame(width: 38, height: 38).background(CopeColor.surface).clipShape(Circle())
                    .overlay(Circle().strokeBorder(CopeColor.line, lineWidth: 1))
            }.buttonStyle(.plain)
        }
        .padding(.horizontal, CopeSpacing.screenH).padding(.top, 6).padding(.bottom, 12)
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 26)).foregroundStyle(CopeColor.clay)
                .frame(width: 52, height: 52).background(CopeColor.claySoft)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.bottom, 20)
            Text("A weekly check on your mood").font(CopeFont.title).foregroundStyle(CopeColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Dr. Alvarez asked for this so your care can stay tuned to how you're really doing. Nine questions, about five minutes.")
                .font(CopeFont.body).foregroundStyle(CopeColor.ink2)
                .padding(.top, 10).fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading) {
                (Text("Over the last 2 weeks, ").font(CopeFont.bodyStrong).foregroundColor(CopeColor.ink)
                 + Text("how often have you been bothered by each of the following?").font(CopeFont.body).foregroundColor(CopeColor.ink2))
            }
            .copeCard(padding: 16).padding(.top, 22)
            Spacer()
            Button("Begin") { phase = 0 }.buttonStyle(.copePrimary)
        }
        .padding(.horizontal, 24).padding(.bottom, 20)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var question: some View {
        VStack(alignment: .leading, spacing: 0) {
            CopeProgressBar(progress: Double(phase) / 9).padding(.horizontal, 24)
            Text("Question \(phase + 1) of 9").font(CopeFont.figtree(11.5, .semibold)).tracking(0.3)
                .foregroundStyle(CopeColor.ink3).padding(.horizontal, 24).padding(.top, 10)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Over the last 2 weeks…").font(CopeFont.caption).foregroundStyle(CopeColor.ink3).padding(.bottom, 8)
                    Text(Self.items[phase]).font(CopeFont.fraunces(24)).foregroundStyle(CopeColor.ink)
                        .fixedSize(horizontal: false, vertical: true).padding(.bottom, 28)
                    VStack(spacing: 10) {
                        ForEach(Self.options.indices, id: \.self) { value in
                            StackedOption(Self.options[value], isSelected: answers[phase] == value) { pick(value) }
                        }
                    }
                }
                .padding(.horizontal, 24).padding(.top, 10).padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .id(phase)
            }
        }
    }

    private var result: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Text("\(score)").font(CopeFont.numberLarge).foregroundStyle(CopeColor.tealInk)
                        Text("of 27").font(CopeFont.figtree(12, .semibold)).foregroundStyle(CopeColor.tealInk)
                    }
                    .frame(width: 140, height: 140).background(CopeColor.tealSoft).clipShape(Circle())
                    .overlay(Circle().strokeBorder(CopeColor.teal, lineWidth: 2)).padding(.vertical, 18)
                    Text("\(interpretation) symptoms").font(CopeFont.title).foregroundStyle(CopeColor.ink)
                    Text("Thank you for taking the time. Your score has been shared securely with Dr. Alvarez, who'll review it before your next visit.")
                        .font(CopeFont.body).foregroundStyle(CopeColor.ink2).multilineTextAlignment(.center)
                        .padding(.top, 6).padding(.horizontal, 8).fixedSize(horizontal: false, vertical: true)
                    Label("Compared to 14 two weeks ago — you're trending toward milder symptoms.", systemImage: "checkmark.circle.fill")
                        .font(CopeFont.caption).foregroundStyle(CopeColor.ink2)
                        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                        .background(CopeColor.surface).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(CopeColor.line, lineWidth: 1))
                        .padding(.top, 18)
                    if answers[8] > 0 { safetyHandoff.padding(.top, 14) }
                }
                .padding(.horizontal, 24).padding(.bottom, 16)
            }
            Button("Done") { dismiss() }.buttonStyle(.copePrimary).padding(.horizontal, 24).padding(.bottom, 20)
        }
    }

    private var safetyHandoff: some View {
        FeatureCard(tint: .clay) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Let's make sure you're supported").font(CopeFont.sectionTitle).foregroundStyle(CopeColor.ink)
                Text("You mentioned thoughts of being better off dead or hurting yourself. Your safety plan and the 988 lifeline are right here.")
                    .font(CopeFont.callout).foregroundStyle(CopeColor.ink2).fixedSize(horizontal: false, vertical: true)
                Button("Open my safety plan") { showSafety = true }
                    .buttonStyle(.plain).font(CopeFont.bodyStrong).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 13).background(CopeColor.clay)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
        }
    }

    private func pick(_ value: Int) {
        answers[phase] = value
        withAnimation(.easeOut(duration: 0.2)) { phase = min(phase + 1, 9) }
    }

    private func back() {
        if phase <= -1 { dismiss() }
        else { withAnimation(.easeOut(duration: 0.2)) { phase -= 1 } }
    }
}

#Preview { AssessmentView() }
