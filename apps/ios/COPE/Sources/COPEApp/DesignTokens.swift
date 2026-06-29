import SwiftUI

enum CopeColor {
    static let background = Color(hex: 0x0C0F18)
    static let surface = Color(hex: 0x161A27)
    static let surfaceElevated = Color(hex: 0x1A2040)
    static let border = Color(hex: 0x1E2535)
    static let primary = Color(hex: 0x2A9D8F)
    static let primaryDark = Color(hex: 0x1D7A6F)
    static let text = Color(hex: 0xE2E8F0)
    static let textMuted = Color(hex: 0x8B9CB0)
    static let danger = Color(hex: 0xFC8181)
    static let success = Color(hex: 0x22C55E)
    static let warning = Color(hex: 0xFAA307)
}

private extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
