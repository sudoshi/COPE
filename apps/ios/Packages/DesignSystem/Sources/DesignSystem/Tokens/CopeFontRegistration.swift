import Foundation
import CoreText

/// Registers the bundled COPE fonts (Fraunces, Figtree) with the system at
/// launch so `Font.custom("Fraunces"/"Figtree", …)` resolves to the real type.
/// Idempotent and safe to call repeatedly; if an asset is missing, SwiftUI
/// simply falls back to the system font.
///
/// Call once at app startup (see FeatureToday's `CopeUI.bootstrap()`).
public enum CopeFonts {
    public static func registerIfNeeded() {
        register("Fraunces")
        register("Figtree")
    }

    private static func register(_ name: String) {
        guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}
