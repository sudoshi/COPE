# ⚠️ DEPRECATED — front-end UI layer

The **UI/design layer** in this directory is being superseded by a de novo build
that matches the gold-standard prototype (`apps/ios/COPE/COPE iOS Prototype.dc.html`)
and build bible (`COPE-iOS-SwiftUI-BUILD-PROMPT.md`). See the migration plan in
`docs/strategy/06-IOS-GOLD-STANDARD-GAP-ANALYSIS.md`.

The previous UI used a dark-only, cold palette and a single-form check-in that
does not reflect the intended warm, calm, one-question-per-screen experience.

## What is being replaced (deprecated)

The **view/design layer** — these are superseded by the new `DesignSystem` package
(`apps/ios/Packages/DesignSystem`) and forthcoming `Feature*` packages:

- `DesignTokens.swift` (cold palette) → `DesignSystem.CopeColor` / `CopeFont` / tokens
- `TodayView.swift`, `CareView.swift`, `AssessmentsView.swift`,
  `PatientHomeView.swift`, `OnboardingConsentView.swift`,
  `OnboardingIntakeView.swift`, `RootView.swift` (UI portions)

These files remain in place **only** so the app keeps compiling during the
migration. They will be removed screen-by-screen as each gold-standard surface
lands and the composition root switches over.

## What is PRESERVED (not deprecated)

The engineering substrate is sound and is being **kept and reused**:

- Auth (`LoginView`, `SessionViewModel`, `KeychainTokenStore`) — also protected by
  `.claude/rules/auth-system.md`; **do not weaken or remove**.
- `APIClient.swift` + the `COPEOpenAPI` generated client.
- Offline/sync: `DailyEntryDraftStore`, `LocalOutboxStore`, `EncryptedLocalFileStore`,
  `SafetyResourceCacheStore`.
- `NotificationRegistrationService`, `LocalPatientDataWiper`, `AppConfiguration`,
  `ConsentContent`.

The new UI will sit on top of (and incrementally repackage) this substrate. No
auth endpoint or flow is changed by the migration.
