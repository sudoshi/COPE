import SwiftUI
import DesignSystem

/// A minimalist, tappable body figure (build bible §6.4 step 5). Tapping a
/// region fills it teal and adds it to the selection — somatic input for
/// feelings that are hard to put in words.
struct BodyMapView: View {
    @Binding var selected: Set<String>

    private let canvas = CGSize(width: 172, height: 286)

    var body: some View {
        ZStack {
            region("head", shape: Circle(), size: CGSize(width: 46, height: 46), center: CGPoint(x: 86, y: 26))
            region("arms", shape: rr(12), size: CGSize(width: 20, height: 104), center: CGPoint(x: 30, y: 120))
            region("arms", shape: rr(12), size: CGSize(width: 20, height: 104), center: CGPoint(x: 142, y: 120))
            region("chest", shape: rr(22), size: CGSize(width: 84, height: 58), center: CGPoint(x: 86, y: 96))
            region("stomach", shape: rr(20), size: CGSize(width: 74, height: 56), center: CGPoint(x: 86, y: 152))
            region("legs", shape: rr(14), size: CGSize(width: 30, height: 102), center: CGPoint(x: 68, y: 232))
            region("legs", shape: rr(14), size: CGSize(width: 30, height: 102), center: CGPoint(x: 104, y: 232))
        }
        .frame(width: canvas.width, height: canvas.height)
    }

    private func rr(_ radius: CGFloat) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }

    @ViewBuilder
    private func region(_ key: String, shape: some InsettableShape, size: CGSize, center: CGPoint) -> some View {
        let isOn = selected.contains(key)
        shape
            .fill(isOn ? CopeColor.teal : CopeColor.surface3)
            .overlay(shape.strokeBorder(isOn ? CopeColor.tealDeep : CopeColor.line, lineWidth: 1.5))
            .frame(width: size.width, height: size.height)
            .shadow(color: isOn ? CopeColor.teal.opacity(0.45) : .clear, radius: 10, y: 6)
            .position(center)
            .contentShape(shape)
            .onTapGesture { toggle(key) }
            .animation(.easeOut(duration: 0.15), value: isOn)
            .accessibilityLabel(key.capitalized)
            .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }

    private func toggle(_ key: String) {
        if selected.contains(key) { selected.remove(key) } else { selected.insert(key) }
    }
}
