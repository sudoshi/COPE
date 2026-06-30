import SwiftUI
import DesignSystem

/// Care / secure messaging (build bible §6.6) — the top differentiator. One
/// thread with the care team. Demo content; live messages + WebSocket come next.
public struct CareView: View {
    @State private var showSafety = false
    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            teamHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Tuesday")
                        .font(CopeFont.figtree(11, .medium)).foregroundStyle(CopeColor.ink3)
                        .frame(maxWidth: .infinity)
                    escalationTrustCard
                    clinicianBubble("So glad the new dose is settling in. How have your mornings felt since we adjusted it?", time: "Dr. Alvarez · 9:02")
                    structuredPrompt
                    patientBubble("Better, honestly. Waking up feels less heavy. Still a rough patch around Wednesdays.", time: "You · 9:14 · Read")
                }
                .padding(.horizontal, CopeSpacing.screenH)
                .padding(.vertical, 18)
            }
            composer
        }
        .background(CopeColor.canvas.ignoresSafeArea())
        .copeFullCover(isPresented: $showSafety) { SafetyPlanView() }
    }

    private var teamHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                avatar("A", bg: CopeColor.tealSoft, fg: CopeColor.tealInk).offset(x: -10)
                avatar("S", bg: CopeColor.claySoft, fg: CopeColor.clay).offset(x: 10)
            }
            .frame(width: 56)
            VStack(alignment: .leading, spacing: 2) {
                Text("Your care team").font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                HStack(spacing: 5) {
                    Circle().fill(CopeColor.teal).frame(width: 7, height: 7)
                    Text("Usually replies within 1 business day").font(CopeFont.caption).foregroundStyle(CopeColor.ink2)
                }
            }
            Spacer()
        }
        .padding(.horizontal, CopeSpacing.screenH)
        .padding(.top, 8).padding(.bottom, 14)
        .overlay(alignment: .bottom) { Rectangle().fill(CopeColor.line2).frame(height: 1) }
    }

    private func avatar(_ letter: String, bg: Color, fg: Color) -> some View {
        Text(letter)
            .font(CopeFont.fraunces(15))
            .foregroundStyle(fg)
            .frame(width: 38, height: 38)
            .background(bg)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(CopeColor.canvas, lineWidth: 2))
    }

    private var escalationTrustCard: some View {
        FeatureCard(tint: .teal) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill").font(.system(size: 14)).foregroundStyle(CopeColor.tealInk)
                    Text("Your team is looking out for you").copeSectionLabel(CopeColor.tealInk)
                }
                Text("After this morning's check-in, Sam was notified and will reach out today. You don't need to do anything.")
                    .font(CopeFont.callout).foregroundStyle(CopeColor.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func clinicianBubble(_ text: String, time: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(text)
                .font(CopeFont.body).foregroundStyle(CopeColor.ink)
                .padding(.horizontal, 15).padding(.vertical, 13)
                .background(CopeColor.surface)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 6, bottomTrailingRadius: 18, topTrailingRadius: 18, style: .continuous))
                .overlay(UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 6, bottomTrailingRadius: 18, topTrailingRadius: 18, style: .continuous).strokeBorder(CopeColor.line, lineWidth: 1))
            Text(time).font(CopeFont.figtree(11)).foregroundStyle(CopeColor.ink3).padding(.leading, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 40)
    }

    private func patientBubble(_ text: String, time: String) -> some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(text)
                .font(CopeFont.body).foregroundStyle(.white)
                .padding(.horizontal, 15).padding(.vertical, 13)
                .background(CopeGradient.primary)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 18, bottomTrailingRadius: 6, topTrailingRadius: 18, style: .continuous))
            Text(time).font(CopeFont.figtree(11)).foregroundStyle(CopeColor.ink3).padding(.trailing, 6)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.leading, 40)
    }

    private var structuredPrompt: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick check-in").copeSectionLabel(CopeColor.clay)
            Text("How are mornings feeling on the new dose?")
                .font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 7) {
                replyChip("Better", filled: true)
                replyChip("Same", filled: false)
                replyChip("Worse", filled: false)
            }
        }
        .copeCard(padding: 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 24)
    }

    private func replyChip(_ label: String, filled: Bool) -> some View {
        Text(label)
            .font(CopeFont.figtree(12.5, .semibold))
            .foregroundStyle(filled ? .white : CopeColor.ink2)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(filled ? CopeColor.teal : CopeColor.surface2)
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).strokeBorder(filled ? CopeColor.teal : CopeColor.line, lineWidth: 1))
    }

    private var composer: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Text("Message your care team…")
                    .font(CopeFont.callout).foregroundStyle(CopeColor.ink3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16).padding(.vertical, 11)
                    .background(CopeColor.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(CopeColor.line, lineWidth: 1))
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 40, height: 40).background(CopeGradient.primary).clipShape(Circle())
            }
            Button { showSafety = true } label: {
                (Text("Not for emergencies — in a crisis, ")
                 + Text("tap for 988 & your safety plan").foregroundColor(CopeColor.clay).bold())
                    .font(CopeFont.figtree(11.5)).foregroundStyle(CopeColor.ink3)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18).padding(.top, 10).padding(.bottom, 14)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Rectangle().fill(CopeColor.line2).frame(height: 1) }
    }
}

#Preview {
    CareView()
}
