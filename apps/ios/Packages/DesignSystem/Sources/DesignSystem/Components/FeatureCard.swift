import SwiftUI

/// A tinted, gradient-washed card with a colored border — used for the privacy
/// card, correlation card, escalation trust card, etc.
public struct FeatureCard<Content: View>: View {
    public enum Tint {
        case teal, clay
    }

    private let tint: Tint
    private let content: Content

    public init(tint: Tint = .teal, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    public var body: some View {
        content
            .padding(CopeSpacing.cardPaddingLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CopeGradient.feature(softTint))
            .clipShape(RoundedRectangle(cornerRadius: CopeRadius.cardLarge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CopeRadius.cardLarge, style: .continuous)
                    .strokeBorder(borderTint, lineWidth: 1)
            )
    }

    private var softTint: Color {
        tint == .teal ? CopeColor.tealSoft : CopeColor.claySoft
    }

    private var borderTint: Color {
        tint == .teal ? CopeColor.teal : CopeColor.clay
    }
}
