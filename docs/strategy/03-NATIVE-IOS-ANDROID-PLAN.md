# COPE — Native iOS (Swift) & Android (Kotlin) Implementation Plan

**Document 3 of 5 · Strategy Series**
**Date:** 2026-06-27 · **Author:** Mobile architecture plan

> A complete plan to replace the Expo/React-Native patient app with **fully native iOS (Swift/SwiftUI)
> and Android (Kotlin/Jetpack Compose)** apps, plus a companion **clinician** native experience. The
> backend (`apps/api`) and `@cope/shared` contract stay; only the patient (and new clinician-mobile)
> client tier is rebuilt natively. Architecture/security/release sections (Parts 4–8) draw on the
> research in doc `02` Part C.

---

## Part 1 — Why Native, and Scope

### 1.1 Rationale
The current Expo app is ~65% complete and functional, but the user's goal is native apps that can
*supersede competitors*. Native is justified here by concrete, COPE-specific needs:

| Driver | Why RN/Expo is limiting | Native advantage |
|---|---|---|
| **Deep health-platform integration** | `react-native-health` / `react-native-health-connect` lag native APIs and background delivery | First-class **HealthKit** (`HKObserverQuery`, background delivery, sleep stages, HRV, mobility/gait) & **Health Connect** (incl. *Mental Wellbeing* records) |
| **On-device privacy/ML (digital phenotyping)** | passive sensing + on-device inference are awkward in RN | Native sensors, Core ML / on-device models, background tasks done right |
| **Crisis-grade reliability & UX** | bridge jank, cold-start latency, notification edge cases | Native time-sensitive/critical notifications, instant safety-plan access, smooth low-cognitive-load UX |
| **Widgets / watch / Live Activities** | limited/none in Expo managed | WidgetKit + watchOS complications + Android widgets + Wear OS for one-tap mood logging |
| **Security posture for SaMD/HIPAA** | encrypted local store, jailbreak/root detection, cert pinning are add-ons | Keychain/Keystore, biometric, attestation, encrypted DB are native-first |
| **App Store/Play medical-app trust** | acceptable, but native signals quality | Best-in-class accessibility, performance, store review outcomes |

### 1.2 Scope of the native program
1. **Patient app — iOS (Swift) + Android (Kotlin):** full parity with today's Expo app + the unfinished
   features + new differentiators (see doc `04`).
2. **Clinician companion — iOS + Android (Phase 2):** read-first triage + secure messaging + alert
   triage + safety-plan review. (The full clinician console remains the web app, made responsive in doc `04`.)
3. **Shared backend & contract unchanged:** native apps consume the existing `/api/v1/*` REST + WS and
   the `@cope/shared` semantics (mood colors, thresholds, crisis contacts, LOINC map, WS events).

**Non-goals (v1 native):** no re-platforming the web console to native; no new backend auth model
(reuse bcrypt + rotating refresh + MFA + OIDC exactly as-is — it is protected per project rules).

---

## Part 2 — Feature-Parity Matrix (native must reach/exceed this)

Legend: ✅ exists in Expo today · 🟡 partial in Expo · 🆕 backend-supported but not in mobile client ·
➕ new in native (doc `04`).

| Domain | Capability | Expo today | Native target |
|---|---|---|---|
| **Auth** | bcrypt login, MFA (TOTP), invite registration, OIDC SSO, forced password change | ✅ | ✅ + passkeys/WebAuthn (➕), biometric unlock |
| **Onboarding** | consent wizard | ✅ | ✅ |
| | clinical **intake wizard** | 🟡 (stub) | ✅ complete |
| **Daily check-in** | 9-step multi-domain (mood/mania/anxiety/anhedonia/SI/substance/social/cognitive/appetite/stress/sleep/exercise/life-events) | ✅ | ✅ + adaptive (skip mania for unipolar), split AM/PM, low-cognitive-load |
| **Safety** | C-SSRS branch + safety modal + crisis resources | ✅ | ✅ + one-tap **safety plan** surface, 988 call/text/chat, means-restriction |
| | crisis **safety plan** (Stanley-Brown) view/sign | 🆕 (`/safety/my-plan`) | ✅ patient-facing plan |
| **Assessments** | PHQ-9, GAD-7, ASRM, ISI, C-SSRS questionnaires | ✅ | ✅ + WHODAS, QIDS-SR (backend ready) |
| | "pending/due" surfacing | 🟡 | ✅ scheduled + reminders |
| **Medications** | list, adherence toggle, add med, history | ✅ | ✅ + **local reminders** firing, side-effect capture |
| **Journal** | list, create, voice capture, share-with-care-team | ✅ | ✅ + **detail/edit view** (stub today), rich text, prompts, search |
| **Insights** | server stats summary | 🟡 (text only) | ✅ **trend charts** (Swift Charts / Compose charts), correlations |
| | AI insights (BAA-gated) | 🟡 | ✅ augmentation-only, consent-gated |
| **Passive health** | steps/HR/HRV/sleep ingest → `/health-data/sync` | ✅ | ✅ + sleep stages, mobility, mindful minutes, background delivery |
| **Offline** | WatermelonDB pull/push | ✅ (foreground only) | ✅ encrypted local DB + **background sync** + conflict UI |
| **Notifications** | push registration | ✅ | ✅ + local check-in/med reminders, time-sensitive/critical for crisis |
| **Comms** | journal share, assessment requests (inbound) | ✅ | ✅ + **secure 2-way messaging** (➕, doc `04`) |
| **Quick-log** | — | — | ➕ **widgets / watch / Live Activities** for 1-tap mood |
| **Security** | biometric lock, SecureStore | ✅ | ✅ + encrypted DB, cert pinning, jailbreak/root detection |
| **A11y** | labels present | 🟡 | ✅ VoiceOver/TalkBack, Dynamic Type, WCAG, trauma-informed |

---

## Part 3 — Backend Contract the Native Apps Consume (no backend changes required for parity)

The native apps target the existing API. Key surfaces:

- **Auth:** `POST /auth/login` → (optional `mfa_pending`) → `POST /auth/mfa/verify`; `POST /auth/refresh`
  (rotating, reuse-detected); `POST /auth/change-password`; OIDC via `GET /auth/oidc/redirect` +
  `POST /auth/oidc/exchange`. Tokens: 15-min access, 7-day refresh.
- **Daily entries:** `GET /daily-entries/today`, `POST /daily-entries`, `PATCH /daily-entries/:id/submit`.
- **Assessments:** `POST /assessments`, `GET /assessments/pending`, `GET /assessments/:id/fhir`.
- **Medications:** `GET /medications/today`, `POST /medications`, `POST /medications/:id/logs`.
- **Journal:** `POST /journal`, `GET /journal`, `PATCH /journal/:id`, `PATCH /journal/:id/share`.
- **Safety:** `GET /safety/resources`, `GET /safety/my-plan`, `POST /safety/my-plan/sign`.
- **Insights:** `GET /insights/me?days=30`, `GET /insights/me/ai…` (gated), `GET /insights/me/risk-scores`.
- **Passive health:** `POST /health-data/sync` (batch upsert), `GET /health-data/me`.
- **Catalogues/consent/notifications/voice:** `GET /catalogues/{triggers,symptoms,strategies}`,
  `GET|POST /consent`, `GET|PUT /notifications/prefs`, `POST /voice/transcribe`.
- **Offline sync:** `GET /sync/pull?last_pulled_at=…&schema_version=…` and `POST /sync/push` —
  **patient-only**, WatermelonDB-style changesets over `daily_entries`, `journal_entries`, and the
  `daily_entry_{triggers,symptoms,strategies}` join tables (server returns `server_id` + `updated_at`).

> **Contract requirement for native:** the sync protocol is WatermelonDB-shaped today (created/updated/
> deleted arrays keyed by table, `last_pulled_at` unix-ms). Native clients will implement the **same
> wire protocol** against their own local stores (GRDB/Room) so the backend `/sync` endpoints need **no
> changes**. Where native adds new offline entities (e.g., messages), extend the changeset object
> additively (backend rule #12: additions only).

### 3.1 Recommended additive backend touch-points (small, optional)
These are *not* required for parity but unlock native differentiators (detailed in doc `04`):
- `messages` resource + `/messages` endpoints + WS `message.created` event (secure 2-way comms).
- `schema_version` bump path in `/sync` for new offline tables.
- Per-device push token model already exists (`patient_notification_preferences.push_token`) — extend to
  allow **APNs + FCM token types** and multiple devices.

---

## Part 4 — Architecture (the recommended shape)

### 4.1 Headline decision: KMP shared core + fully native UIs
Adopt **Kotlin Multiplatform (KMP) for a shared `commonMain` core** behind **fully native SwiftUI (iOS)
and Jetpack Compose (Android) UIs.** Skip Compose Multiplatform for v1 (not yet native-feeling on iOS;
weak XCTest evidence trail for a regulated app).

**Why (COPE-specific):** the one thing that *must not* diverge between platforms is **clinical assessment
scoring** (PHQ-9/GAD-7/ISI/C-SSRS/ASRM/WHODAS) and the `ALERT_THRESHOLDS`/validation rules — divergence
is a **patient-safety defect**. KMP lets us write + unit-test that once. Native UIs keep platform-idiomatic
UX, accessibility, and deep OS integration (HealthKit/Health Connect, biometrics, notifications, widgets).

**Share in `commonMain`:** assessment scoring + interpretation, validation rules (Zod-equivalent, `LIMITS`,
`ALERT_THRESHOLDS`), networking (Ktor REST + WS against the Fastify API), the offline DB + sync engine
(SQLDelight), and the crisis safety-plan model + 988/741741 constants.
**Keep native:** all UI, HealthKit/Health Connect, biometrics/Keychain/Keystore, notifications, widgets/watch.

**The "three type definitions" problem:** TS (`@cope/shared`), Swift, Kotlin. KMP collapses iOS+Android to
one Kotlin source (3→2); close the gap to TS with **OpenAPI Generator** off the Fastify JSON-Schema spec to
emit TS+Swift+Kotlin **DTOs in CI**. (Codegen syncs *shapes*; KMP shares *behavior*.) *If the team has zero
Kotlin appetite, fall back to fully-native + OpenAPI codegen — accepting a third hand-maintained scoring
implementation that must be cross-tested.*

### 4.2 iOS module/architecture
- **SwiftUI-first**, **MVVM-lite with `@Observable`** (`@MainActor @Observable` models for screens with real
  logic: assessment scoring, sync status, safety plan); bind directly for trivial screens. **TCA** only for
  the multi-step check-in/assessment + safety-plan state machines if exhaustive testability is wanted.
- **Swift 6.2 strict concurrency + Approachable Concurrency** (default `@MainActor` isolation on; `actor`
  for the sync/DB boundary). **URLSession** async/await client with an `actor`-isolated token-refresh
  interceptor matching COPE's rotating refresh tokens. **`URLSessionWebSocketTask`** in an `actor` exposing
  `AsyncStream` (build heartbeat + backoff + re-auth/resubscribe).
- **Local SPM packages:** `CopeCore`/`Models` (mirror `@cope/shared`), `DesignSystem`, `Persistence`,
  `Networking`, `Feature{CheckIns,Journal,Assessments,SafetyPlan,Meds,Insights,Messaging,CareTeam}`; thin app
  target as composition root. DI via **Factory** (or swift-dependencies if SQLiteData adopted).

### 4.3 Android module/architecture
- **Jetpack Compose + Material 3** (BOM 2025.12+), **Google layered + UDF**, `ViewModel` + single `uiState`
  **StateFlow** (`stateIn(..., WhileSubscribed(5000), Loading)`), `collectAsStateWithLifecycle()`. Scoring +
  thresholds live in **domain-layer use cases**.
- **Coroutines + Flow**; **Hilt + KSP** DI; **Retrofit + OkHttp + kotlinx.serialization**; **OkHttp
  WebSocket** in a `callbackFlow` with backoff; **Navigation 3** (stable).
- **Now-in-Android modularization:** `:app` + `:feature:*` + `:core:{data,database,network,datastore,
  designsystem,model,domain,security}`; isolate PHI-touching `:core:security`/`:core:database`.

### 4.4 KMP core stack
Kotlin 2.x · **Ktor ~3.5** (REST+WS) · **SQLDelight ~2.3** · kotlinx-serialization/coroutines/datetime ·
multiplatform-settings · **Koin** (core DI) · **SKIE (required)** to turn Kotlin sealed classes → exhaustive
Swift enums, `suspend` → Swift `async`, `Flow` → `AsyncSequence`.

---

## Part 5 — Data & Offline Sync

### 5.1 Local persistence
- **iOS:** **GRDB.swift** (FTS5 full-text journal search; mature, fast) via **SQLiteData** wrapper —
  **not SwiftData** (no FTS, CloudKit-only sync, migration regressions).
- **Android:** **Room 2.8 + KSP**, DAOs `suspend`/`Flow`-only (ready for the Room 3.0 KMP rewrite).
- **KMP option:** **SQLDelight** as the shared store so the sync engine itself is shared `commonMain`.

### 5.2 Sync engine — reuse COPE's existing protocol, harden it
The backend `/sync/pull` + `/sync/push` already speak a WatermelonDB-shaped changeset (created/updated/
deleted per table, `last_pulled_at` unix-ms, `server_id`+`updated_at`). The native engine implements the
**same wire protocol** → **no backend change for parity**.
- **Pattern:** local DB is the **single source of truth**; **lazy writes** (write local, enqueue sync) so
  nothing is lost offline; a WebSocket invalidation channel triggers pulls; an **outbox** queues pushes.
- **Conflict resolution:** **field-level last-write-wins using server-authoritative timestamps** for
  single-author records (check-ins, assessments, meds). For **co-edited free text** (shared safety plan;
  journal edited offline on two devices) use an **explicit merge UI or CRDT** — *never silently drop PHI.*
- **Clinical-record discipline (SaMD):** make assessments/journal entries **append-only / versioned**
  (`created_at`/`updated_at`/`server_version`), never overwrite — preserves the audit trail.
- **Optional accelerator:** **evaluate PowerSync** (bi-directional Postgres↔SQLite, Swift + Kotlin SDKs,
  Sync Rules mapping onto COPE's RLS / `app.current_user_id`; *verify its Jan-2026 HIPAA/SOC 2 status*).
  If adopted it can replace the hand-rolled outbox; otherwise keep the protocol above.

### 5.3 New offline entities
Messaging (W1 of doc `04`) adds a `messages` table to the changeset — bump `schema_version` and extend the
changeset object **additively** (backend rule: additions only).

---

## Part 6 — Security on Device (HIPAA / OWASP MASVS L2+R)

| Control | iOS | Android |
|---|---|---|
| Secrets/tokens | **Keychain** `…WhenUnlockedThisDeviceOnly` + `.biometryCurrentSet`; wrap with **Secure Enclave** | **Keystore** (TEE/**StrongBox**) + **key attestation** (server-verified) |
| Biometric unlock | LocalAuthentication **bound to a Keychain/Enclave crypto op** (not `evaluatePolicy` alone) | **BiometricPrompt + `CryptoObject`**, `BIOMETRIC_STRONG`, `setInvalidatedByBiometricEnrollment(true)` |
| DB at rest | **SQLCipher (GRDBCipher)** AES-256 + **`NSFileProtectionComplete`**; key in Keychain/Enclave | **SQLCipher** (`sqlcipher-android` 4.6+ `SupportOpenHelperFactory`) + key in Keystore. ⚠️ Jetpack Security **deprecated** |
| Field encryption | **CryptoKit** AES.GCM | **Google Tink** (`Aead`/`StreamingAead`) |
| Transport | **ATS on** + SPKI pinning (`URLSessionDelegate`/TrustKit, ≥1 backup pin) | **Network Security Config `<pin-set>`** + OkHttp `CertificatePinner`, `cleartextTrafficPermitted=false` |
| Integrity/tamper | best-effort jailbreak detection (MASVS-RESILIENCE) | **Play Integrity** (server-verified); gate sensitive actions, not launch |
| Screen privacy | blur overlay on `resignActive` (app-switcher) | **`FLAG_SECURE`** on every PHI window |
| Session | **auto-logoff ~2–5 min** inactivity → clear in-memory PHI, re-auth (biometric); reuse COPE's 5-min biometric pattern |
| Hygiene | **no PHI in logs/crash/analytics**; **no hardcoded secrets** (proxy 3rd-party keys via backend); MobSF/secret-scan in CI |

This directly advances doc `04` W5 (Trust & Privacy) and the SaMD/HIPAA posture (doc `01` §4, the Dec-2024
HIPAA NPRM expectations in doc `02` B4).

---

## Part 7 — Health-Platform Integration & Notifications

### 7.1 HealthKit (iOS)
- **State of Mind** (`HKStateOfMind`: valence −1…+1, emotion labels, life-context associations) — a native
  mood signal COPE can both read and *write* (mirror in-app mood logs to Health).
- **Native PHQ-9 & GAD-7 types** (licensed from Pfizer) — read/write COPE's assessments to HealthKit.
- Passive: `sleepAnalysis` (stages), `stepCount`/`appleExerciseTime`, `mindfulSession`, `heartRate`/
  `restingHeartRate`, **HRV `heartRateVariabilitySDNN`**, mobility. Background: `HKObserverQuery` +
  `enableBackgroundDelivery` + `HKAnchoredObjectQuery`. Permissions per-type/direction; **cannot detect
  denied read** → design for empty results. Sync derived snapshots to `POST /health-data/sync` (exists).

### 7.2 Health Connect (Android)
- Stable `connect-client` **1.1** (Nov 2025): `SleepSessionRecord`, steps/exercise, `HeartRateRecord`/
  `RestingHeartRateRecord`, **`HeartRateVariabilityRmssdRecord`** (RMSSD — note iOS uses SDNN), and the new
  **`MindfulnessSessionRecord`**. **No mood/valence equivalent → COPE owns the mood schema on Android.**
  Granular permissions + `READ_HEALTH_DATA_IN_BACKGROUND`/`READ_HEALTH_DATA_HISTORY`; mandatory Play health
  declaration ("Mental and behavioral health").

### 7.3 Passive sensing / digital phenotyping (feeds doc `04` W3)
**SensorKit is research/IRB-only** — avoid for commercial. Use **HealthKit + CoreMotion** (+ consented
CoreLocation) on iOS and **Health Connect + Activity Recognition + SensorManager** on Android. **Process
features on-device; transmit derived indicators, not raw traces;** granular, revocable per-signal consent.

### 7.4 Notifications
- **iOS APNs:** `.timeSensitive` for medication/check-in reminders (auto-grantable entitlement);
  **`.critical`** (Apple-reviewed `critical-alerts` entitlement) **reserved for clinically-validated crisis
  events only**; Notification Service Extension composes a **PHI-free** banner.
- **Android FCM HTTP v1:** **data-only** messages → client composes a generic banner; **channels**
  (`crisis_alerts` HIGH, `med_reminders`, `checkin_reminders`, `sync_status` LOW); `POST_NOTIFICATIONS`
  runtime permission; crisis baseline = `IMPORTANCE_HIGH` heads-up (full-screen-intent is opt-in only).
- **Local reminders:** iOS `UNCalendarNotificationTrigger`; Android `AlarmManager.setAlarmClock()` /
  `setExactAndAllowWhileIdle()` (handle `SCHEDULE_EXACT_ALARM` prompt on 14+).
- **Background sync:** iOS `BGTaskScheduler` + background `URLSession` + silent push; Android **WorkManager**
  (expedited work for a just-submitted **C-SSRS** crisis assessment).
- **HIPAA rule:** **never put PHI in any payload/banner** — neutral copy only ("Time to check in," "New
  secure message"); details after in-app auth. Keep PHI out of payloads regardless of vendor BAA status.

### 7.5 Quick-log surfaces (a differentiator — doc `04` W2)
One shared **`LogMood`** path exposed via: **iOS** interactive **WidgetKit** widget (`Button(intent:)`),
**Control Center** control (iOS 18), **Siri `AppShortcutsProvider`** ("Log my mood in COPE"), and a
**watchOS complication** + independent watch app. **Android** **Glance** home-screen widget + **Wear OS
Tile**/complication. One-tap mood logging is the highest-frequency, lowest-friction engagement loop.

---

## Part 8 — Accessibility, Release & Roadmap

### 8.1 Accessibility (WCAG 2.2 AA + trauma-informed)
- iOS: `.accessibilityLabel/Hint/Value/Traits`, **Dynamic Type** to largest sizes, honor
  `accessibilityReduceMotion`; complete **Accessibility Nutrition Labels** (becoming mandatory).
- Android: `Modifier.semantics`, **48dp** targets, `sp` text, WCAG contrast; test TalkBack + Scanner.
- Most relevant criteria for depressed/anxious users: **3.3.8 Accessible Authentication** (allow paste +
  biometric — *must accommodate COPE's forced-password-change modal*), **3.2.6 Consistent Help** (fixed
  988/Crisis-Text-Line placement), **3.3.7 Redundant Entry** (don't re-ask in assessments). UX: low-stimulus
  calm palette (preserve Fraunces/Figtree + teal `#2a9d8f`), one primary action per screen, paged
  assessments, autosave/undo for journals.

### 8.2 Store & compliance
- Apple **1.4.1** (medical accuracy — submit any FDA clearance docs), **5.1.1** (in-app account deletion;
  **submit as a legal entity**), **5.1.3** (no ad/data-mining use of health data). Verify 988/741741 are
  correct in-app (shipped apps have had wrong crisis numbers).
- Google Play: **health declaration**, **Medical Device labeling** (verified label if cleared, else "not a
  medical device" disclaimer — relevant to SaMD posture), **organization account** (migrate by ~Jan 28,
  2026), in-app + web account deletion, Data Safety form (health data, App-functionality only, no ad
  sharing, encrypted in transit).

### 8.3 CI/CD
iOS: **Xcode Cloud** primary (managed signing/notarization, TestFlight) + thin **Fastlane** for
screenshots/metadata/privacy-label sync (note: `fastlane match` cert *creation* degraded since May 2025;
still syncs existing). Android: **Fastlane `supply`** or **Gradle Play Publisher**, **Play App Signing**,
staged rollout (internal→closed→open→prod). **Generate SLSA provenance / SBOM per build** for SaMD
auditability. Keep KMP `commonTest` scoring tests in the gate.

### 8.4 Native build roadmap (parallelizable with backend workstreams in doc `04`)

| Phase | Focus | Exit criteria |
|---|---|---|
| **P0 — Foundations (3–4 wk)** | KMP core skeleton, OpenAPI DTO codegen, design system, modules, CI (Xcode Cloud + Play), SKIE | Build pipelines green; shared scoring lib unit-tested in `commonTest` |
| **P1 — Auth & shell (3–4 wk)** | Login + MFA + OIDC + forced password change, Keychain/Keystore, biometric unlock, secure session/auto-logoff | Parity with Expo auth; MASVS storage/auth checks pass |
| **P2 — Daily check-in (4–6 wk)** | Full multi-domain check-in (adaptive: skip mania for unipolar), C-SSRS branch + safety modal, offline writes | Check-in parity; offline create/submit works |
| **P3 — Offline + sync (3–4 wk)** | GRDB/Room + SQLCipher, sync engine on `/sync`, background sync, conflict UI | Multi-device sync correct; encrypted-at-rest verified |
| **P4 — Assessments, meds, journal (4–6 wk)** | All scales, med adherence + **local reminders**, journal **detail/edit** + voice + prompts + FTS search | Feature parity + finished gaps from Expo |
| **P5 — Insights, health, safety plan (3–4 wk)** | Trend charts (Swift Charts/Compose), HealthKit/Health Connect ingest, patient safety-plan view/sign | Charts shipped; passive data flowing; safety plan accessible |
| **P6 — Differentiators (4–6 wk)** | Quick-log widgets/watch, secure **messaging** UI (W1), engagement mechanics (W2), notifications hardening | Widgets live; messaging usable; time-sensitive/critical notifications working |
| **P7 — A11y, store, launch (3–4 wk)** | WCAG 2.2 AA audit, nutrition/Data-Safety labels, store review, staged rollout | Both apps approved; pilot-ready |
| **P8 — Clinician companion (later)** | Read-first triage + alert/messaging + safety-plan review | Clinician mobile parity for triage |

> Total ≈ **7–9 months** to a pilot-ready patient app on both platforms with a small team, overlapping the
> backend workstreams in doc `04`. The clinician companion (P8) follows.

### 8.5 Verify before committing (carried from research)
SQLiteData version (Swift Package Index); PowerSync Cloud HIPAA date; FCM Google Cloud BAA coverage; Play
org-account migration deadline; current Compose BOM/library versions; LOINC for ISI/ASRM/WHODAS.

