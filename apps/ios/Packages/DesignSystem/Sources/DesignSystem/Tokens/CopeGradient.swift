import SwiftUI

/// Brand gradients (build bible §3.1).
public enum CopeGradient {
    /// Primary CTA / hero / FAB gradient (≈150°, teal → tealDeep).
    public static var primary: LinearGradient {
        LinearGradient(
            colors: [CopeColor.teal, CopeColor.tealDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Crisis (988) gradient — warm clay, never an alarming red.
    public static var crisis: LinearGradient {
        LinearGradient(
            colors: [CopeColor.clay, CopeColor.clayDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Tinted feature-card wash: a soft tint fading into the surface.
    public static func feature(_ tint: Color) -> LinearGradient {
        LinearGradient(
            colors: [tint, CopeColor.surface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
