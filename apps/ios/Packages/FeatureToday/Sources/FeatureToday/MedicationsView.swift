import SwiftUI
import DesignSystem

/// Medications (build bible §6.9): today's doses grouped by time with adherence
/// toggles + a side-effect prompt. Demo data; logging posts via outbox next.
public struct MedicationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var taken: [String: Bool] = ["lam": false, "ser": true, "abi": false]

    public init() {}

    private var doneCount: Int { taken.values.filter { $0 }.count }

    public var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    summaryCard
                    group("Morning · 8:00 AM") {
                        medRow("lam", name: "Lamotrigine", dose: "200 mg · 1 tablet", tint: .teal)
                        medRow("ser", name: "Sertraline", dose: "100 mg · 1 tablet", tint: .teal)
                    }
                    group("Evening · 9:00 PM") {
                        medRow("abi", name: "Aripiprazole", dose: "5 mg · 1 tablet", tint: .clay)
                    }
                    sideEffectPrompt
                }
                .padding(.horizontal, CopeSpacing.screenH).padding(.bottom, 30)
            }
        }
        .background(CopeColor.canvas.ignoresSafeArea())
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)).foregroundStyle(CopeColor.ink)
                    .frame(width: 38, height: 38).background(CopeColor.surface).clipShape(Circle())
                    .overlay(Circle().strokeBorder(CopeColor.line, lineWidth: 1))
            }.buttonStyle(.plain)
            Text("Medications").font(CopeFont.sectionTitle).foregroundStyle(CopeColor.ink)
            Spacer()
            Image(systemName: "plus").font(.system(size: 16, weight: .semibold)).foregroundStyle(CopeColor.teal)
                .frame(width: 38, height: 38).background(CopeColor.surface).clipShape(Circle())
                .overlay(Circle().strokeBorder(CopeColor.line, lineWidth: 1))
        }
        .padding(.horizontal, CopeSpacing.screenH).padding(.top, 6).padding(.bottom, 12)
    }

    private var summaryCard: some View {
        HStack(spacing: 12) {
            Text("\(doneCount)/3").font(CopeFont.fraunces(30)).foregroundStyle(CopeColor.teal)
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's doses").font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                Text("Keeping a steady rhythm helps your levels stay even.")
                    .font(CopeFont.caption).foregroundStyle(CopeColor.ink2).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .copeCard(padding: 16)
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).copeSectionLabel(CopeColor.ink3).padding(.leading, 4)
            content()
        }
    }

    private func medRow(_ key: String, name: String, dose: String, tint: TodayRow.IconTint) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "pills.fill")
                .font(.system(size: 18)).foregroundStyle(tint == .teal ? CopeColor.tealInk : CopeColor.clay)
                .frame(width: 44, height: 44).background(tint == .teal ? CopeColor.tealSoft : CopeColor.claySoft)
                .clipShape(RoundedRectangle(cornerRadius: CopeRadius.iconTile, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                Text(dose).font(CopeFont.caption).foregroundStyle(CopeColor.ink2)
            }
            Spacer(minLength: 8)
            MedToggle(isOn: Binding(get: { taken[key] ?? false }, set: { taken[key] = $0 }))
        }
        .copeCard(padding: 15)
    }

    private var sideEffectPrompt: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle").font(.system(size: 16)).foregroundStyle(CopeColor.ink3)
            (Text("Noticing a side effect? ").foregroundColor(CopeColor.ink2)
             + Text("Log it for your team →").foregroundColor(CopeColor.teal).bold())
                .font(CopeFont.caption).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(CopeColor.surface2)
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(CopeColor.line, style: StrokeStyle(lineWidth: 1, dash: [5])))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview { MedicationsView() }
