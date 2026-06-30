import SwiftUI
import DesignSystem

/// Stanley-Brown safety plan (build bible §6.5), patient-facing. The 988 crisis
/// card uses a warm clay gradient (never alarming red) and the call/text actions
/// use the verified 988 lifeline. Demo content; cache + signing come next.
public struct SafetyPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    private let model: SafetyPlanModel
    public init(model: SafetyPlanModel = .sample) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(CopeColor.ink)
                        .frame(width: 38, height: 38).background(CopeColor.surface).clipShape(Circle())
                        .overlay(Circle().strokeBorder(CopeColor.line, lineWidth: 1))
                }
                .buttonStyle(.plain)
                Text("My safety plan").font(CopeFont.sectionTitle).foregroundStyle(CopeColor.ink)
                Spacer()
            }
            .padding(.horizontal, CopeSpacing.screenH).padding(.top, 6).padding(.bottom, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 11) {
                    crisisCard
                    Text(model.builtWith)
                        .font(CopeFont.figtree(11.5)).foregroundStyle(CopeColor.ink3)
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                    section(1, "Signs a hard moment is coming") {
                        Text(model.warningSigns)
                            .font(CopeFont.callout).foregroundStyle(CopeColor.ink2).fixedSize(horizontal: false, vertical: true)
                    }
                    section(2, "Things that help me cope") {
                        Text(model.copingStrategies)
                            .font(CopeFont.callout).foregroundStyle(CopeColor.ink2).fixedSize(horizontal: false, vertical: true)
                    }
                    section(3, "Reasons to keep going") {
                        FlowLayout(spacing: 8) {
                            ForEach(model.reasons, id: \.self) { pill($0) }
                        }
                    }
                    section(4, "People I can reach out to") {
                        ForEach(model.contacts) { contactRow($0) }
                    }
                    section(5, "Making my space safer") {
                        Text(model.saferSpace)
                            .font(CopeFont.callout).foregroundStyle(CopeColor.ink2).fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, CopeSpacing.screenH).padding(.bottom, 30)
            }
        }
        .background(CopeColor.canvas.ignoresSafeArea())
    }

    private var crisisCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(model.crisisHeadline).copeSectionLabel(.white.opacity(0.92))
            Text(model.crisisSubtitle)
                .font(CopeFont.fraunces(21)).foregroundStyle(.white)
                .padding(.top, 5).padding(.bottom, 14)
            HStack(spacing: 9) {
                Button { openURL(URL(string: "tel://988")!) } label: {
                    Text("Call 988").font(CopeFont.figtree(14, .bold)).foregroundStyle(CopeColor.clayDeep)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(.white.opacity(0.95)).clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                }.buttonStyle(.plain)
                Button { openURL(URL(string: "sms://988")!) } label: {
                    Text("Text 988").font(CopeFont.figtree(14, .semibold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(.white.opacity(0.2)).clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).strokeBorder(.white.opacity(0.5), lineWidth: 1))
                }.buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CopeGradient.crisis)
        .clipShape(RoundedRectangle(cornerRadius: CopeRadius.cardLarge, style: .continuous))
        .shadow(color: CopeColor.clay.opacity(0.4), radius: 16, y: 12)
    }

    private func section<Content: View>(_ number: Int, _ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text("\(number)")
                    .font(CopeFont.figtree(12, .bold)).foregroundStyle(CopeColor.tealInk)
                    .frame(width: 24, height: 24).background(CopeColor.tealSoft).clipShape(Circle())
                Text(title).font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
            }
            content()
        }
        .copeCard(padding: 16)
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(CopeFont.figtree(13, .semibold)).foregroundStyle(CopeColor.clay)
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(CopeColor.claySoft).clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }

    private func contactRow(_ contact: SafetyContact) -> some View {
        HStack(spacing: 12) {
            Text(contact.initial).font(CopeFont.fraunces(15)).foregroundStyle(CopeColor.clay)
                .frame(width: 38, height: 38).background(CopeColor.claySoft).clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name).font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                Text(contact.subtitle).font(CopeFont.caption).foregroundStyle(CopeColor.ink2)
            }
            Spacer()
            Image(systemName: "phone.fill").font(.system(size: 16)).foregroundStyle(CopeColor.teal)
        }
    }
}

#Preview {
    SafetyPlanView()
}
