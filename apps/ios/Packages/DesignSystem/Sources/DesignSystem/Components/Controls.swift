import SwiftUI

/// 52×31 pill toggle, teal when on, 25px white knob translating 21px (medication
/// adherence).
public struct MedToggle: View {
    @Binding private var isOn: Bool

    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }

    public var body: some View {
        Button {
            isOn.toggle()
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? CopeColor.teal : CopeColor.surface3)
                    .frame(width: 52, height: 31)
                Circle()
                    .fill(.white)
                    .frame(width: 25, height: 25)
                    .shadow(color: .black.opacity(0.28), radius: 3, x: 0, y: 1)
                    .padding(3)
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isOn)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isOn ? "Taken" : "Not taken")
    }
}

/// 6px progress track with a teal→tealDeep fill that animates width.
public struct CopeProgressBar: View {
    private let progress: Double

    public init(progress: Double) {
        self.progress = min(max(0, progress), 1)
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(CopeColor.surface3)
                Capsule()
                    .fill(CopeGradient.primary)
                    .frame(width: geo.size.width * progress)
            }
            .animation(.easeInOut(duration: 0.35), value: progress)
        }
        .frame(height: 6)
        .accessibilityElement()
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}
