import SwiftUI

/// Typography scale. Fraunces (variable serif) for human moments — greetings,
/// titles, question prompts, big numbers — and Figtree for UI. All styles use
/// `relativeTo:` so they scale with Dynamic Type (build bible §3.3).
///
/// If the .ttf assets aren't bundled, `Font.custom` falls back to the system
/// font automatically — register the real fonts via `CopeFonts.registerIfNeeded()`.
public enum CopeFont {
    public static let displayFamily = "Fraunces"
    public static let uiFamily = "Figtree"

    // MARK: Fraunces (serif) — human moments
    public static var display: Font { fraunces(30, .semibold, relativeTo: .largeTitle) }
    public static var title: Font { fraunces(26, .semibold, relativeTo: .title) }
    public static var sectionTitle: Font { fraunces(19, .semibold, relativeTo: .title3) }
    public static var question: Font { fraunces(26, .semibold, relativeTo: .title) }
    public static var numberLarge: Font { fraunces(46, .semibold, relativeTo: .largeTitle) }
    public static var numberMedium: Font { fraunces(24, .semibold, relativeTo: .title2) }

    // MARK: Figtree (sans) — UI chrome
    public static var body: Font { figtree(15, .regular, relativeTo: .body) }
    public static var bodyStrong: Font { figtree(15, .semibold, relativeTo: .body) }
    public static var callout: Font { figtree(13.5, .regular, relativeTo: .callout) }
    public static var caption: Font { figtree(12.5, .regular, relativeTo: .caption) }
    public static var micro: Font { figtree(11, .medium, relativeTo: .caption2) }
    public static var label: Font { figtree(12.5, .semibold, relativeTo: .caption) }
    public static var buttonLabel: Font { figtree(15.5, .semibold, relativeTo: .body) }

    public static func fraunces(_ size: CGFloat, _ weight: Font.Weight = .semibold, relativeTo style: Font.TextStyle = .body) -> Font {
        Font.custom(displayFamily, size: size, relativeTo: style).weight(weight)
    }

    public static func figtree(_ size: CGFloat, _ weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        Font.custom(uiFamily, size: size, relativeTo: style).weight(weight)
    }
}

public extension Text {
    /// Uppercase, tracked section label — e.g. "MORNING CHECK-IN", "TODAY".
    func copeSectionLabel(_ color: Color = CopeColor.ink3) -> some View {
        self.font(CopeFont.label)
            .tracking(0.4)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}
