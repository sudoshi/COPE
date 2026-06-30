import SwiftUI
import DesignSystem

/// Onboarding (build bible §6.1): 5 calm steps — welcome, privacy promise,
/// about-you intake, daily rhythm, ready. Demo content; writes consent/intake +
/// schedules reminders when wired.
public struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var concerns: Set<String> = ["Low mood", "Mood swings"]

    public init() {}

    private let concernOptions = ["Low mood", "Anxiety", "Mood swings", "Sleep", "Stress", "Medication support"]
    private var ctaTitle: String { step >= 4 ? "Enter COPE" : (step == 0 ? "Get started" : "Continue") }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button { back() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)).foregroundStyle(CopeColor.ink)
                        .frame(width: 38, height: 38).background(CopeColor.surface).clipShape(Circle())
                        .overlay(Circle().strokeBorder(CopeColor.line, lineWidth: 1))
                }.buttonStyle(.plain)
                CopeProgressBar(progress: Double(step + 1) / 5)
            }
            .padding(.horizontal, 20).padding(.top, 6).padding(.bottom, 12)

            ScrollView {
                stepContent.padding(.horizontal, 24).padding(.top, 8).padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading).id(step)
            }

            Button(ctaTitle) { advance() }.buttonStyle(.copePrimary).padding(.horizontal, 24).padding(.bottom, 20)
        }
        .background(CopeColor.canvas.ignoresSafeArea())
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0: welcome
        case 1: privacy
        case 2: aboutYou
        case 3: rhythm
        default: ready
        }
    }

    private var welcome: some View {
        VStack(spacing: 0) {
            Text("c").font(CopeFont.fraunces(40)).foregroundStyle(.white)
                .frame(width: 96, height: 96).background(CopeGradient.primary)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: CopeColor.teal.opacity(0.4), radius: 20, y: 14)
                .padding(.top, 30).padding(.bottom, 28)
            Text("Welcome to COPE").font(CopeFont.display).foregroundStyle(CopeColor.ink).multilineTextAlignment(.center)
            Text("A calmer, more connected way to stay close to your care team — built around how you actually feel, day to day.")
                .font(CopeFont.body).foregroundStyle(CopeColor.ink2).multilineTextAlignment(.center)
                .padding(.top, 12).frame(maxWidth: 300).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private var privacy: some View {
        VStack(alignment: .leading, spacing: 0) {
            iconTile("lock.fill", tint: .teal).padding(.bottom, 18)
            Text("First, our promise to you").font(CopeFont.title).foregroundStyle(CopeColor.ink).fixedSize(horizontal: false, vertical: true)
            Text("Your trust comes before any feature.").font(CopeFont.body).foregroundStyle(CopeColor.ink2).padding(.top, 10).padding(.bottom, 20)
            VStack(spacing: 11) {
                promiseRow("Journals & messages are encrypted")
                promiseRow("We never sell or advertise on your data")
                promiseRow("You choose what your care team can see")
            }
        }
    }

    private var aboutYou: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("A little about you").font(CopeFont.title).foregroundStyle(CopeColor.ink)
            Text("What brings you to COPE? Tap any that fit — this helps us tailor your check-ins.")
                .font(CopeFont.body).foregroundStyle(CopeColor.ink2).padding(.top, 10).padding(.bottom, 22).fixedSize(horizontal: false, vertical: true)
            FlowLayout(spacing: 9) {
                ForEach(concernOptions, id: \.self) { c in
                    ChoiceChip(c, isSelected: concerns.contains(c)) {
                        if concerns.contains(c) { concerns.remove(c) } else { concerns.insert(c) }
                    }
                }
            }
            HStack(spacing: 12) {
                Text("A").font(CopeFont.fraunces(15)).foregroundStyle(CopeColor.tealInk)
                    .frame(width: 38, height: 38).background(CopeColor.tealSoft).clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dr. Alvarez").font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                    Text("Your psychiatrist · Bayview").font(CopeFont.caption).foregroundStyle(CopeColor.ink2)
                }
                Spacer(minLength: 0)
            }
            .copeCard(padding: 15).padding(.top, 24)
        }
    }

    private var rhythm: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your daily rhythm").font(CopeFont.title).foregroundStyle(CopeColor.ink)
            Text("A short morning moment, an optional evening one. Gentle nudges — never guilt.")
                .font(CopeFont.body).foregroundStyle(CopeColor.ink2).padding(.top, 10).padding(.bottom, 22).fixedSize(horizontal: false, vertical: true)
            reminderRow("sun.max.fill", title: "Morning check-in", sub: "Mood & sleep", time: "8:00 AM", tint: .clay)
            reminderRow("moon.fill", title: "Evening reflection", sub: "Optional · mood & activity", time: "9:00 PM", tint: .teal).padding(.top, 11)
        }
    }

    private var ready: some View {
        VStack(spacing: 0) {
            Image(systemName: "checkmark").font(.system(size: 44, weight: .semibold)).foregroundStyle(CopeColor.teal)
                .frame(width: 96, height: 96).background(CopeColor.tealSoft).clipShape(Circle())
                .overlay(Circle().strokeBorder(CopeColor.teal, lineWidth: 2)).padding(.top, 24).padding(.bottom, 26)
            Text("You're all set, Maya").font(CopeFont.title).foregroundStyle(CopeColor.ink).multilineTextAlignment(.center)
            Text("Take it one check-in at a time. Your care team is with you — and the 988 lifeline is always one tap away.")
                .font(CopeFont.body).foregroundStyle(CopeColor.ink2).multilineTextAlignment(.center)
                .padding(.top, 12).frame(maxWidth: 300).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private func iconTile(_ icon: String, tint: TodayRow.IconTint) -> some View {
        Image(systemName: icon).font(.system(size: 26)).foregroundStyle(tint == .teal ? CopeColor.tealInk : CopeColor.clay)
            .frame(width: 52, height: 52).background(tint == .teal ? CopeColor.tealSoft : CopeColor.claySoft)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func promiseRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundStyle(CopeColor.teal)
            Text(text).font(CopeFont.body).foregroundStyle(CopeColor.ink).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .copeCard(padding: 14)
    }

    private func reminderRow(_ icon: String, title: String, sub: String, time: String, tint: TodayRow.IconTint) -> some View {
        HStack(spacing: 14) {
            iconTile(icon, tint: tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                Text(sub).font(CopeFont.caption).foregroundStyle(CopeColor.ink2)
            }
            Spacer(minLength: 0)
            Text(time).font(CopeFont.bodyStrong).foregroundStyle(CopeColor.teal)
        }
        .copeCard(padding: 16)
    }

    private func advance() {
        if step >= 4 { dismiss() } else { withAnimation(.easeOut(duration: 0.25)) { step += 1 } }
    }
    private func back() {
        if step == 0 { dismiss() } else { withAnimation(.easeOut(duration: 0.25)) { step -= 1 } }
    }
}

#Preview { OnboardingView() }
