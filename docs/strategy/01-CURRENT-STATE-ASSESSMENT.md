# COPE — Current-State Assessment

**Document 1 of 5 · Strategy Series**
**Date:** 2026-06-27 · **Version assessed:** v1.1a · **Author:** Engineering review

> This is a candid, evidence-based examination of the COPE platform as it exists today. It is the
> foundation for the competitive strategy, native-app plan, and enhancement master plan that follow
> (docs `02`–`04`). Where the documentation and the code disagree, the code is treated as truth and
> the discrepancy is flagged.

---

## 1. Executive Snapshot

COPE is **substantially more mature than its `README` (v0.4a) suggests**. The codebase is at **v1.1a**:
20 database migrations, ~52 tables, 70+ REST endpoints, a real-time WebSocket alert system, a
compliance-gated AI-insights pipeline, OMOP CDM research export, FHIR R4 read endpoints, Stanley-Brown
crisis safety plans, first-party rotating-token auth with OIDC SSO, and a cohort builder. This is a
**research-grade clinical platform**, not a prototype.

The three client surfaces are at very different maturities:

| Surface | Stack | Maturity | Headline gap |
|---|---|---|---|
| **Backend API** | Fastify 5 / Node 22 / PG 17 | **High** — broad, well-structured | Low automated test coverage; provisional clinical thresholds |
| **Clinician web** | React 19 + Vite | **High** for desktop | **No responsive/mobile layout**; no direct messaging |
| **Patient mobile** | Expo SDK 52 / RN 0.76 | **~65%** feature-complete | Charts, background sync, intake wizard, journal detail unfinished |

**The single most important strategic fact:** the backend already supports far more than either client
surface exposes. The platform's value is currently *bottlenecked at the client tier* — especially the
patient mobile app. Rebuilding that tier natively (the user's stated goal) is the highest-leverage move
available, and the backend is ready for it.

---

## 2. Architecture Overview

```
┌─────────────────┐   ┌──────────────────┐   ┌───────────────────┐
│ Patient Mobile  │   │ Clinician Web    │   │ Background Worker  │
│ (Expo SDK 52)   │   │ (React 19+Vite)  │   │ (BullMQ + Redis)   │
└───────┬─────────┘   └────────┬─────────┘   └─────────┬─────────┘
        │  HTTP/REST + WS       │  HTTP/REST + WS         │
        └───────────────────────┼─────────────────────────┘
                       ┌─────────▼──────────┐
                       │   Fastify 5 API     │  Zod validation, JWT,
                       │   /api/v1/*         │  rate limit, Helmet, Pino
                       └─────────┬──────────┘
              ┌──────────────────┼───────────────────┐
        ┌─────▼─────┐      ┌──────▼──────┐      ┌──────▼───────┐
        │PostgreSQL │      │   Redis     │      │  External    │
        │ 17 + RLS  │      │ pub/sub +   │      │  Anthropic / │
        │ 52 tables │      │ BullMQ jobs │      │  Resend /    │
        └───────────┘      └─────────────┘      │  Whisper /   │
                                                │  Authentik   │
                                                └──────────────┘
```

- **Monorepo:** npm workspaces + Turbo. `apps/{api,web,mobile}` + `packages/{db,shared}`.
- **Contract source of truth:** `@cope/shared` exports Types, Zod Schemas, and Constants
  (`MOOD_COLORS`, `ALERT_THRESHOLDS`, `CRISIS_CONTACTS`, `SCALE_LOINC_MAP`, `WS_EVENTS`, `LIMITS`).
- **Data access:** `postgres.js` raw SQL templates (no ORM). **RLS** is enforced in the database;
  every request calls `setRlsContext(userId, role)` which sets `app.current_user_id` /
  `app.current_user_role` for policy evaluation.
- **Async work:** five BullMQ queues — `cope-rules` (alert engine), `cope-ai-insights`,
  `cope-nightly` (02:00 ET scheduler), `cope-report-generator`, `cope-omop-export`.
- **Real-time:** WebSocket at `/api/v1/ws`, fanned out across instances via Redis pub/sub on
  `cope:alerts:{orgId}` channels.

---

## 3. Backend API — What Exists

The API is the platform's strongest asset. ~28 route modules, ~9,300 LOC of routes, grouped by domain.

### 3.1 Endpoint inventory (abridged)
- **Auth** (`/auth`): bcrypt login (clinicians + patients), `register-demo`, `change-password`,
  TOTP MFA (`enroll`/`activate`/`verify`), rotating refresh tokens (RFC 6819 reuse detection),
  `logout`, `me`, and OIDC SSO (`providers`, `oidc/redirect`, `oidc/callback`, `oidc/exchange`).
- **Patients** (`/patients`, `/patients/me`): caseload, detail, mood-heatmap, care-team management,
  patient self-service profile/catalogues.
- **Daily entries** (`/daily-entries`): upsert + submit; **21 clinical-domain columns** (mood, mania
  (ASRM-informed), anxiety (GAD-2), anhedonia, C-SSRS suicidal-ideation screener, substance (AUDIT-C),
  social/cognitive/appetite/stress, sleep, exercise, life events).
- **Assessments** (`/assessments`): PHQ-9, GAD-7, ISI, C-SSRS, ASRM, WHODAS, QIDS-SR with LOINC
  mapping and a FHIR `QuestionnaireResponse` export per assessment.
- **Journal, Medications, Alerts, Safety/Crisis, Notifications, Consent, Catalogues, Sync** (offline
  pull/push), **Invites, Reports, Clinicians (notes/caseload/snapshot), Admin (users + audit log),
  Research (exports/cohorts/OMOP concepts), Search (pg_trgm), Voice (Whisper), Health-Data
  (HealthKit/Health Connect ingest), Files, and FHIR R4** (`Patient/$everything`, `Observation`,
  `MedicationRequest`, `QuestionnaireResponse`, `Condition`, `CarePlan`, `Consent`, `metadata`).

### 3.2 Alert rules engine (RULE-001 … RULE-008)
Mood decline vs. baseline, missed check-ins, trigger escalation, **safety-symptom → CRITICAL +
auto-`crisis` status** (DB trigger `handle_safety_symptom`), medication non-adherence, sleep
disruption, exercise decline, and LLM journal-sentiment. **All numeric thresholds are provisional
engineering defaults** (`ALERT_THRESHOLDS` in `@cope/shared`) and explicitly require licensed-clinician
sign-off before any pilot (decision OQ-004).

### 3.3 AI / insights pipeline
- Provider-agnostic `llmClient` dispatches to **Anthropic Claude** (BAA-gated) or **local Ollama /
  MedGemma** (no BAA needed).
- Double gate: `AI_INSIGHTS_ENABLED=true` **and** `ANTHROPIC_BAA_SIGNED=true`; otherwise rule-based
  fallback. Per-patient `ai_insights` consent is checked before any inference.
- Jobs: weekly summary, trend narrative, anomaly detection, nightly deep analysis (structured findings
  + clinical trajectory), and an interactive clinician AI chat (`ai_discussions`).
- HIPAA preamble + de-identified clinical snapshot in every prompt; token cost recorded in `ai_usage_log`.

---

## 4. Data Model & Compliance Posture

### 4.1 Domains (52 tables across 20 migrations)
Identity/auth · clinical setup (ICD-10, RxNorm meds) · daily entries + sleep/exercise/adherence logs ·
wellness/triggers/symptoms catalogues + logs · **safety events** · journaling · alerts + routing +
notification prefs/logs · **validated assessments** (LOINC-coded) · **passive health snapshots**
(HealthKit/Health Connect: steps, HR, HRV, sleep stages, SpO₂) · **AI insights + usage + discussions** ·
**crisis safety plans** (Stanley-Brown, versioned) · cohorts + snapshots + research exports + **OMOP CDM
mapping** (person-id assignment, high-water-mark incremental export) · audit log (append-only) · consent
records (immutable history) · clinician notes/appointments/reports · population snapshots + correlation
cache + risk history.

### 4.2 Interoperability
- **FHIR R4 read** endpoints live today; assessment `QuestionnaireResponse` export works.
- **OMOP CDM** export pipeline with Safe-Harbour de-identification (18 identifiers), consent-gated
  `omop_person_id` assignment, and nightly incremental export.
- Medical coding embedded: **SNOMED-CT** (symptoms/triggers), **RxNorm/NDC** (meds), **LOINC**
  (assessments), **ICD-10** (diagnoses).

### 4.3 Compliance decisions (DECISIONS.md, OQ-001…010, all resolved)
- **OQ-002:** US market; COPE is **likely SaMD Class II** (it captures suicidal ideation and generates
  clinical-decision-influencing alerts). Formal regulatory assessment + HIPAA SRA still required pre-pilot.
- **OQ-004:** alert thresholds provisional — **clinical sign-off is a hard gate.**
- **OQ-005:** **18+ only** in v1.0 (state minor-consent law complexity deferred).
- **OQ-007:** AI behind BAA + env gate; prompts use aggregates, not raw PHI.
- **OQ-001:** journal encryption is server-side-at-rest; E2EE deferred to v2.0.
- Crisis defaults: **988** Suicide & Crisis Lifeline, Crisis Text Line **741741**.

---

## 5. Clinician Web Dashboard — What Exists

- **Stack:** React 19 + Vite 6, React Router v7, TanStack Query v5, lightweight pub/sub stores
  (auth/ui/theme), Recharts, lucide-react icons, Sentry with PHI scrubbing.
- **Pages:** Dashboard (population KPIs + mood heatmap + live alert feed), Patients (caseload roster +
  invites), Patient Detail (7 tabs: overview, mood trends, journal, notes, alerts, medications, AI
  insights), Alerts, Trends, Reports, Cohort builder (admin), Admin, Login/Register/MFA/OIDC-callback.
- **Real-time:** `useAlertSocket` with exponential-backoff reconnect; dashboard refetches on
  `ALERT_CREATED`.
- **Design-system discipline (notable strength):** a completed "readability remediation" replaced 102
  emoji + ad-hoc SVGs with a sized `<Icon>` vocabulary, migrated 491 inline font-sizes to `--text-*`
  tokens, and **enforces the contract in CI** (`scripts/check-readability.sh` + ESLint bans numeric
  `fontSize`). This is unusually rigorous and should be preserved as a platform asset.

**Gaps:** desktop-only (260px fixed sidebar, no responsive/hamburger), no direct clinician↔patient
messaging, Reports/Audit-log/LDAP partially scaffolded, no component unit tests (E2E only), aggressive
30s `staleTime`, no caseload pagination (risk at 500+ patients).

---

## 6. Patient Mobile App — What Exists (the replacement target)

- **Stack:** Expo SDK 52 / RN 0.76.9, Expo Router v4, WatermelonDB (offline), TanStack Query, Zustand,
  Expo SecureStore + LocalAuthentication (biometric), Expo Notifications, `react-native-health` +
  `react-native-health-connect`.
- **Built & functional:** onboarding/login/MFA, consent wizard, **9-step daily check-in** (full
  multi-domain incl. C-SSRS branching + safety modal), medications + adherence, journal (text + voice
  capture), insights tab (text summaries), profile, biometric lock (5-min timeout), push registration,
  passive-health ingest, and full **PHQ-9/GAD-7/ASRM/ISI/C-SSRS** questionnaires. WatermelonDB
  pull/push sync works on foreground.
- **Maturity ≈ 65%.** Unfinished: intake wizard (blocks self-serve enrollment), journal **detail/edit**
  view (route is a stub), **background sync** (foreground-only today), **trend charts** (Victory Native
  not integrated — text only), medication/assessment **local reminders** not firing, voice transcription
  flow incomplete, no offline encryption of the local DB, server-wins conflict resolution with no UI.

**Design intent (from `MOBILE_PLAN.md` + prototype):** clinically-informed, low-burden daily probes
(PHQ-2/GAD-2 daily, full scales weekly), bipolar-optimized mania pole, safety-first crisis resources on
every relevant screen, passive phenotyping. Fonts: Fraunces (display) + Figtree (body); teal `#2a9d8f`
primary; mood gradient red→blue.

---

## 7. Cross-Cutting Findings & Risks

### 7.1 Strengths to protect
1. **Clinical depth** — multi-domain daily entries, 7 validated instruments, bipolar mania pole,
   AUDIT-C/PSQI/PSS sub-items. Few competitors track this richly.
2. **Interoperability-ready** — FHIR R4 + OMOP CDM + standard code systems already wired. This is a
   genuine enterprise moat most consumer apps lack.
3. **Compliance scaffolding** — append-only audit log, immutable consent history, RLS isolation,
   BAA-gated AI, Safe-Harbour de-identification, refresh-token reuse detection.
4. **Safety architecture** — DB-level safety-symptom trigger, Stanley-Brown crisis plans, C-SSRS.
5. **Design-system rigor enforced in CI** (web).

### 7.2 Material risks & honest gaps
| # | Finding | Severity | Notes |
|---|---|---|---|
| R1 | **Test coverage discrepancy** | High | API agent found ~2/63 test files (~3%); `DEVLOG` claims "80%+". Treat coverage as **largely unverified** and prioritize a real test suite. |
| R2 | **Alert thresholds & risk score unvalidated** | High (regulatory) | Provisional values; require clinical sign-off (OQ-004) before pilot. Risk-scoring model needs validation + bias review. |
| R3 | **No clinician↔patient messaging** | High (product) | Communication is one-directional (journal share, notes, assessment requests). This is the #1 feature gap vs. the user's stated focus. |
| R4 | **PHI at rest** | Medium-High | Relies on DB/host encryption; no field-level encryption for journals/notes; mobile local DB unencrypted. |
| R5 | **Prompt-injection surface** | Medium | User journal/notes concatenated into LLM snapshots without sanitization. |
| R6 | **No automated SI escalation beyond alert** | Medium | C-SSRS ≥ threshold raises a CRITICAL alert but no automated emergency-contact / care-pathway workflow. |
| R7 | **Web is desktop-only** | Medium | No responsive layout; clinicians increasingly expect tablet/phone access. |
| R8 | **Mobile not release-ready** | Medium | ~65% complete; the native rebuild (doc 03) supersedes finishing it. |
| R9 | **Operational hardening gaps** | Medium | No DLQ monitoring, request tracing, audit-log immutability enforcement, report TTL cleanup, or OpenAPI docs. |

### 7.3 Documentation vs. reality
The `DEVLOG`/`V1.1_DEVELOPMENT_PLAN` describe all six phases as "complete" with "80%+ coverage." The
code shows the *features* are largely present but **test coverage and several mobile features are not**.
This gap matters for an FDA SaMD posture, where verification evidence is part of the regulatory record.
**Recommendation:** reconcile docs to ground truth and stand up a measured-coverage CI gate.

---

## 8. Implications for the Strategy That Follows

1. **The backend is the launch pad, not the bottleneck.** Native apps (doc 03) can light up
   capabilities that already exist server-side (passive health, assessments, crisis plans, AI insights).
2. **Communication is the biggest product gap** and the user's explicit focus → it becomes a tentpole of
   the enhancement plan (doc 04): secure async + structured between-visit messaging.
3. **Clinical validation + verification is the biggest *non-feature* gap** → thresholds sign-off, a real
   test suite, and a regulatory/quality workstream are prerequisites to "supersede competitors" credibly.
4. **Interoperability + measurement-based care are the moat** → lean into FHIR/SMART-on-FHIR,
   collaborative-care billing, and EHR embedding where consumer competitors cannot follow.

> Continue to **`02-BEST-PRACTICES-AND-COMPETITIVE-LANDSCAPE.md`** for the external evidence base, then
> **`03-NATIVE-IOS-ANDROID-PLAN.md`** and **`04-COMPETITIVE-ENHANCEMENT-MASTERPLAN.md`**.
