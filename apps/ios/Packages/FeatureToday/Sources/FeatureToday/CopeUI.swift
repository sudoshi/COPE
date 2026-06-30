import DesignSystem

/// App-facing entry point for one-time UI setup. Call `bootstrap()` once at
/// launch so the bundled Fraunces/Figtree fonts are registered before the first
/// view renders.
public enum CopeUI {
    public static func bootstrap() {
        CopeFonts.registerIfNeeded()
    }
}
