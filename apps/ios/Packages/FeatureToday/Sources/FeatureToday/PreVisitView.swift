import SwiftUI
import DesignSystem

/// Pre-visit prep (build bible §6.12): a quiet summary of two weeks + an
/// editable agenda, so patients arrive heard. Auto-summary is generated from
/// existing data; the patient chooses what to raise. Demo content.
public struct PreVisitView: View {
    @Environment(\.dismiss) private var dismiss

    private struct AgendaItem: Identifiable {
        let id: String
        let label: String
        let sub: String
    }
    private static let agenda = [
        AgendaItem(id: "dose", label: "The new dose & my mornings", sub: "You noted mornings feel lighter"),
        AgendaItem(id: "anx", label: "Anxiety midweek", sub: "Spikes around Wednesdays"),
        AgendaItem(id: "sleep", label: "Sleep still uneven", sub: "Avg 6.8h · a few restless nights"),
        AgendaItem(id: "side", label: "A side effect to mention", sub: "Optional — add if it comes up")
    ]
    @State private var included: Set<String> = ["dose", "anx"]

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    appointmentCard
                    Text("A quiet summary of your two weeks. Choose what you want to make sure you talk about — it'll be ready before you meet, so you don't have to find the words in the moment.")
                        .font(CopeFont.body).foregroundStyle(CopeColor.ink2).fixedSize(horizontal: false, vertical: true)
                    Text("Your last two weeks").copeSectionLabel(CopeColor.ink3).padding(.leading, 4)
                    summaryGrid
                    Text("What I want to talk about").copeSectionLabel(CopeColor.ink3).padding(.leading, 4)
                    VStack(spacing: 10) {
                        ForEach(Self.agenda) { item in agendaRow(item) }
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
                Text("Dr. Alvarez").font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                Text("Thursday, Jun 26 · 2:00 PM · Telehealth").font(CopeFont.caption).foregroundStyle(CopeColor.ink2)
            }
            Spacer(minLength: 0)
        }
        .copeCard(padding: 15)
    }

    private var summaryGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                statCard("Mood", value: "4.8→6.4", note: "↑ trending up", noteColor: CopeColor.teal)
                statCard("Sleep", value: "6.8h", note: "steadier than before", noteColor: CopeColor.ink3)
            }
            HStack(spacing: 10) {
                statCard("PHQ-9", value: "14→9", note: "↓ improving", noteColor: CopeColor.teal)
                flagCard
            }
        }
    }

    private func statCard(_ title: String, value: String, note: String, noteColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(CopeFont.figtree(12.5, .medium)).foregroundStyle(CopeColor.ink2)
            Text(value).font(CopeFont.fraunces(22)).foregroundStyle(CopeColor.ink)
            Text(note).font(CopeFont.figtree(11.5, .semibold)).foregroundStyle(noteColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .copeCard(padding: 15)
    }

    private var flagCard: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Worth flagging").copeSectionLabel(CopeColor.clay)
            Text("Anxiety still spikes midweek").font(CopeFont.figtree(13, .semibold)).foregroundStyle(CopeColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(CopeGradient.feature(CopeColor.claySoft))
        .clipShape(RoundedRectangle(cornerRadius: CopeRadius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: CopeRadius.card, style: .continuous).strokeBorder(CopeColor.clay, lineWidth: 1))
    }

    private func agendaRow(_ item: AgendaItem) -> some View {
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
