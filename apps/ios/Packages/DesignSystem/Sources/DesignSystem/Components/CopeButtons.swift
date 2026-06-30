import SwiftUI

/// Primary CTA: teal→tealDeep gradient, white label, soft teal shadow, press-scale.
public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CopeFont.buttonLabel)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(CopeGradient.primary)
            .clipShape(RoundedRectangle(cornerRadius: CopeRadius.button, style: .continuous))
            .shadow(color: CopeColor.teal.opacity(0.45), radius: 14, x: 0, y: 12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Secondary: surface background, hairline border, ink label.
public struct SecondaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CopeFont.buttonLabel)
            .foregroundStyle(CopeColor.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(CopeColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: CopeRadius.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CopeRadius.button, style: .continuous)
                    .strokeBorder(CopeColor.line, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == PrimaryButtonStyle {
    /// `.buttonStyle(.copePrimary)`
    static var copePrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

public extension ButtonStyle where Self == SecondaryButtonStyle {
    /// `.buttonStyle(.copeSecondary)`
    static var copeSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}
