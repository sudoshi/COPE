import SwiftUI

/// Semantic color palette, resolved per color scheme.
///
/// Hex values are authoritative and taken from the gold-standard prototype
/// (`COPE iOS Prototype.dc.html`) and build bible §3.1. Light-first, with a
/// warm paper canvas, teal primary, and clay warm accent.
public enum CopeColor {
    // MARK: Surfaces
    public static let canvas    = Color(light: Color(hex: 0xF1ECE4), dark: Color(hex: 0x101413))
    public static let surface   = Color(light: Color(hex: 0xFFFFFF), dark: Color(hex: 0x1B211F))
    public static let surface2  = Color(light: Color(hex: 0xFAF6F0), dark: Color(hex: 0x212825))
    public static let surface3  = Color(light: Color(hex: 0xF3EEE6), dark: Color(hex: 0x283029))

    // MARK: Ink (text)
    public static let ink  = Color(light: Color(hex: 0x20251F), dark: Color(hex: 0xEDF0EA))
    public static let ink2 = Color(light: Color(hex: 0x5D625B), dark: Color(hex: 0xA4AAA1))
    public static let ink3 = Color(light: Color(hex: 0x9A9E96), dark: Color(hex: 0x6E746C))

    // MARK: Hairlines
    public static let line  = Color(light: Color(hex: 0x20251F, alpha: 0.09), dark: Color(hex: 0xFFFFFF, alpha: 0.10))
    public static let line2 = Color(light: Color(hex: 0x20251F, alpha: 0.05), dark: Color(hex: 0xFFFFFF, alpha: 0.05))

    // MARK: Teal (primary)
    public static let teal     = Color(light: Color(hex: 0x2F9E8F), dark: Color(hex: 0x54B9A8))
    public static let tealDeep = Color(light: Color(hex: 0x1F6F64), dark: Color(hex: 0x7FD3C4))
    public static let tealSoft = Color(light: Color(hex: 0xE3F1ED), dark: Color(hex: 0x54B9A8, alpha: 0.15))
    public static let tealInk  = Color(light: Color(hex: 0x1C5F56), dark: Color(hex: 0x8FDCCD))

    // MARK: Clay (warm accent)
    public static let clay     = Color(light: Color(hex: 0xD68A68), dark: Color(hex: 0xE09E7F))
    public static let claySoft = Color(light: Color(hex: 0xF6E7DF), dark: Color(hex: 0xE09E7F, alpha: 0.16))
    /// Deep clay used only as the second stop of the crisis (988) gradient.
    public static let clayDeep = Color(hex: 0xC06A4B)

    // MARK: Amber
    public static let amber = Color(light: Color(hex: 0xE3A93F), dark: Color(hex: 0xE9B95A))

    // MARK: Semantic aliases
    /// Background of the whole screen.
    public static let background = canvas
    /// Primary text.
    public static let textPrimary = ink
    /// Secondary text.
    public static let textSecondary = ink2
    /// Tertiary / placeholder text.
    public static let textTertiary = ink3
}
