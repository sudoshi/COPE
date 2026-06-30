# 06 — iOS Gold-Standard Gap Analysis

**Date:** 2026-06-29
**Scope:** Maps the gold-standard UX/UI (the build bible + interactive prototype in `apps/ios/COPE/`) against the **current** native SwiftUI scaffold (`apps/ios/COPE/COPE/Sources/COPEApp/`), screen by screen, with the work required to close each gap.

**Sources of truth**
- Behavioral/engineering: `apps/ios/COPE/COPE-iOS-SwiftUI-BUILD-PROMPT.md` (the "Full Bible," §1–15)
- Visual/interaction: `apps/ios/COPE/COPE iOS Prototype.dc.html` (rendered via `support.js`, a React templating runtime — not app code)
- Current code: `apps/ios/COPE/COPE/Sources/COPEApp/*.swift` + local SPM package `COPEOpenAPI`

---

## 0. TL;DR verdict

The split is clean and important:

- **The engineering substrate is real and worth keeping.** Auth + MFA, a generated OpenAPI client (`COPEOpenAPI`), the offline daily-entry draft store, the sync outbox with flush-on-load, encrypted local file storage, keychain token storage, safety-resource offline cache, push-token registration, and consent/notification wiring all exist and broadly work.
- **The design/UX layer contradicts the vision and is the bulk of the work.** The current palette is a **dark-only, cold "dev-tool" theme** (`#0C0F18` near-black), system font only (no Fraunces/Figtree), radius-8 boxes everywhere, no gradients, no mood color scale. The navigation is a flat 4-tab bar with no center check-in FAB and no Insights tab.
- **Roughly half the gold-standard surfaces don't exist at all:** the 10-step check-in hero flow, secure care-team messaging (the #1 differentiator), Insights, Medications UI, Journal, and Pre-visit prep.

**Effort shape:** ~20% is reskinning screens whose logic already works; ~50% is net-new feature builds (some needing additive backend); ~30% is foundation (design system, navigation shell, clinical-scoring core) that unblocks everything else.

---

## 1. Foundation gaps (cross-cutting — these block or degrade every screen)

| # | Foundation | Current state | Gold standard (prompt §) | Work to close | Effort |
|---|---|---|---|---|---|
| F1 | **Design tokens** | `DesignTokens.swift`: dark-only, cold; `background #0C0F18`, `surface #161A27`, `primary #2A9D8F`, `text/textMuted/danger/success/warning`. No light theme, no `canvas/surface-2/3`, no `ink/ink-2/ink-3`, no `clay/amber`, no mood scale, radius 8. | §3.1–3.4: warm light **+** dark, full semantic palette, mood scale, gradients, radii 11–26 | New `DesignSystem` SPM package; port the prototype's `[data-theme]` tokens verbatim, resolved per `colorScheme` + `@AppStorage` manual override; primary/crisis gradients; shadow tokens | **L** |
| F2 | **Typography** | System font (`.system(size:weight:)`) everywhere | §3.3: **Fraunces** (variable serif) for headers/numbers/prompts; **Figtree** for UI; Dynamic Type | Bundle + register both fonts (`UIAppFonts`); `Font` helpers; a Dynamic-Type scale | **M** |
| F3 | **Navigation shell** | `PatientHomeView`: 4-tab `TabView` (Today, Assessments, Care, Profile). No FAB, no Insights, no full-screen check-in cover. | §5: 5 tabs **Today · Insights · [+FAB] · Care · You**; raised teal center FAB → check-in `.fullScreenCover`; Safety/Meds/Assessment/Journal/Pre-visit as covers | Rebuild `MainTabView` with custom translucent tab bar + raised FAB; `AppState` holder (tab/unlock/theme); cover routing | **L** |
| F4 | **Component library** | None. Ad-hoc `RoundedRectangle(cornerRadius: 8)` + `Slider().tint()` inline per view. | §4: `PrimaryButton`, `SecondaryButton`, `CopeCard`, `FeatureCard`, `MoodDial`, gradient `MoodSlider/TealSlider/ClaySlider`, `SegmentedChoice`, `ChoiceChip`, `StackedOption`, `MedToggle`, `SettingsRow`, `ProgressBar`, `SafetyButton` | Build all §4 components in `DesignSystem` (gradient sliders need a `GeometryReader` track + draggable thumb — native `Slider` can't gradient-fill) | **L** |
| F5 | **Clinical scoring core** | Scoring is ad hoc in `AssessmentsViewModel` (just sums items); no interpretation bands, no item-9 logic. | §13: `CopeCore` with validated PHQ-9/GAD-7/ASRM/ISI/C-SSRS/WHODAS/QIDS-SR scoring + bands + **golden fixture tests**; centralized provisional `ALERT_THRESHOLDS` | New `CopeCore` package mirroring `@cope/shared`; golden tests vs. server | **M** |
| F6 | **Module structure** | Single `COPEApp` target + `COPEOpenAPI` local package. | §2: local SPM `DesignSystem`, `CopeCore`, `Networking`, `Persistence`, `Feature*` | Introduce packages incrementally (DesignSystem + CopeCore first); thin app target as composition root | **M** (ongoing) |

> **Do F1–F4 first.** Every screen below assumes they exist; attempting screens before the design system means throwaway work.

---

## 2. Screen-by-screen mapping

Legend — **Data/Logic** and **Design/Flow** each rated ○ none · ◑ partial · ● done. **Verdict:** *Reskin* (logic exists, needs warm UI) · *Rebuild* (flow + partial logic) · *Net-new*.

| Gold-standard screen (prompt §) | Maps to current file | Data/Logic | Design/Flow | Verdict | Effort |
|---|---|:--:|:--:|---|:--:|
| 6.1 Onboarding (5-step) | `OnboardingConsentView` + `OnboardingIntakeView` | ◑ | ○ | Rebuild | L |
| 6.2 Auth (login/MFA/biometric) | `LoginView` | ● | ◑ | Reskin (+biometric) | M |
| 6.3 Today / Home | `TodayView` | ◑ | ○ | Rebuild | L |
| 6.4 Daily check-in **(HERO, 10 steps)** | *(logic in `TodayView`/VM; no flow UI)* | ◑ | ○ | Net-new flow | **XL** |
| 6.5 Safety plan | section inside `CareView` (`SafetyPlanCard`) | ● | ○ | Rebuild as own screen | M |
| 6.6 Care / secure messaging **(TOP DIFFERENTIATOR)** | `CareView` *(currently a consent/notif/safety hub — not messaging)* | ○ | ○ | **Net-new** (+backend) | **XL** |
| 6.7 Insights | *(none)* | ○ | ○ | Net-new | L |
| 6.8 Assessments (PHQ-9 + engine) | `AssessmentsView` | ◑ | ○ | Rebuild | L |
| 6.9 Medications | *(none; only `createMedication` wired)* | ◑ | ○ | Net-new | M |
| 6.10 Journal | *(none)* | ○ | ○ | Net-new (+API) | L |
| 6.11 You / Profile & privacy | `ProfileTabView` (in `PatientHomeView`) | ◑ | ○ | Rebuild | M |
| 6.12 Pre-visit prep | *(none)* | ○ | ○ | Net-new (+API) | M |

### Detail

**6.1 Onboarding** → `OnboardingConsentView` (161 lines, consent gate) + `OnboardingIntakeView` (525 lines, intake: concerns/emergency contact/catalogues/med setup).
- *Have:* consent capture, intake PATCH (`patients/me/intake`), symptom/trigger/strategy catalogues, medication create — all wired.
- *Gap:* gold standard is a single **5-step warm flow** (Welcome → Privacy promise → About-you concern chips + assigned-clinician card → Daily-rhythm reminders → Ready). Current is two cold form screens, no progress bar, no privacy-promise step, no reminder scheduling.
- *Work:* compose 5-step `FeatureOnboarding` flow on the design system; keep the existing intake/consent calls; add local-notification scheduling (F-cross C2).

**6.2 Auth** → `LoginView` (394 lines: login + register + MFA verify).
- *Have:* email/password login, demo register, MFA TOTP verify, token storage to keychain.
- *Gap:* cold styling; **biometric unlock on relaunch** and **forced-password-change modal** not evident; need paste/autofill (WCAG 3.3.8), auto-logoff, blur-on-resign.
- *Work:* reskin to Fraunces/`CopeCard`/`PrimaryButton`; add Face ID unlock bound to a keychain crypto op (§8); forced-password-change cover.

**6.3 Today / Home** → `TodayView` (611 lines).
- *Have:* `todayDailyEntry()` load, draft restore, outbox status, sync flush.
- *Gap:* **Today currently *is* the check-in form** (mood/anxiety/stress/SI/sleep/notes sliders on one card). Gold standard is a calm dashboard: greeting + avatar, teal **hero check-in card**, **Gentle streak** + **7-day mood mini-bar**, and a TODAY list (meds "2 due", PHQ-9 due, "Dr. Alvarez replied" w/ unread dot, Pre-visit, dashed Safety affordance).
- *Work:* **move the check-in out of Today** into the hero flow (6.4); rebuild Today as a dashboard pulling `daily-entries/today`, `medications/today`, `assessments/pending`, last message, local streak.

**6.4 Daily check-in — THE HERO** → logic lives in `TodayViewModel`; **no dedicated flow UI exists.**
- *Have (substantial!):* mood/sleep/anxiety/stress/SI/notes capture, local draft (file-protected), outbox enqueue, save→submit, flush-on-reconnect — the offline-first spine §6.4/§10 demands.
- *Gap:* the entire **10-step, one-question-per-screen** experience: `MoodDial`, **feeling-words picker (NEW)**, sleep hours+quality, energy+anhedonia, anxiety, **body map (NEW)**, **adaptive mania pole** (bipolar-only), what's-present triggers, **C-SSRS gentle item with inline escalation card** (reveals at ≥"Some of the time"), reflection + voice + recap. Current model captures only 6 fields; gold standard adds `feelings[]`, `body[]`, `energy`, `anhedonia`, `mania`, `triggers[]`.
- *Work:* build `FeatureCheckIn` step-machine VM + 10 step views; extend the daily-entry draft/model and `ApiV1DailyEntriesPostRequest` mapping to the additional clinical-domain columns (the entry has 21 columns server-side; iOS uses 6); wire the **safety escalation pattern (§7)** as a shared surface; mark C-SSRS positive as a high-priority sync op.
- *Note:* prompt §14 says "8-step" but §6.4 + prototype enumerate **10 steps (0–9)** — build the 10-step version.

**6.5 Safety plan** → currently a **section** in `CareView` (`SafetyPlanCard` + `SafetyResourceRow`).
- *Have:* `mySafetyPlan()` GET (404→empty), `signMySafetyPlan()`, `safetyResources()`, **offline cache** via `SafetyResourceCacheStore`, `tel:`/`sms:` links on resources.
- *Gap:* not its own screen, not globally reachable, no warm **clay 988 crisis card** (Call/Text 988), no numbered Stanley-Brown sections with teal numerals, no contact call rows styled per prototype.
- *Work:* promote to a `FeatureSafety` full-screen cover reachable from everywhere (Today, check-in branch, Care footer); hardcode verified 988/741741 actions; ensure it opens instantly from cache (offline).

**6.6 Care / secure messaging — TOP DIFFERENTIATOR** → `CareView` (768 lines) is **mis-named**: it's a consent + notification-prefs + safety hub, **not** messaging.
- *Have:* nothing messaging-related. No messages UI, no `messages` API method, no WebSocket.
- *Gap:* the entire differentiator — team thread (overlapped avatars, "replies within 1 business day"), clinician/patient bubbles + Read receipts, **escalation trust card**, structured between-visit quick-reply prompts, composer with required **988 footer**.
- *Work:* **largest net-new.** Backend `messages` resource + `/messages` REST + WS `message.created` are *additive and don't exist yet* (prompt §6.6/§9 flag them as additive). Build `Networking` WebSocket actor (heartbeat/backoff/re-auth), `FeatureCare` thread UI, and the structured-prompt post path. Move the current consent/notification controls to **You** (6.11) where they belong.

**6.7 Insights** → **no screen / no tab.**
- *Gap/Work:* net-new `FeatureInsights` tab — Swift Charts mood line (14d) w/ area gradient, **correlation FeatureCard** (`patient_correlation_cache`), Sleep-avg + PHQ-9 stat cards, **AI weekly reflection** (consent + BAA gated, "not a diagnosis"). Wire `GET /insights/me?days=30`, `/risk-scores`, `/ai`. Add Swift Charts (none today).

**6.8 Assessments** → `AssessmentsView` (264 lines).
- *Have:* `pendingAssessments()`, `submitAssessment()`, generic item count/range per scale.
- *Gap:* raw UX — generic "Item 1…9" steppers, **no real PHQ-9 item wording on screen**, no warm intro, no one-question-per-screen auto-advance, no result circle/interpretation bands, **no C-SSRS / item-9 safety handoff**. (The prototype hardcodes the 9 PHQ items + bands Minimal/Mild/Moderate/Mod-severe/Severe.)
- *Work:* `FeatureAssessments` intro → per-question `StackedOption` flow (item text from `CopeCore`) → result with band + prior comparison; hook item-9>0 into the shared safety handoff (§7); generalize to GAD-7/ASRM/ISI/WHODAS/QIDS-SR; wire `:scale/responses` + `:id/fhir`.

**6.9 Medications** → **no screen.** Only `createMedication()` is wired (used in onboarding).
- *Gap/Work:* net-new `FeatureMeds` cover — summary card, grouped doses (Morning/Evening) with `MedToggle` adherence, side-effect prompt, per-med local reminders. Wire `GET /medications/today` + `POST /medications/:id/logs` (not yet wired).

**6.10 Journal** → **no screen / no API wired.**
- *Gap/Work:* net-new `FeatureJournal` — compose (Write/Speak), gentle-prompt card, entry list w/ shared/voice badges, detail/edit + share toggle, FTS search (GRDB FTS5), voice via `POST /voice/transcribe` (multipart). Reuse the feeling-words picker here per §6.4. Wire `GET/POST/PATCH /journal`, `/journal/:id/share`.

**6.11 You / Profile & privacy** → `ProfileTabView` (inside `PatientHomeView`).
- *Have:* metric tiles (status/risk/streak/best), timezone/onboarding/last-checkin rows, sign-out.
- *Gap:* gold standard = avatar + name + org, **privacy FeatureCard** ("we never sell or advertise…", "see who's viewed your data"), `SettingsRow` list (Notifications, Face ID & app lock, Apple Health, Care team & sharing, Export), Replay onboarding, **in-app account deletion** (App Store 5.1.1), version footer.
- *Work:* rebuild as `FeatureProfile`; **relocate consent + notification controls here from `CareView`**; add data-export + account-deletion + access-log surfaces.

**6.12 Pre-visit prep** → **no screen / no API.**
- *Gap/Work:* net-new `FeaturePreVisit` cover (entry from a Today card) — appointment header, auto-summary stat cards (Mood/Sleep/PHQ-9 + "worth flagging" clay card from `/insights/me` + assessments + correlation cache), **editable agenda** (include/exclude checkboxes), share-to-care-team footer. Implements masterplan doc-04 W1 #3.

---

## 3. API / data-layer mapping

The generated `COPEOpenAPI` client (satisfying prompt §9 codegen) already exposes and the app **wires**:

✅ `auth/login`, `auth/register`, `auth/mfa/verify`, refresh · `patients/me` (GET) · `patients/me/intake` (PATCH) · `patients/me/{symptoms,triggers,strategies}` (POST) · `catalogues/{symptoms,triggers,strategies}` · `medications` (POST create) · `daily-entries/today` (GET), `daily-entries` (POST), `:id/submit` (PATCH) · `assessments/pending` (GET), `assessments` (POST) · `consent` (GET/POST) · `safety/resources`, `safety/my-plan` (GET), `my-plan/sign` (POST) · `notifications/prefs` (GET/PUT), push-token.

❌ **Not wired (needed by gold-standard screens):**
- `messages` REST + WS `message.created` — **additive, backend not built** (6.6)
- `insights/me`, `/risk-scores`, `/ai` (6.7)
- `medications/today`, `medications/:id/logs` (6.9)
- `journal` GET/POST/PATCH, `/journal/:id/share` (6.10)
- `voice/transcribe` (multipart — do not force JSON) (6.4, 6.10)
- `assessments/:scale/responses`, `assessments/:id/fhir` (6.8)
- `health-data/sync`, `health-data/me` (HealthKit, §12)
- `sync/pull` + `sync/push` (full WatermelonDB-shaped engine, §10) — only a bespoke daily-entry outbox exists today
- OIDC redirect/exchange (6.2)

**Daily-entry model gap:** current iOS draft serializes 6 fields; the server entry has 21 clinical-domain columns. The check-in additions (feelings, body map, energy, anhedonia, mania, triggers) require extending the iOS draft + request mapping (additively).

---

## 4. Cross-cutting capability gaps

| Area | Current | Gold standard (§) | Gap | Effort |
|---|---|---|---|---|
| **C1 Offline/sync** | File-based `EncryptedLocalFileStore` + bespoke daily-entry `LocalOutboxStore` w/ flush | §10: GRDB+SQLCipher single source of truth; full `sync/pull`+`push` (WatermelonDB-shaped); merge UI for co-edited text | Replace file store with GRDB+SQLCipher `Persistence` pkg; generalize outbox to the wire protocol | **L** |
| **C2 Notifications** | `NotificationRegistrationService` (push-token register) + prefs | §11: local `UNCalendarNotificationTrigger` reminders (check-in/meds), `.timeSensitive`/`.critical`, PHI-free NSE | Add local reminder scheduling (onboarding/profile) + NSE | **M** |
| **C3 Security** | `KeychainTokenStore`, `LocalPatientDataWiper`, entitlements file | §8: biometric-bound keychain crypto op, blur-on-resign, auto-logoff 2–5m, ATS + SPKI pinning, jailbreak gate | Add unlock binding, blur overlay, inactivity timer, cert pinning | **M** |
| **C4 HealthKit** | None | §12: read sleep/steps/HRV/etc., write `HKStateOfMind`, background delivery | Net-new `HealthKit` integration → `health-data/sync` | **L** |
| **C5 Charts** | None | §6.7: Swift Charts | Add Swift Charts (Insights, stat cards) | **S** |
| **C6 A11y** | Per-control labels sparse; system Dynamic Type only | §15: full labels/hints/traits, Dynamic Type to largest (no Fraunces truncation), reduce-motion, consistent 988 placement | A11y pass across all screens | **M** |

---

## 5. Recommended sequencing (reconciles prompt §14 with what exists)

1. **Foundations (F1–F4):** `DesignSystem` package — tokens (two themes), Fraunces/Figtree, all §4 components incl. gradient sliders + `MoodDial`. *Unblocks everything.*
2. **`CopeCore` (F5):** models + validated scoring + golden tests.
3. **Navigation shell (F3):** `MainTabView` (5 tabs + raised FAB), `AppState`, cover routing. Reskin **Auth** + add biometric unlock.
4. **Check-in hero (6.4):** the 10-step flow on top of the *existing* draft/outbox logic; build the shared **safety handoff (§7)** here. *Highest product value.*
5. **Today (6.3):** rebuild as dashboard once the check-in has moved out.
6. **Safety (6.5):** promote to its own cached, globally-reachable screen.
7. **Assessments (6.8):** warm flow + real wording + item-9 handoff + generic engine.
8. **Medications (6.9)** + local reminders (C2); **Journal (6.10)** + voice/FTS.
9. **Insights (6.7)** + Swift Charts (C5) + HealthKit (C4).
10. **Care / messaging (6.6):** after backend `messages` + WS land; build `Networking` WS actor + thread UI + escalation trust state. Move consent/notif controls out of today's `CareView` into **You**.
11. **You/Profile (6.11):** privacy card, settings, export, **account deletion**; **Pre-visit (6.12)**.
12. **Onboarding (6.1)** front-to-back; then **a11y + security hardening (C3/C6)** + full **sync engine (C1)** + store metadata.

---

## 6. Guardrail callouts (must hold throughout)

- **988/Safety is never a dead end and is placed consistently** (§7, WCAG 3.2.6). The escalation surface is built **once** in `CopeCore`/`FeatureSafety` and reused by check-in C-SSRS, assessment item-9, and crisis language.
- **No PHI in any notification payload/banner** (§1, §11) — neutral copy only.
- **AI is consent + BAA gated**, labeled "not a diagnosis"; no standalone AI therapist (§1, 6.7).
- **No guilt mechanics** — gentle streaks with freeze/grace; progress framing (§1).
- **Provisional `ALERT_THRESHOLDS`** centralized in `CopeCore`, pending clinician sign-off (OQ-004, §13).
- **Auth rules** (`.claude/rules/auth-system.md`) are untouched by this client work — additions only; never weaken the bcrypt/MFA/refresh paths.

---

*This document is the bridge between the gold-standard spec triad and the current scaffold. It does not change code. Recommended next step after review: execute item 1 (the `DesignSystem` foundation), since every screen depends on it.*
