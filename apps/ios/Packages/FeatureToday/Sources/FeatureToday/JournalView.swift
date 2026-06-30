import SwiftUI
import DesignSystem

/// Journal (build bible §6.10): compose (write/speak), a gentle rotating prompt,
/// and earlier entries with shared/voice badges. Demo data; FTS + voice +
/// share-with-care-team wiring come next.
public struct JournalView: View {
    @Environment(\.dismiss) private var dismiss
    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    composeCard
                    promptCard
                    Text("Earlier entries").copeSectionLabel(CopeColor.ink3).padding(.leading, 4)
                    entryCard(
                        dotColor: Color(hex: 0x8FC08C), meta: "Yesterday · 9:40 PM", shared: true, voice: false,
                        title: "A better Tuesday",
                        excerpt: "Got out for a walk before the rain. Felt the first bit of lightness in a while…")
                    entryCard(
                        dotColor: CopeColor.amber, meta: "Sunday · 8:12 AM", shared: false, voice: true,
                        title: "Couldn't sleep again",
                        excerpt: "Mind wouldn't settle. Tried the breathing thing Sam showed me…")
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
            Text("Journal").font(CopeFont.sectionTitle).foregroundStyle(CopeColor.ink)
            Spacer()
        }
        .padding(.horizontal, CopeSpacing.screenH).padding(.top, 6).padding(.bottom, 12)
    }

    private var composeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What's on your mind today?").font(CopeFont.body).foregroundStyle(CopeColor.ink3)
            HStack(spacing: 9) {
                composeButton("Write", icon: "square.and.pencil", tint: .teal)
                composeButton("Speak", icon: "mic.fill", tint: .clay)
            }
        }
        .copeCard(padding: 16)
    }

    private func composeButton(_ title: String, icon: String, tint: TodayRow.IconTint) -> some View {
        Label(title, systemImage: icon)
            .font(CopeFont.figtree(13, .semibold))
            .foregroundStyle(tint == .teal ? CopeColor.tealInk : CopeColor.clay)
            .frame(maxWidth: .infinity).padding(.vertical, 11)
            .background(tint == .teal ? CopeColor.tealSoft : CopeColor.claySoft)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private var promptCard: some View {
        FeatureCard(tint: .clay) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Gentle prompt").copeSectionLabel(CopeColor.clay)
                Text("What's one small thing that felt okay today?")
                    .font(CopeFont.sectionTitle).foregroundStyle(CopeColor.ink).fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func entryCard(dotColor: Color, meta: String, shared: Bool, voice: Bool, title: String, excerpt: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                HStack(spacing: 8) {
                    Circle().fill(dotColor).frame(width: 11, height: 11)
                    Text(meta).font(CopeFont.figtree(12.5, .medium)).foregroundStyle(CopeColor.ink2)
                }
                Spacer()
                if shared {
                    Text("Shared with team").font(CopeFont.figtree(10.5, .semibold)).foregroundStyle(CopeColor.tealInk)
                        .padding(.horizontal, 8).padding(.vertical, 3).background(CopeColor.tealSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                if voice {
                    Label("Voice", systemImage: "mic.fill").font(CopeFont.figtree(10.5, .semibold)).foregroundStyle(CopeColor.ink3)
                }
            }
            Text(title).font(CopeFont.sectionTitle).foregroundStyle(CopeColor.ink)
            Text(excerpt).font(CopeFont.callout).foregroundStyle(CopeColor.ink2).fixedSize(horizontal: false, vertical: true)
        }
        .copeCard(padding: 16)
    }
}

#Preview { JournalView() }
