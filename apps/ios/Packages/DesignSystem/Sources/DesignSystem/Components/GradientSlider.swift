import SwiftUI

/// A slider with a gradient-filled track and a 28px white thumb. iOS `Slider`
/// can't gradient-fill natively, so this is a `GeometryReader` track + draggable
/// thumb. Used for mood, sleep hours, energy, anxiety.
public struct GradientSlider: View {
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let track: LinearGradient

    private let thumbSize: CGFloat = 28
    private let trackHeight: CGFloat = 10

    public init(
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double = 1,
        track: LinearGradient
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.track = track
    }

    public var body: some View {
        GeometryReader { geo in
            let width = max(thumbSize, geo.size.width)
            let span = range.upperBound - range.lowerBound
            let fraction = span > 0 ? CGFloat((value - range.lowerBound) / span) : 0
            let travel = width - thumbSize

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(track)
                    .frame(height: trackHeight)

                Circle()
                    .fill(.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay(Circle().strokeBorder(.black.opacity(0.06), lineWidth: 1))
                    .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 2)
                    .offset(x: fraction * travel)
            }
            .frame(height: thumbSize, alignment: .leading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let clampedX = min(max(0, gesture.location.x - thumbSize / 2), travel)
                        let fraction = travel > 0 ? Double(clampedX / travel) : 0
                        update(toRaw: range.lowerBound + fraction * span)
                    }
            )
        }
        .frame(height: 34)
        .accessibilityElement()
        .accessibilityValue(Text(value.formatted()))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: update(toRaw: value + step)
            case .decrement: update(toRaw: value - step)
            default: break
            }
        }
    }

    private func update(toRaw raw: Double) {
        let stepped = step > 0 ? (raw / step).rounded() * step : raw
        value = min(max(range.lowerBound, stepped), range.upperBound)
    }
}

public extension GradientSlider {
    /// Mood slider (red→blue scale).
    static func mood(value: Binding<Double>, in range: ClosedRange<Double> = 1...10, step: Double = 1) -> GradientSlider {
        GradientSlider(value: value, in: range, step: step, track: CopeMood.sliderTrack)
    }

    /// Teal slider (sleep hours, energy).
    static func teal(value: Binding<Double>, in range: ClosedRange<Double>, step: Double = 1) -> GradientSlider {
        GradientSlider(
            value: value,
            in: range,
            step: step,
            track: LinearGradient(colors: [CopeColor.tealSoft, CopeColor.teal], startPoint: .leading, endPoint: .trailing)
        )
    }

    /// Clay slider (anxiety).
    static func clay(value: Binding<Double>, in range: ClosedRange<Double>, step: Double = 1) -> GradientSlider {
        GradientSlider(
            value: value,
            in: range,
            step: step,
            track: LinearGradient(colors: [CopeColor.claySoft, CopeColor.clay], startPoint: .leading, endPoint: .trailing)
        )
    }
}
