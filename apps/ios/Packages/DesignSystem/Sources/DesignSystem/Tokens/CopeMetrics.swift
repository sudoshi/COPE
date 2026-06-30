import CoreGraphics

/// Corner radii (build bible §3.4).
public enum CopeRadius {
    public static let chip: CGFloat = 11
    public static let pill: CGFloat = 13
    public static let button: CGFloat = 17
    public static let card: CGFloat = 20
    public static let cardLarge: CGFloat = 22
    public static let hero: CGFloat = 26
    public static let iconTile: CGFloat = 13
}

/// Spacing scale.
public enum CopeSpacing {
    /// Horizontal screen content padding.
    public static let screenH: CGFloat = 20
    public static let cardPadding: CGFloat = 16
    public static let cardPaddingLarge: CGFloat = 22
    public static let gap: CGFloat = 12
    public static let gapSmall: CGFloat = 8
}

/// Minimum interactive hit target.
public enum CopeLayout {
    public static let minTarget: CGFloat = 44
}
