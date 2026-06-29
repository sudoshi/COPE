# COPE Native Mobile Split - Todo and Implementation Plan

**Date:** 2026-06-29

**Status:** Native split foundation merged into draft PR; iOS auth, clinical workflow, consent, safety, and notification plumbing slices in progress

**Scope:** Replace the current Expo/React Native patient app with native Android and iOS apps.

**Target clients:** Android Kotlin/Jetpack Compose and iOS Swift/SwiftUI.

**Primary source review:** `apps/mobile`, `apps/api`, `packages/shared`, `packages/db`, and `docs/strategy`.

**Checklist key:** `[ ]` not started, `[~]` in progress, `[x]` complete.

## 1. Executive Decision

COPE should split the patient mobile client into two native apps:

- Android: Kotlin, Jetpack Compose, Hilt, WorkManager, Room or SQLDelight, SQLCipher, Health Connect, Firebase Cloud Messaging.
- iOS: Swift, SwiftUI, async/await, BackgroundTasks, GRDB or Core Data, SQLCipher where needed, HealthKit, APNs.

The React Native app should become a behavioral reference and parity harness, not the long-term production client.

The recommended implementation is native UI on both platforms with a shared clinical and sync core where practical:

- Preferred: Kotlin Multiplatform core for API DTOs, validation, scoring, sync merge rules, feature flags, and golden clinical tests.
- Acceptable alternative: no shared runtime, but strict OpenAPI-generated clients plus language-neutral fixture tests for every clinical rule.

The app should not be ported screen by screen without first stabilizing the API contract, local data model, safety workflow, and privacy/security boundaries.

## 2. Current State Summary

The existing mobile app already includes real patient-facing features:

- Auth, MFA, invite onboarding, consent, and intake.
- Today/check-in workflow with expanded clinical domains.
- Medication list and adherence toggles.
- Journal list/detail and voice transcription entry point.
- Insights, assessments, profile, settings, biometrics, notifications, passive health integration, and WatermelonDB sync.
- Maestro flows and a small amount of unit/accessibility test coverage.

The current mobile app is still not native-production ready:

- Core check-in submission is not truly offline-first.
- WatermelonDB schema is behind the backend clinical model.
- Consent DTOs and type names drift from the backend contract.
- Voice upload is blocked by JSON-only request headers.
- The API lacks an executable OpenAPI contract for generated Swift/Kotlin clients.
- Secure messaging/care-team communication is not implemented as a product surface.
- Local database encryption, notification payload policy, multi-device push token handling, and full native health background behavior need to be designed explicitly.

## 3. Non-Goals

- Do not continue adding major features to the Expo app except temporary parity fixes and safety-critical bug fixes.
- Do not ship a native client that depends on undocumented API behavior.
- Do not create independent clinical scoring logic in Kotlin and Swift without shared golden tests.
- Do not put PHI in push notification payloads.
- Do not treat Zephyrus/Parthenon strategy documents as direct COPE mobile scope. Reuse only governance and event-intelligence patterns.

## 4. Architecture Targets

### 4.1 Repository Layout

Preferred layout:

```text
apps/
  android/                  Native Android app
  ios/                      Native iOS app
  mobile/                   Existing Expo app, reference only during migration
packages/
  mobile-contracts/         Generated OpenAPI clients and fixtures, if kept language-neutral
  mobile-core/              Kotlin Multiplatform core, if adopted
  shared/                   Existing TypeScript schemas and constants
  db/                       Server migrations and DB utilities
docs/
  strategy/
    05-NATIVE-SPLIT-TODO-IMPLEMENTATION-PLAN.md
```

If Kotlin Multiplatform is adopted, `packages/mobile-core` should own only platform-neutral behavior:

- API DTOs and response envelopes.
- Auth state machine, excluding platform keychain implementation.
- Clinical scoring and risk threshold helpers.
- Offline sync operation types and merge decisions.
- Validation rules.
- Date/time normalization.
- Feature flag and consent-state evaluation.

Platform-specific code stays platform-specific:

- UI and navigation.
- Secure storage implementation.
- Database encryption and file protection.
- HealthKit and Health Connect adapters.
- APNs and FCM registration.
- Background scheduling.
- Biometric prompts.

### 4.2 Contract Strategy

The native split requires a real mobile API contract before large UI implementation.

Required outputs:

- OpenAPI 3.1 artifact generated from the Fastify API.
- Versioned response envelope definitions.
- Stable error code catalog.
- Consent type enum aligned with database and mobile UI.
- Assessment scale catalog and scoring metadata.
- Sync payload schemas for local-first mobile writes.
- PHI-safe push notification schema.

The current API uses Zod parsing inside route handlers, but route schemas are not registered in a way that supports full OpenAPI generation. The first backend slice must create an OpenAPI pipeline and incrementally annotate mobile-critical routes.

### 4.3 Local Data Strategy

Native apps must be local-first for patient workflows.

Local tables/entities:

- Auth session metadata, excluding raw refresh tokens if platform secure storage can own them.
- Patient profile and onboarding state.
- Consent records.
- Daily entries with all expanded clinical domain fields.
- Sleep, exercise, triggers, symptoms, and wellness strategy logs.
- Journal entries and attachments/transcription metadata.
- Medications and adherence logs.
- Assessment assignments, answers, scores, and submit state.
- Health summaries and sync cursors.
- Safety plan, crisis resources, and local safety event queue.
- Notification preferences and scheduled reminder metadata.
- Sync outbox, sync cursors, conflict records, and tombstones.

Security requirements:

- Encrypted at rest.
- Platform keychain/keystore for tokens and encryption keys.
- Explicit data wipe on logout.
- Screen-level privacy for sensitive views where platform support exists.
- No diagnostic logs containing PHI.

## 5. Implementation Phases

### Phase 0 - Stabilize Contracts and Source of Truth

Goal: make native development possible without guessing.

Checklist:

- [x] Decide whether Kotlin Multiplatform core is accepted or whether the apps must be fully independent.
  - Initial implementation track: independent Kotlin/Swift clients backed by the generated OpenAPI contract. KMP remains a future option for clinical fixtures or scoring helpers if duplication becomes risky.
- [x] Register Fastify Swagger/OpenAPI support.
- [x] Add a command that exports an OpenAPI JSON artifact.
- [~] Add schema metadata for mobile-critical routes first:
  - [x] `POST /auth/login`
  - [x] `POST /auth/register`
  - [x] `POST /auth/mfa/verify`
  - [x] `POST /auth/refresh`
  - [x] `GET /patients/me`
  - [x] `PATCH /patients/me`
  - [x] `PATCH /patients/me/intake`
  - [x] `GET /daily-entries/today`
  - [x] `POST /daily-entries`
  - [x] `PATCH /daily-entries/:id/submit`
  - [x] `GET /journal`
  - [x] `POST /journal`
  - [x] `GET /medications/today`
  - [x] `GET /medications/:id/logs`
  - [x] `POST /medications`
  - [x] `POST /medications/:id/logs`
  - [x] `GET /assessments/pending`
  - [x] `POST /assessments`
  - [x] `POST /assessments/:scale/responses` compatibility alias
  - [x] `GET /sync/pull`
  - [x] `POST /sync/push`
  - [x] `GET /safety/resources`
  - [x] `GET /safety/my-plan`
  - [x] `GET /notifications/prefs`
  - [x] `PUT /notifications/prefs`
  - [x] `POST /notifications/push-token` dedicated token registration endpoint
    - Current implementation replaces the single stored patient token; a true multi-device token table remains a later migration.
- [~] Normalize consent types across API, database, mobile UI, docs, and native contract.
- [~] Normalize LOINC/FHIR/OMOP use:
  - [x] Distinguish questionnaire panel codes from total-score observation codes.
  - [x] Update shared constants, FHIR mapping, OMOP mapping, and seed/enrichment data to match the chosen mapping.
  - [x] Add tests around mapper output.
  - [ ] Verify remaining unpinned ISI/ASRM/WHODAS/QIDS-SR LOINC choices against an authoritative terminology source before pilot release.
- [x] Define push payload policy with no PHI in notification bodies or data payloads.
- [x] Extend sync schemas for expanded daily-entry clinical domains.
- [~] Define native database schema and migration policy.
  - [x] Align current mobile reference schema and WatermelonDB migration with backend expanded daily-entry fields.
  - [ ] Choose Android persistence stack and migration mechanism.
  - [ ] Choose iOS persistence stack and migration mechanism.
- [x] Confirm live database migration state against expected migration files.
- [x] Confirm production/staging API base URLs and bundle identifiers.
  - Inherited from the Expo app: `com.cope.app`, production `https://app.cope.health`, staging `https://staging.cope.health`, local development `http://localhost:3000` or Android emulator `http://10.0.2.2:3000`.

Exit criteria:

- Native engineers can generate clients or DTOs from a checked-in artifact.
- Every mobile-critical route has documented request, response, and error shapes.
- Consent, assessment, safety, and sync semantics are no longer inferred from UI code.

### Phase 1 - Native Foundations

Goal: bootable native shells with auth/session infrastructure and shared design primitives.

Android checklist:

- [x] Create `apps/android`.
- [~] Configure Gradle, Kotlin, Compose, detekt or ktlint, unit tests, and instrumented tests.
  - [x] Add buildable Gradle/AGP/Kotlin/Compose application scaffold.
  - [x] Verify `npm run native:android:assemble`.
  - [ ] Add ktlint or detekt.
  - [ ] Add unit and instrumented test scaffolds.
- [x] Add build variants for development, staging, and production.
- [ ] Add secure token storage through Android Keystore.
- [ ] Add encrypted local database foundation.
- [~] Add API client generated from OpenAPI or backed by KMP.
  - [x] Add native health-check smoke client.
  - [x] Add OpenAPI generator workspace/config for Kotlin.
  - [ ] Wire generated Kotlin client into the Android app module.
- [ ] Add navigation shell for onboarding, tabs, modal flows, and deep links.
- [x] Add design tokens from existing COPE visual system.
- [ ] Add basic accessibility lint and screenshot test path.

iOS checklist:

- [x] Create `apps/ios`.
- [~] Configure Xcode project, Swift Package Manager, SwiftLint or SwiftFormat, unit tests, and UI tests.
  - [x] Add reproducible XcodeGen project scaffold.
  - [x] Verify `npm run native:ios:build`.
  - [ ] Add SwiftLint or SwiftFormat.
  - [ ] Add unit and UI test scaffolds.
- [x] Add build schemes for development, staging, and production.
  - Apple Team ID `TKXPY255A2` and App Store Connect App ID `6785638840` are recorded in the iOS release config.
- [x] Add Keychain token storage.
- [~] Add encrypted local database foundation.
  - iOS now has a file-protected Today draft store for the first daily-entry cache step.
  - Full encrypted database selection, migrations, outbox tables, and logout wipe remain open.
- [x] Add API client generated from OpenAPI or bridged from KMP.
  - [x] Add native health-check smoke client.
  - [x] Add OpenAPI generator workspace/config for Swift.
  - [x] Generate and build the Swift OpenAPI package.
  - [x] Wire generated Swift client into the iOS app target.
  - [x] Add app-layer wrapper for base URL, bearer headers, refresh retry, and profile decoding.
- [~] Add SwiftUI navigation shell for onboarding, tabs, modal flows, and universal/deep links.
  - [x] Add root authenticated/unauthenticated switch.
  - [x] Add login form wired to native API client.
  - [x] Add first authenticated `/patients/me` profile screen.
  - [x] Add onboarding gate, authenticated tabs, MFA modal flow, and `cope://invite?token=...` deep-link handling.
  - [ ] Add universal link association once production invite domains are finalized.
- [x] Add design tokens from existing COPE visual system.
- [ ] Add accessibility audit and screenshot test path.

Shared checklist:

- [ ] Add clinical fixture directory with JSON test cases.
- [ ] Add scoring fixtures for PHQ-9, GAD-7, ASRM, ISI, C-SSRS, WHODAS, and QIDS-SR.
- [ ] Add safety escalation fixtures for passive SI, frequent SI, plan/intent, and no-risk cases.
- [ ] Add consent-state fixtures.
- [ ] Add sync conflict fixtures.

Exit criteria:

- Both apps compile and boot to a login/onboarding shell.
- Both apps can call a health endpoint against development API.
- Both apps can run the same clinical fixture suite.

### Phase 2 - Auth, Invite, Consent, and Intake

Goal: patient can enter through invite, register, consent, complete intake, and reach Today.

Checklist:

- [x] Implement invite deep link handling.
  - iOS registers the `cope` URL scheme and prefills invite tokens from `cope://invite?token=...`.
- [~] Implement sign-in and MFA.
  - [x] Implement iOS email/password sign-in using generated OpenAPI `POST /auth/login`.
  - [x] Implement iOS MFA verification UI and partial-token continuation.
- [~] Implement invite validation and registration.
  - iOS now supports invite-code registration through `POST /auth/register`; invalid, expired, used, and email-mismatch states are surfaced from backend errors.
  - A separate pre-registration invite validation endpoint is still not present in the mobile contract.
- [x] Implement secure session persistence and refresh.
- [x] Enforce patient-only app role handling.
- [x] Implement required consent screens using backend consent enum.
  - iOS now requires `terms_of_service` and `privacy_policy` acceptance before invite registration, gates existing authenticated sessions missing those records before intake, and keeps authenticated optional consent controls in Care.
- [x] Implement optional consent controls for research, AI insights, journal sharing, emergency contact sharing, and push notifications.
- [~] Implement intake:
  - [x] Primary concern.
  - [x] Emergency contact.
  - [ ] Medication setup.
  - [ ] Symptom preferences.
  - [ ] Trigger preferences.
  - [ ] Reminder preferences.
- [~] Add logout and local wipe.
  - [x] Clear Keychain tokens on logout.
  - [ ] Wipe encrypted local database once native persistence is introduced.
- [ ] Add accessibility coverage for every onboarding and auth screen.

Exit criteria:

- New patient invite to native onboarding works end to end.
- Expired, used, and invalid invite states are handled.
- Consent records are correct in the backend.
- Intake state survives app restart and offline interruption.

### Phase 3 - Offline-First Daily Check-In and Safety

Goal: the primary clinical loop works offline, syncs correctly, and escalates safety signals.

Checklist:

- [~] Implement local daily-entry draft creation.
  - iOS persists same-day Today check-in drafts before attempting network writes and restores them on screen load.
- [~] Implement all expanded clinical domains:
  - [x] Mood.
  - [ ] Coping/wellbeing.
  - [~] Sleep duration and quality.
    - iOS currently captures sleep duration only; sleep quality remains open.
  - [ ] Exercise.
  - [ ] Mania/racing thoughts/decreased sleep need.
  - [~] Anxiety/somatic anxiety.
    - iOS currently captures anxiety score only; somatic anxiety remains open.
  - [ ] Anhedonia.
  - [x] Suicidal ideation.
  - [ ] Substance use.
  - [ ] Social functioning.
  - [ ] Cognitive functioning.
  - [ ] Appetite.
  - [~] Stress and life events.
    - iOS currently captures stress score and notes; structured life-event handling remains open.
  - [ ] Triggers, symptoms, and wellness strategies.
- [ ] Implement local validation before submit.
- [ ] Write local outbox operations before network calls.
- [ ] Submit safety-relevant signals as high-priority sync operations.
- [~] Display crisis resources locally even when offline.
  - iOS reads backend crisis resources and displays them in the Care tab; offline cache remains open.
- [~] Add safety plan read/sign support once backend contract is finalized.
  - iOS reads the authenticated patient safety plan and handles no-plan `404` as an empty state; patient signature/acknowledgement remains open.
- [ ] Add sync status UI that reflects actual outbox state.
- [ ] Add conflict behavior for same-day edits across devices.

Exit criteria:

- Airplane-mode check-in can be completed and queued.
- Reconnect sync creates the same server state as online submission.
- Safety-critical events are prioritized and auditable.
- No check-in data is lost on process death.

### Phase 4 - Journal, Medications, Assessments, and Notifications

Goal: ship the remaining current RN parity features natively with production-grade behavior.

Journal checklist:

- [ ] List journal entries from local cache.
- [ ] Create and edit entries offline.
- [ ] Share/unshare with care team.
- [ ] Add voice transcription path without JSON header conflicts.
- [ ] Add search and tags if API contract supports it.

Medication checklist:

- [ ] Today medication schedule.
- [ ] Adherence toggle with local outbox.
- [ ] Medication add/edit/discontinue.
- [ ] Local reminder scheduling per medication when enabled.
- [ ] Backend push preference alignment.

Assessment checklist:

- [x] Pending assessment list.
- [~] PHQ-9.
  - Generic item capture and score submission are implemented; licensed/approved item text and fixture validation remain open.
- [~] GAD-7.
  - Generic item capture and score submission are implemented; approved item text and fixture validation remain open.
- [~] ASRM.
  - Generic item capture and score submission are implemented; approved item text and fixture validation remain open.
- [ ] ISI.
- [~] C-SSRS.
  - Generic item capture and score submission are implemented; safety handoff remains open.
- [ ] WHODAS.
- [ ] QIDS-SR.
- [ ] Local draft answers.
- [~] Score calculation and backend submission.
  - iOS sums generic item responses and submits through the generated OpenAPI client.
- [ ] Immediate safety handoff for C-SSRS risk responses.

Notification checklist:

- [~] APNs and FCM native token registration.
  - iOS APNs permission, entitlement, device-token callback, and backend token registration are wired.
  - Backend push sending is still Expo-token oriented; APNs/FCM delivery-provider migration and token metadata remain open.
- [ ] Multi-device token model if backend is extended.
- [~] Daily reminder scheduling.
  - iOS can update backend daily reminder preference; local OS scheduling remains open.
- [~] Medication reminder scheduling.
  - iOS can update backend medication reminder preference; local OS scheduling remains open.
- [ ] Assessment request notifications.
- [ ] No-PHI payload enforcement.

Exit criteria:

- Native clients match or exceed RN app parity for these surfaces.
- Assessment scoring matches fixture tests exactly.
- Local reminders continue after app restart and OS permission changes.

### Phase 5 - Insights, Passive Health, and Engagement

Goal: reduce patient burden and provide useful feedback without overclaiming clinical interpretation.

Checklist:

- [ ] Native insights dashboard.
- [ ] Trend charts for mood, sleep, activity, medication adherence, and assessments.
- [ ] Backend AI insights display only when enabled and legally approved.
- [ ] HealthKit opt-in flow.
- [ ] Health Connect opt-in flow.
- [ ] Step count, sleep, HRV, and heart-rate summary ingestion where available.
- [ ] Background sync for passive health summaries.
- [ ] Patient-visible health data permissions and revoke flow.
- [ ] Engagement copy review to avoid shame/streak pressure.
- [ ] Widgets or watch surfaces only after core workflows are stable.

Exit criteria:

- Health data is opt-in, revocable, and auditable.
- Insights are useful but do not imply standalone diagnosis or treatment.
- Background behavior is tested on real devices.

### Phase 6 - Secure Messaging and Care-Team Loop

Goal: close the most important competitive gap identified in the strategy docs.

Checklist:

- [ ] Design secure messaging data model.
- [ ] Add API routes for patient-clinician threads.
- [ ] Add clinician web inbox or patient-detail messaging panel.
- [ ] Add native patient messaging surface.
- [ ] Add notification policy with no message body PHI in push payload.
  - Backend assessment push payload policy is present; native APNs/FCM provider path still needs enforcement tests.
- [ ] Add emergency disclaimers and safety routing for crisis content.
- [ ] Add audit logs and retention policy.
- [ ] Add read receipts only if clinically appropriate.

Exit criteria:

- Patient can contact care team asynchronously.
- Clinician can respond from the web app.
- Crisis content is routed to safety workflows.
- Notifications do not leak PHI.

### Phase 7 - Validation, Compliance, and Release

Goal: prepare the native clients for pilot and app-store distribution.

Checklist:

- [ ] Threat model for native clients.
- [ ] HIPAA controls review.
- [ ] SaMD/regulatory positioning review.
- [ ] Accessibility audit for WCAG 2.1 AA target.
- [ ] Device matrix testing.
- [ ] Store listing content.
- [ ] Privacy nutrition labels and Play Data Safety forms.
- [ ] TestFlight and internal Android distribution.
- [ ] Crash reporting and redaction review.
- [ ] Clinical pilot runbook.
- [ ] Support and incident response runbook.

Exit criteria:

- Signed release candidates are available for controlled pilot.
- Monitoring, rollback, and support procedures are documented.
- Clinical and privacy risks have named owners.

## 6. First Implementation Slices

These are the first implementation tasks to execute from this document.

### Slice 1 - Stabilize current mobile fetch behavior

Reason: the current `apiFetch` forces JSON content type, which breaks multipart voice upload and any future native-compatible upload behavior.

Checklist:

- [x] Preserve caller-provided `Content-Type`.
- [x] Do not set JSON content type for `FormData`.
- [x] Preserve caller-provided `Authorization` unless a token refresh retry occurs.
- [ ] Add a regression test when dependencies are installable.

### Slice 2 - OpenAPI pipeline scaffold

Reason: Kotlin and Swift clients need a stable API contract.

Checklist:

- [x] Register `@fastify/swagger`.
- [x] Register `@fastify/swagger-ui` only in non-production or behind config.
- [x] Add `npm run openapi:generate --workspace=@cope/api`.
- [x] Add a generated or exported `docs/api/openapi.json`.
- [x] Start route schemas with auth, patient, daily-entry, consent, sync, and notifications.
- [x] Add compatibility or replacement contract for assessment response submission by scale.
- [x] Add dedicated push-token registration contract.

### Slice 3 - Consent contract alignment

Reason: mobile and backend currently use different consent type names.

Checklist:

- [x] Define canonical consent enum in `packages/shared`.
- [x] Use the enum in API schemas.
- [x] Update current mobile consent UI to canonical types.
- [ ] Use the same enum in native app code generation.
- [x] Add DB verification for existing consent rows.
  - Live `copedemo` rows currently used `ai_insights` in the sampled consent records.

### Slice 4 - Native repository scaffold

Reason: native app work can start once contract direction is chosen.

Checklist:

- [x] Create Android app shell.
- [x] Create iOS app shell.
- [x] Add shared design token source.
- [x] Add generated-client or KMP-core build path.
  - `packages/mobile-contracts` owns OpenAPI validation plus Kotlin and Swift generation configs.
  - Generated Kotlin and Swift clients are committed as reviewable source artifacts for the first native implementation slice.
- [x] Add first smoke test on both platforms.
  - Android: `npm run native:android:assemble`.
  - iOS: `npm run native:ios:build`.

### Slice 5 - iOS auth/session and patient profile

Reason: the iOS app needs the first real generated-client workflow before expanding into clinical surfaces.

Checklist:

- [x] Link `apps/ios` to the generated `COPEOpenAPI` Swift package through XcodeGen.
- [x] Add environment-based API base URL configuration for dev/staging/production.
- [x] Add Keychain-backed access/refresh token persistence.
- [x] Add generated-client wrapper for login, refresh-on-401 retry, logout, and `/patients/me`.
- [x] Add SwiftUI root session state and login screen.
- [x] Add first authenticated profile screen backed by `GET /api/v1/patients/me`.
- [x] Verify `npm run native:ios:build`.
- [ ] Add UI test harness for login/profile once a stable simulator fixture account is available.

### Slice 6 - iOS Today and assessments network workflow

Reason: the first clinical workflow needs to prove native SwiftUI screens can use generated contracts beyond profile reads.

Checklist:

- [x] Add typed iOS app decoders around generic OpenAPI success envelopes.
- [x] Add generated-client wrapper methods for `GET /daily-entries/today`, `POST /daily-entries`, and `PATCH /daily-entries/:id/submit`.
- [x] Add generated-client wrapper methods for `GET /assessments/pending` and `POST /assessments`.
- [x] Add authenticated tab shell for Today, Assessments, and Profile.
- [x] Add network-backed Today screen for mood, sleep duration, anxiety, stress, suicidal ideation, notes, save, and submit.
- [x] Add network-backed Assessments screen for pending scale list, generic item scoring, score calculation, and backend submission.
- [x] Verify `npm run native:ios:build`.
- [ ] Replace generic assessment item labels with approved/licensed instrument content and scoring fixtures.
- [~] Add offline local persistence, draft restore, outbox, and conflict handling.
  - iOS Today draft restore and local save status are implemented with file protection.
  - General outbox, encrypted database migration, conflict handling, and multi-screen persistence remain open.
- [ ] Add C-SSRS safety handoff before clinical pilot use.

### Slice 7 - iOS consent, safety, and notification infrastructure

Reason: the first usable native iOS pilot shell needs consent state, safety resources, and push-token registration before TestFlight use.

Checklist:

- [x] Add generated-client wrapper methods for consent list/update.
- [x] Add generated-client wrapper methods for safety resources and authenticated safety-plan read.
- [x] Add generated-client wrapper methods for notification preferences and push-token registration.
- [x] Add an authenticated Care tab for safety plan, crisis resources, consent controls, and notification preferences.
- [x] Add APNs permission flow, app delegate token callback bridge, remote-notification background mode, and `aps-environment` entitlement wiring.
- [x] Verify `npm run native:ios:build`.
- [ ] Add safety-plan patient acknowledgement/sign action once UI copy and clinical semantics are approved.
- [ ] Add local crisis-resource cache so safety resources remain available offline.
- [ ] Migrate backend push delivery from Expo-token assumptions to native APNs/FCM token metadata before real device notification delivery.
- [ ] Add device/simulator tests for notification permission states and consent persistence.

### Slice 8 - iOS Today local draft persistence

Reason: the native Today flow needs a first local-first behavior before broader encrypted database and sync outbox work.

Checklist:

- [x] Make `DailyEntryDraft` codable with backend-aligned coding keys.
- [x] Add a file-protected iOS draft store under Application Support for same-day Today drafts.
- [x] Restore a saved local draft when Today opens.
- [x] Save Today inputs locally before attempting the network save.
- [x] Surface local draft sync state in the Today UI.
- [x] Delete the local draft after successful submit.
- [x] Verify `npm run native:ios:build`.
- [ ] Promote this file-backed draft cache into the selected encrypted database/outbox design.
- [ ] Add retry/sync worker semantics for queued local writes.
- [ ] Add simulator/unit coverage for draft restore, pending upload, and submitted-delete behavior.

### Slice 9 - iOS invite registration, MFA continuation, and intake gate

Reason: a TestFlight pilot user must be able to enter the native app through the same invite and onboarding path used by the backend, not only by signing into a pre-created account.

Checklist:

- [x] Add flexible auth-response decoding for MFA partial-token responses where the backend intentionally omits a full access token.
- [x] Add iOS registration flow for invited patients using `POST /auth/register`.
- [x] Add `cope://invite?token=...` URL scheme registration and token prefill.
- [x] Add MFA verification sheet using the partial-token bearer flow.
- [x] Gate authenticated patients with incomplete onboarding into a native intake screen before showing tabs.
- [x] Add primary-concern and emergency-contact intake submission.
- [x] Align backend intake completion with the `onboarding_complete` profile flag consumed by `/patients/me`.
- [x] Add required consent acceptance to invite registration and required consent gating to onboarding instead of only authenticated Care-tab controls.
- [x] Verify `npm run native:ios:build`.
- [ ] Add medication, symptom, trigger, and reminder onboarding steps.
- [ ] Add simulator/UI coverage for invite deep link, invalid invite errors, MFA continuation, and intake completion.

## 7. Live Database Verification Plan

The live database should be used for verification, not as the source of truth for undocumented behavior.

Verification tasks:

- [x] Confirm database name and current schema version.
  - The reachable database is `copedemo`; a `cope` database was not present on the checked server.
- [x] Confirm all migration files in `packages/db/migrations` are represented in live schema state.
  - Live `_migrations` contained `001_initial.sql` through `020_authentik_oidc.sql`.
- [x] Inspect consent type values currently present in `consent_records`.
  - Sampled rows used `ai_insights`.
- [x] Inspect assessment scale values currently present in assessment tables.
  - Assessment table present as `validated_assessments`.
- [x] Inspect whether push tokens are one-per-patient or multi-device in practice.
  - Current schema uses single-token preference columns, including `push_token`, not a multi-device token table.
- [x] Inspect daily-entry columns against mobile local schema.
  - Backend daily entries include expanded clinical fields now mirrored by the current mobile reference DB schema.
- [x] Inspect safety plan and safety event tables.
  - `crisis_safety_plans` and `safety_events` are present.
- [x] Confirm no production PHI is exported into local files during verification.
  - Verification used schema and aggregate metadata checks only.

Credential handling:

- Do not commit credentials.
- Do not write credentials into docs, scripts, shell history, or checked-in env files.
- Prefer a temporary process environment or password prompt.
- Redact connection strings from logs.

## 8. Acceptance Criteria for Native Split Completion

The native split is complete only when:

- Expo app is no longer required for patient workflows.
- Android and iOS both support invite registration, MFA, consent, intake, check-in, journal, medications, assessments, insights, notifications, health integration, profile/settings, and safety resources.
- Primary clinical workflows work offline and sync safely.
- Assessment scoring and safety escalation match fixture tests on both platforms.
- Local storage is encrypted and wiped on logout.
- Push payloads are PHI-safe.
- Clinical and consent audit trails are intact.
- App-store-ready builds exist for both platforms.
- Release runbooks and support procedures are documented.

## 9. Risk Register

| Risk | Severity | Mitigation |
| --- | --- | --- |
| API contract drift during native development | High | OpenAPI artifact, generated clients, contract tests |
| Clinical logic diverges between Android and iOS | High | KMP shared core or golden fixture tests |
| Offline safety event delayed too long | High | Priority outbox and foreground sync trigger |
| Consent records mismatched across clients | High | Canonical shared enum and DB verification |
| LOINC/FHIR/OMOP semantic mismatch | High | Panel-vs-total mapping decision and mapper tests |
| Local PHI exposure | High | SQLCipher, keychain/keystore, log redaction |
| Notification payload PHI leak | High | Payload policy and tests |
| Native scope expands before foundation stabilizes | Medium | Phase gates and exit criteria |
| Dependency/tooling drift blocks verification | Medium | Repair lockfile separately from native work |

## 10. Immediate Next Actions

- [x] Fix current mobile `apiFetch` multipart/header behavior.
- [x] Repair `package-lock.json` so workspace installs and verification commands run.
- [x] Add OpenAPI registration scaffold to the API.
- [x] Add first mobile-critical route schemas.
- [x] Verify live DB schema once dependencies or DB tooling are available.
- [x] Decide KMP shared core versus fully independent native clients with generated contracts.
  - Proceeding with independent native clients plus generated-contract discipline for the first implementation track.
- [x] Implement first iOS generated-client flow: auth/session plus `/patients/me`.
- [x] Implement first iOS clinical workflow slice: network-backed Today save/submit and pending assessment submit.
- [x] Implement first iOS consent/safety/notification infrastructure slice.
- [x] Implement first iOS local Today draft persistence slice.
- [~] Implement iOS invite registration, MFA continuation, and consent/intake screens.
  - Invite registration, MFA continuation, required consent gating, and primary/emergency-contact intake gate are implemented.
  - Medication, symptom, trigger, and reminder intake remain open.
- [ ] Choose iOS encrypted persistence stack and start daily-entry local cache/outbox.
