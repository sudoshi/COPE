import SwiftUI

/// Always-available safety affordance: dashed border, shield, "988 inside".
/// The single most important navigational element — placement is consistent
/// everywhere it appears (WCAG 3.2.6).
public struct SafetyButton: View {
    private let title: String
    private let subtitle: String
    private let action: () -> Void

    public init(
        title: String = "My safety plan",
        subtitle: String = "Always one tap away · 988 lifeline inside",
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "shield")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(CopeColor.ink2)
                    .frame(width: 34, height: 34)
                    .background(CopeColor.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(CopeFont.figtree(13.5, .semibold))
                        .foregroundStyle(CopeColor.ink)
                    Text(subtitle)
                        .font(CopeFont.micro)
                        .foregroundStyle(CopeColor.ink2)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(CopeColor.ink3)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(CopeColor.line, style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}

/// Settings list row: icon tile + label + trailing value/chevron.
public struct SettingsRow: View {
    private let icon: String
    private let title: String
    private let value: String?
    private let showsChevron: Bool
    private let action: () -> Void

    public init(
        icon: String,
        title: String,
        value: String? = nil,
        showsChevron: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.showsChevron = showsChevron
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(CopeColor.tealInk)
                    .frame(width: 34, height: 34)
                    .background(CopeColor.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(title)
                    .font(CopeFont.figtree(14.5, .medium))
                    .foregroundStyle(CopeColor.ink)

                Spacer(minLength: 8)

                if let value {
                    Text(value)
                        .font(CopeFont.figtree(12, .semibold))
                        .foregroundStyle(CopeColor.teal)
                }
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(CopeColor.ink3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
