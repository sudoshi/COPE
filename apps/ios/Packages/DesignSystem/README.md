# DesignSystem

The warm, two-theme COPE design system — the visual foundation of the de novo
native iOS patient app. Ports the gold-standard prototype (`COPE iOS
Prototype.dc.html`) and build bible §3–4 into reusable SwiftUI.

## What's inside

**Tokens**
- `CopeColor` — semantic palette, light **+** dark, resolved per `ColorScheme`
  (warm paper canvas, teal primary, clay accent, amber).
- `CopeMood` — the 1–10 red→blue mood scale (colors, words, slider gradient).
- `CopeFont` — Fraunces (serif display) + Figtree (UI), Dynamic-Type aware.
- `CopeRadius` / `CopeSpacing` / `CopeLayout` — shape & spacing.
- `CopeShadow` (`.copeShadow()`), `CopeGradient` (primary, crisis, feature).

**Components**
- `CopeCard` / `.copeCard()`, `FeatureCard` (teal/clay)
- `PrimaryButtonStyle` / `SecondaryButtonStyle` (`.buttonStyle(.copePrimary)`)
- `MoodDial`, `GradientSlider` (`.mood` / `.teal` / `.clay`)
- `ChoiceChip`, `SegmentedChoice`, `StackedOption`
- `MedToggle`, `CopeProgressBar`
- `SafetyButton`, `SettingsRow`

## Build & test

```bash
cd apps/ios/Packages/DesignSystem
swift build      # type-checks on macOS (verification target)
swift test
```

The package targets iOS 17 and (for `swift build` verification only) macOS 14.

## Fonts

Fraunces/Figtree `.ttf` assets are **not yet bundled** — `Font.custom(...)`
falls back to the system font until they are. To bundle:
1. Add the `.ttf` files under `Sources/DesignSystem/Resources/Fonts/`.
2. Add `resources: [.process("Resources")]` to the `DesignSystem` target in
   `Package.swift`.
3. Update the filename candidates in `CopeFontRegistration.swift` and call
   `CopeFonts.registerIfNeeded()` once at app launch.

## Integrating into the app target

This is a local SPM package, mirroring the existing `COPEOpenAPI` package. To
link it into the `COPE` app target, add an `XCLocalSwiftPackageReference`
(`relativePath = "Packages/DesignSystem"`) plus a `DesignSystem` product
dependency in `COPE.xcodeproj` — a single, well-understood project edit, then
`import DesignSystem`.
