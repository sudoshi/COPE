import SwiftUI
import DesignSystem

/// Pre-visit prep (build bible §6.12): a quiet summary of two weeks + an
/// editable agenda, so patients arrive heard. Auto-summary is generated from
/// existing data; the patient chooses what to raise. Demo content.
public struct PreVisitView: View {
    @Environment(\.dismiss) private var dismiss

    private let model: PreVisitModel
    @State private var included: Set<String>

    public init(model: PreVisitModel = .sample) {
        self.model = model
        _included = State(initialValue: Set(model.agenda.filter(\.includedByDefault).map(\.id)))
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    appointmentCard
                    Text(model.intro)
                        .font(CopeFont.body).foregroundStyle(CopeColor.ink2).fixedSize(horizontal: false, vertical: true)
                    Text("Your last two weeks").copeSectionLabel(CopeColor.ink3).padding(.leading, 4)
                    summaryGrid
                    Text("What I want to talk about").copeSectionLabel(CopeColor.ink3).padding(.leading, 4)
                    VStack(spacing: 10) {
                        ForEach(model.agenda) { item in agendaRow(item) }
                        addRow
                    }
                }
                .padding(.horizontal, CopeSpacing.screenH).padding(.bottom, 24)
            }
            footer
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
            Text("Before your visit").font(CopeFont.sectionTitle).foregroundStyle(CopeColor.ink)
            Spacer()
        }
        .padding(.horizontal, CopeSpacing.screenH).padding(.top, 6).padding(.bottom, 12)
    }

    private var appointmentCard: some View {
        HStack(spacing: 13) {
            Image(systemName: "calendar").font(.system(size: 22)).foregroundStyle(CopeColor.clay)
                .frame(width: 46, height: 46).background(CopeColor.claySoft)
                .clipShape(RoundedRectangle(cornerRadius: CopeRadius.iconTile, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(model.clinician).font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                Text(model.appointment).font(CopeFont.caption).foregroundStyle(CopeColor.ink2)
            }
            Spacer(minLength: 0)
        }
        .copeCard(padding: 15)
    }

    private var summaryGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                if model.stats.indices.contains(0) { statCard(model.stats[0]) }
                if model.stats.indices.contains(1) { statCard(model.stats[1]) }
            }
            HStack(spacing: 10) {
                if model.stats.indices.contains(2) { statCard(model.stats[2]) }
                flagCard
            }
        }
    }

    private func statCard(_ stat: PreVisitStat) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(stat.title).font(CopeFont.figtree(12.5, .medium)).foregroundStyle(CopeColor.ink2)
            Text(stat.value).font(CopeFont.fraunces(22)).foregroundStyle(CopeColor.ink)
            Text(stat.note).font(CopeFont.figtree(11.5, .semibold)).foregroundStyle(stat.notePositive ? CopeColor.teal : CopeColor.ink3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .copeCard(padding: 15)
    }

    private var flagCard: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Worth flagging").copeSectionLabel(CopeColor.clay)
            Text(model.flagTitle).font(CopeFont.figtree(13, .semibold)).foregroundStyle(CopeColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(CopeGradient.feature(CopeColor.claySoft))
        .clipShape(RoundedRectangle(cornerRadius: CopeRadius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: CopeRadius.card, style: .continuous).strokeBorder(CopeColor.clay, lineWidth: 1))
    }

    private func agendaRow(_ item: PreVisitItem) -> some View {
        let on = included.contains(item.id)
        return Button {
            if on { included.remove(item.id) } else { included.insert(item.id) }
        } label: {
            HStack(spacing: 13) {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold)).foregroundStyle(on ? .white : .clear)
                    .frame(width: 26, height: 26)
                    .background(on ? CopeColor.teal : CopeColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(on ? CopeColor.teal : CopeColor.line, lineWidth: 1.5))
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.label).font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                    Text(item.sub).font(CopeFont.caption).foregroundStyle(CopeColor.ink2)
                }
                Spacer(minLength: 0)
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(on ? CopeColor.tealSoft : CopeColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(on ? CopeColor.teal : CopeColor.line, lineWidth: on ? 1.5 : 1))
        }
        .buttonStyle(.plain)
    }

    private var addRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus").font(.system(size: 16, weight: .semibold)).foregroundStyle(CopeColor.ink3)
            Text("Add something else…").font(CopeFont.callout).foregroundStyle(CopeColor.ink3)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 15).padding(.vertical, 14)
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(CopeColor.line, style: StrokeStyle(lineWidth: 1, dash: [5])))
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Button("Share with Dr. Alvarez · \(included.count) items") { dismiss() }.buttonStyle(.copePrimary)
            Text("Only you and your care team can see this.")
                .font(CopeFont.figtree(11.5)).foregroundStyle(CopeColor.ink3)
        }
        .padding(.horizontal, 24).padding(.top, 14).padding(.bottom, 18)
        .background(CopeColor.canvas)
    }
}

#Preview { PreVisitView() }
