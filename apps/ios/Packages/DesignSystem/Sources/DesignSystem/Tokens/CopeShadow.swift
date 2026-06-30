import SwiftUI

public enum CopeShadowStyle {
    /// Small ambient shadow for inline rows/stat cards.
    case soft
    /// The workhorse card shadow (two layers).
    case card
}

public extension View {
    /// Applies COPE's layered card shadow, adapting to color scheme.
    func copeShadow(_ style: CopeShadowStyle = .card) -> some View {
        modifier(CopeShadowModifier(style: style))
    }
}

private struct CopeShadowModifier: ViewModifier {
    let style: CopeShadowStyle

    func body(content: Content) -> some View {
        switch style {
        case .soft:
            content.shadow(color: small, radius: 1, x: 0, y: 1)
        case .card:
            content
                .shadow(color: small, radius: 1, x: 0, y: 1)
                .shadow(color: big, radius: 16, x: 0, y: 12)
        }
    }

    private var small: Color {
        Color(light: Color(hex: 0x20251F, alpha: 0.06), dark: Color(hex: 0x000000, alpha: 0.35))
    }

    private var big: Color {
        Color(light: Color(hex: 0x20251F, alpha: 0.14), dark: Color(hex: 0x000000, alpha: 0.6))
    }
}
