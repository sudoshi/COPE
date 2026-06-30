import SwiftUI

/// The 1–10 diverging mood scale (red → amber → teal → blue) and its words.
///
/// This is a defining piece of COPE's visual language: the mood dial *is* its
/// color, and 7-day mini charts are tinted by it. Values are authoritative
/// (build bible §3.2).
public enum CopeMood {
    /// Index 0 == mood 1, … index 9 == mood 10.
    public static let colors: [Color] = moodHexes.map { Color(hex: $0) }

    private static let moodHexes: [UInt32] = [
        0xD9645A, 0xDD7A5B, 0xE0935F, 0xE4AD61, 0xE7C765,
        0xBFC77A, 0x8FC08C, 0x6FB89A, 0x64A6B0, 0x5A93C4
    ]

    /// Word for each mood value (index 0 == mood 1).
    public static let words: [String] = [
        "Really low", "Low", "Heavy", "Tender", "Neutral",
        "Steadying", "Okay", "Good", "Bright", "Really good"
    ]

    /// Clamped color for a 1–10 mood value.
    public static func color(for value: Int) -> Color {
        colors[clampIndex(value)]
    }

    /// Clamped word for a 1–10 mood value.
    public static func word(for value: Int) -> String {
        words[clampIndex(value)]
    }

    /// Gradient used as the mood slider track (left = low, right = high).
    public static let sliderTrack = LinearGradient(
        colors: ([0xD9645A, 0xE0935F, 0xE7C765, 0x8FC08C, 0x5A93C4] as [UInt32]).map { Color(hex: $0) },
        startPoint: .leading,
        endPoint: .trailing
    )

    private static func clampIndex(_ value: Int) -> Int {
        min(max(0, value - 1), colors.count - 1)
    }
}
