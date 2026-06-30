import SwiftUI

/// The workhorse container: surface background, hairline border, rounded, shadowed.
public struct CopeCard<Content: View>: View {
    private let padding: CGFloat
    private let radius: CGFloat
    private let content: Content

    public init(
        padding: CGFloat = CopeSpacing.cardPadding,
        radius: CGFloat = CopeRadius.card,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.radius = radius
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CopeColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(CopeColor.line, lineWidth: 1)
            )
            .copeShadow(.soft)
    }
}

public extension View {
    /// Apply COPE card chrome to any view without an extra container.
    func copeCard(
        padding: CGFloat = CopeSpacing.cardPadding,
        radius: CGFloat = CopeRadius.card,
        shadow: CopeShadowStyle = .soft
    ) -> some View {
        self
            .padding(padding)
            .background(CopeColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(CopeColor.line, lineWidth: 1)
            )
            .copeShadow(shadow)
    }
}
