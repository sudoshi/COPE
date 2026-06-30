import SwiftUI
import DesignSystem

/// You / Profile & privacy (build bible §6.11). Demo content for now; consent +
/// notification controls will move here from the legacy CareView.
public struct ProfileView: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                privacyCard
                settingsList
                Button("Replay onboarding") {}
                    .buttonStyle(.copeSecondary)
                Text("COPE v1.1 · 988 Suicide & Crisis Lifeline built in")
                    .font(CopeFont.figtree(11.5))
                    .foregroundStyle(CopeColor.ink3)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(.horizontal, CopeSpacing.screenH)
            .padding(.top, 10)
            .padding(.bottom, 40)
        }
        .background(CopeColor.canvas.ignoresSafeArea())
    }

    private var header: some View {
        HStack(spacing: 14) {
            Text("M")
                .font(CopeFont.fraunces(26))
                .foregroundStyle(CopeColor.clay)
                .frame(width: 60, height: 60)
                .background(CopeColor.claySoft)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Maya Thompson").font(CopeFont.title).foregroundStyle(CopeColor.ink)
                Text("Bayview Behavioral Health").font(CopeFont.caption).foregroundStyle(CopeColor.ink2)
            }
        }
    }

    private var privacyCard: some View {
        FeatureCard(tint: .teal) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 9) {
                    Image(systemName: "lock.fill").font(.system(size: 16, weight: .semibold)).foregroundStyle(CopeColor.tealInk)
                    Text("Your privacy, in plain terms").font(CopeFont.sectionTitle).foregroundStyle(CopeColor.ink)
                }
                Text("Your journals and messages are encrypted. We never sell or advertise on your data — ever.")
                    .font(CopeFont.callout).foregroundStyle(CopeColor.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 6)
                Divider().overlay(CopeColor.teal)
                HStack {
                    Text("See who's viewed your data").font(CopeFont.bodyStrong).foregroundStyle(CopeColor.tealInk)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(CopeColor.tealInk)
                }
                .padding(.top, 8)
            }
        }
    }

    private var settingsList: some View {
        VStack(spacing: 0) {
            row("bell.fill", "Notifications & reminders", first: true)
            divider
            SettingsRow(icon: "faceid", title: "Face ID & app lock", value: "On", showsChevron: false) {}
            divider
            row("heart.text.square.fill", "Apple Health data")
            divider
            row("person.2.fill", "Care team & sharing")
            divider
            row("square.and.arrow.up", "Export my data")
        }
        .background(CopeColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: CopeRadius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: CopeRadius.card, style: .continuous).strokeBorder(CopeColor.line, lineWidth: 1))
        .copeShadow(.soft)
    }

    private func row(_ icon: String, _ title: String, first: Bool = false) -> some View {
        SettingsRow(icon: icon, title: title) {}
    }

    private var divider: some View {
        Divider().overlay(CopeColor.line2).padding(.leading, 63)
    }
}

#Preview {
    ProfileView()
}
