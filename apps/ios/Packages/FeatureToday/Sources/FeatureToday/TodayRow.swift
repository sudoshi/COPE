import SwiftUI
import DesignSystem

/// A single row in the Today list: icon tile + title/subtitle + trailing
/// badge or chevron, with an optional unread dot on the icon.
struct TodayRow: View {
    enum Trailing {
        case chevron
        case badge(String)
    }

    enum IconTint {
        case teal, clay
    }

    let icon: String
    let iconTint: IconTint
    let title: String
    let subtitle: String
    let trailing: Trailing
    var showsUnread: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                iconTile
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(CopeFont.figtree(15, .semibold))
                        .foregroundStyle(CopeColor.ink)
                    Text(subtitle)
                        .font(CopeFont.figtree(12.5))
                        .foregroundStyle(CopeColor.ink2)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                trailingView
            }
            .copeCard(padding: 15)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }

    private var iconTile: some View {
        Image(systemName: icon)
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(iconForeground)
            .frame(width: 42, height: 42)
            .background(iconBackground)
            .clipShape(RoundedRectangle(cornerRadius: CopeRadius.iconTile, style: .continuous))
            .overlay(alignment: .topTrailing) {
                if showsUnread {
                    Circle()
                        .fill(CopeColor.clay)
                        .frame(width: 11, height: 11)
                        .overlay(Circle().strokeBorder(CopeColor.surface, lineWidth: 2))
                        .offset(x: 2, y: -2)
                }
            }
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(CopeColor.ink3)
        case .badge(let text):
            Text(text)
                .font(CopeFont.figtree(12, .semibold))
                .foregroundStyle(CopeColor.clay)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(CopeColor.claySoft)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private var iconBackground: Color {
        iconTint == .teal ? CopeColor.tealSoft : CopeColor.claySoft
    }

    private var iconForeground: Color {
        iconTint == .teal ? CopeColor.tealInk : CopeColor.clay
    }
}
