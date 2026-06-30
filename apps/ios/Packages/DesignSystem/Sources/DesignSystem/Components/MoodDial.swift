import SwiftUI

/// 150×150 circle filled with the current mood color, big Fraunces number
/// centered, colored glow. Animates color + glow on change.
public struct MoodDial: View {
    private let value: Int

    public init(value: Int) {
        self.value = value
    }

    public var body: some View {
        let color = CopeMood.color(for: value)
        Circle()
            .fill(color)
            .frame(width: 150, height: 150)
            .overlay(
                Text("\(value)")
                    .font(CopeFont.numberLarge)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 2)
            )
            .shadow(color: color.opacity(0.55), radius: 26, x: 0, y: 18)
            .animation(.easeOut(duration: 0.3), value: value)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Mood")
            .accessibilityValue("\(value) out of 10, \(CopeMood.word(for: value))")
    }
}
