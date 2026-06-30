import Foundation
import CoreText

/// Registers the bundled COPE fonts (Fraunces, Figtree) with the system at
/// launch. Safe to call repeatedly and a no-op if the .ttf assets aren't
/// bundled yet — in which case `Font.custom(...)` falls back to the system font.
///
/// Call once at app startup, e.g. from the App initializer.
public enum CopeFonts {
    /// Candidate filenames to look for (without extension). Add real filenames
    /// here when the font assets are added to the app/package bundle.
    private static let candidates: [String] = [
        "Fraunces", "Fraunces-VariableFont_SOFT,WONK,opsz,wght",
        "Figtree", "Figtree-VariableFont_wght",
        "Figtree-Regular", "Figtree-Medium", "Figtree-SemiBold", "Figtree-Bold"
    ]

    public static func registerIfNeeded() {
        for name in candidates {
            register(name)
        }
    }

    private static func register(_ name: String) {
        for bundle in Bundle.allBundles + Bundle.allFrameworks {
            if let url = bundle.url(forResource: name, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}
