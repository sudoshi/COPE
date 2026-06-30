# COPE iOS — SwiftUI Build Prompt (Full Bible)

> **Role:** You are a senior iOS engineer building the **COPE patient app** in **Swift 6 / SwiftUI** for **iPhone (iOS 17+)**.
> **Source of truth for visuals:** the rendered prototype in `COPE iOS Prototype.dc.html` and the PNG stills in `/stills` (light) and `/stills/*-dark.png` (dark). Match them faithfully — spacing, type, color, warmth.
> **Source of truth for behavior/contract:** the COPE strategy docs (`03-NATIVE-IOS-ANDROID-PLAN.md`, `05-NATIVE-SPLIT-TODO-IMPLEMENTATION-PLAN.md`). The backend already exists; do **not** invent new endpoints — consume the ones listed in §9.
> **North star:** *the trusted, clinically-connected loop between a patient's daily life and their care team.* Warm, human, calm, trauma-informed. One primary action per screen. Safety always one tap away.

This document is exhaustive. Build in the phase order in §14. Every screen section gives you: **purpose → layout → components → state → API → interactions → accessibility.**

---

## 1. Product context (read once)

COPE is a research-grade clinical mental-health platform (bipolar-aware). This app is the **patient** client. It replaces an Expo/React-Native app with a fully native build. The backend (Fastify REST + WebSocket) is mature: auth/MFA/OIDC, multi-domain daily entries, validated assessments (PHQ-9, GAD-7, ASRM, ISI, C-SSRS, WHODAS, QIDS-SR), medications, journaling, Stanley-Brown crisis safety plans, passive health ingest, AI insights (consent-gated), and a WatermelonDB-shaped offline `/sync` protocol.

**The hero of this app is the daily check-in.** The single biggest product differentiator is the **secure two-way care-team messaging loop**. Treat both with extra craft.

**Hard guardrails (do not violate):**
- Messaging is **not** a crisis channel — always show response-time expectations and route emergencies to 988 + the safety plan.
- **Never put PHI in any notification payload or banner.** Neutral copy only ("Time to check in", "New secure message").
- No third-party ad/tracking SDKs, ever. No standalone "AI therapist" — AI is augmentation only, consent-gated, with human escalation.
- No guilt mechanics. Streaks are gentle, with freeze/grace days. Progress framing, never loss-aversion.
- 18+ only (v1).

---

## 2. Tech stack & project setup

- **Language/UI:** Swift 6.2 (strict concurrency, default `@MainActor` isolation), SwiftUI-first. Min target **iOS 17.0** (use `@Observable` macro; if you must support 16, fall back to `ObservableObject`).
- **Architecture:** **MVVM-lite.** `@MainActor @Observable` view-model per screen that has real logic (check-in, assessment scoring, sync status, safety plan). Bind directly for trivial screens. Consider **TCA** *only* for the multi-step check-in & assessment state machines if you want exhaustive testability — not required.
- **Packages (local SPM):** `DesignSystem`, `CopeCore` (models + clinical scoring + validation, mirrors `@cope/shared`), `Networking`, `Persistence`, and `Feature*` modules (`FeatureCheckIn`, `FeatureCare`, `FeatureSafety`, `FeatureAssessments`, `FeatureMeds`, `FeatureJournal`, `FeatureInsights`, `FeatureProfile`, `FeatureOnboarding`). Thin app target = composition root.
- **Networking:** `URLSession` async/await. An `actor`-isolated token-refresh interceptor that matches COPE's **rotating refresh tokens** (15-min access / 7-day refresh, reuse-detected). `URLSessionWebSocketTask` in an `actor` exposing an `AsyncStream` for live events (message.created, alerts) with heartbeat + backoff + re-auth.
- **Persistence:** **GRDB.swift** (FTS5 for journal search) wrapped behind a `Persistence` package. Encrypt at rest with **SQLCipher (GRDBCipher)** + `NSFileProtectionComplete`; key in Keychain/Secure Enclave. Do **not** use SwiftData.
- **Charts:** Swift Charts.
- **DI:** Factory (or plain init injection).
- **Bundle id:** `com.cope.app`. **API base URLs:** prod `https://app.cope.health`, staging `https://staging.cope.health`, local `http://localhost:3000`. Apple Team ID `TKXPY255A2`, App Store Connect app id `6785638840`.

---

## 3. Design system → `DesignSystem` package

Match the prototype exactly. Warm, paper-like neutrals; teal primary; clay warm accent; a red→blue mood scale. **Two themes**, switched by `@Environment(\.colorScheme)` (support system + manual override stored in `@AppStorage`).

### 3.1 Color tokens

Define a semantic palette resolved per scheme. Hex values below are authoritative.

```swift
public enum CopeColor {
    // Light                              Dark
    static let canvas    = scheme(light: "#F1ECE4", dark: "#101413")
    static let surface   = scheme(light: "#FFFFFF", dark: "#1B211F")
    static let surface2  = scheme(light: "#FAF6F0", dark: "#212825")
    static let surface3  = scheme(light: "#F3EEE6", dark: "#283029")
    static let ink       = scheme(light: "#20251F", dark: "#EDF0EA")
    static let ink2      = scheme(light: "#5D625B", dark: "#A4AAA1")
    static let ink3      = scheme(light: "#9A9E96", dark: "#6E746C")
    static let line      = scheme(light: "rgba(32,37,31,.09)", dark: "rgba(255,255,255,.10)")
    static let teal      = scheme(light: "#2F9E8F", dark: "#54B9A8")
    static let tealDeep  = scheme(light: "#1F6F64", dark: "#7FD3C4")
    static let tealSoft  = scheme(light: "#E3F1ED", dark: "rgba(84,185,168,.15)")
    static let tealInk   = scheme(light: "#1C5F56", dark: "#8FDCCD")
    static let clay      = scheme(light: "#D68A68", dark: "#E09E7F")
    static let claySoft  = scheme(light: "#F6E7DF", dark: "rgba(224,158,127,.16)")
    static let amber     = scheme(light: "#E3A93F", dark: "#E9B95A")
}
```

- **Primary gradient** (CTAs, hero, FAB): `linear 150° teal → tealDeep`.
- **Crisis gradient** (988 card only): `150° clay → #C06A4B` (light) — warm, never alarming red.
- **Card shadow (light):** `0 1px 2px rgba(32,37,31,.05), 0 12px 32px -18px rgba(32,37,31,.22)`. Dark: deeper, lower opacity.

### 3.2 Mood scale (1–10)

A diverging red→amber→teal→blue scale. Index `mood-1`:

```swift
let moodColors = ["#D9645A","#DD7A5B","#E0935F","#E4AD61","#E7C765",
                  "#BFC77A","#8FC08C","#6FB89A","#64A6B0","#5A93C4"]
let moodWords  = ["Really low","Low","Heavy","Tender","Neutral",
                  "Steadying","Okay","Good","Bright","Really good"]
```
Mood slider track = `linear 90° #D9645A,#E0935F,#E7C765,#8FC08C,#5A93C4`.

### 3.3 Typography

- **Display / headlines:** **Fraunces** (variable serif), weight 600, optical sizing on. Used for greetings, screen titles, question prompts, big numbers. Bundle the variable font; register via `UIAppFonts`.
- **Body / UI:** **Figtree**, weights 400/500/600/700.
- Scale (support **Dynamic Type** — these are the default sizes, must scale): Display 30 / Title 26–27 / Section-title (Fraunces) 18–20 / Body 14–15 / Caption 12–12.5 / Micro 11. Question prompts use Fraunces 24–27, line-height ~1.2.
- Uppercase labels (e.g. "MORNING CHECK-IN", "TODAY") use Figtree 12–13, weight 600, letter-spacing ~0.4px.

### 3.4 Shape & spacing

- Radii: cards 18–22, hero/large cards 22–26, pills 11–14, full-round for avatars/FAB/toggles. Screen content horizontal padding **20–24**.
- Buttons: primary 16px vertical padding, radius 17, Fraunces-free (Figtree 600 15.5). Min hit target **44×44**.
- Tab bar uses a translucent material (`.ultraThinMaterial`) over a hairline top border.

### 3.5 Iconography

Use **SF Symbols** throughout (the prototype draws lucide equivalents — map them): `house`, `chart.line.uptrend.xyaxis`, `bubble.left.and.bubble.right`, `person`, `pills`, `checkmark.seal`, `shield`, `mic`, `bell`, `faceid`, `heart.text.square`, `square.and.arrow.up`, `plus`, `chevron.left`, `xmark`, `paperplane.fill`, `phone.fill`. No emoji.

---

## 4. Reusable components (build these first, in `DesignSystem`)

| Component | Spec |
|---|---|
| `PrimaryButton` | Teal→tealDeep gradient, white Figtree 600, radius 17, soft teal shadow. Pressed = scale 0.98. Full-width by default. |
| `SecondaryButton` | `surface` bg, `line` border, `ink` text. |
| `CopeCard` | `surface` bg, 1px `line` border, radius 18–22, card shadow. The workhorse container. |
| `FeatureCard` | Tinted gradient (`tealSoft→surface` or `claySoft→surface`) + colored border — used for the privacy card, correlation card, crisis trust card. |
| `MoodDial` | 150×150 circle filled with current `moodColor`, big Fraunces number centered, colored glow shadow; animates color on change (`.animation(.easeOut, value: mood)`). |
| `MoodSlider` / `TealSlider` / `ClaySlider` | Custom `Slider` styles with a gradient track (10px, radius 6) and a 28px white thumb with shadow. iOS `Slider` can't gradient-fill natively — build with a `GeometryReader` track + draggable thumb, or a styled `UISlider` wrapper. |
| `SegmentedChoice` | 2–3 equal pills; selected = teal fill + white, glow; unselected = `surface2` + `line`. (Sleep quality, structured replies.) |
| `ChoiceChip` | Multi-select tag pill; selected = teal fill white, else `surface` + `line`. (Stress/triggers, intake concerns.) |
| `StackedOption` | Full-width left-aligned option with title + subtitle; selected = `tealSoft` bg + teal border. (Mania pole, C-SSRS, PHQ answers.) |
| `MedToggle` | 52×31 pill toggle, teal when on, 25px white knob translating 21px. |
| `SettingsRow` | Icon tile (34, `surface2`, tealInk) + label + trailing chevron/value, hairline divider between rows. |
| `ProgressBar` | 6px track `surface3`, teal→tealDeep fill, width animates 0.35s. |
| `SafetyButton` | Always-available affordance: dashed `line` border, shield icon, "My safety plan · 988 inside". |
| `DeviceChrome` (prototype only) | Not needed in the real app — the OS provides status bar/safe areas. Honor safe-area insets; the tab bar sits above the home indicator. |

Entrance motion: subtle `translateY(9→0)` on content appearance (no opacity-gated reveals — keep content visible if interrupted). Respect `accessibilityReduceMotion`.

---

## 5. Navigation architecture

```
RootView
 ├─ if !authed → AuthFlow (Login → MFA → forced-password-change → biometric unlock)
 ├─ if authed && !onboarded → OnboardingFlow (5 steps)
 └─ else → MainTabView
       tabs: Today · Insights · [Check-in FAB] · Care · You
       + center raised FAB launches CheckInFlow (full-screen cover)
       + pushed/cover destinations: SafetyPlan, Medications, Assessment, Journal
```

- **Tab bar:** 5 slots; the **center is a raised circular teal FAB** (the `+`) that presents the **Check-in** as a `.fullScreenCover`. Labels: Today, Insights, (FAB), Care, You.
- **Check-in, Safety, Assessment, Meds, Journal, Onboarding** are full-screen covers/flows with their own top bar (back chevron + optional progress + close).
- **Safety is reachable from everywhere:** Today card, check-in safety branch, Care composer footer, and a global affordance. One tap to the plan; the 988 actions are inside it.
- App state holder: `@Observable final class AppState { var tab; var unlockState; var theme }`. Check-in/assessment/onboarding each own a step-machine view-model.

---

## 6. Screen specs

> For every screen: match the corresponding still. Use `CopeCard`, tokens, and components from §3–4. All copy below is the real copy — use it.

### 6.1 Onboarding (`/stills/04-light2.png` = welcome)

5 steps, top progress bar + back chevron, sticky bottom `PrimaryButton`.
1. **Welcome** — centered: rounded-square teal logo tile (Fraunces "c"), "Welcome to COPE", subcopy "A calmer, more connected way to stay close to your care team — built around how you actually feel, day to day." CTA "Get started".
2. **Privacy promise** — shield icon, "First, our promise to you". Three check rows: *Journals & messages are encrypted* · *We never sell or advertise on your data* · *You choose what your care team can see*. (This is a marketed differentiator — make it feel sincere.)
3. **About you (intake)** — "A little about you". Multi-select concern chips (Low mood, Anxiety, Mood swings, Sleep, Stress, Medication support). Below: the assigned clinician card (Dr. Alvarez · Bayview). Maps to `PATCH /patients/me/intake`.
4. **Daily rhythm** — "Your daily rhythm". Two reminder rows: Morning check-in (mood & sleep) 8:00 AM; Evening reflection (optional) 9:00 PM. Schedules local notifications (§11). Copy: "Gentle nudges — never guilt."
5. **Ready** — big teal check, "You're all set, [Name]", subcopy mentioning the care team + "the 988 lifeline is always one tap away." CTA "Enter COPE".

State: `obStep 0…4`, selected concerns, reminder times. On finish → write consent + intake, set `onboarded`.

### 6.2 Auth (from docs — not in stills, build to spec)

Login (email/password) → optional `mfa_pending` → TOTP verify → optional forced-password-change modal → biometric unlock on subsequent launches. Use the same warm visual language: Fraunces title, `CopeCard` form, `PrimaryButton`. **Accessible Authentication (WCAG 3.3.8):** allow paste, offer biometric; the forced-password-change modal must accommodate paste + autofill. Tokens to Keychain (`WhenUnlockedThisDeviceOnly` + `.biometryCurrentSet`). Auto-logoff after ~2–5 min inactivity → clear in-memory PHI, re-auth with Face ID.

### 6.3 Today / Home (`/stills/01-light.png`, `/stills/01-dark.png`)

**Purpose:** calm landing; surfaces today's one clear action (check-in) + what's due.
- Header: "TUESDAY · GOOD MORNING" (teal uppercase) + "Hi, [Name]" (Fraunces 30) + round avatar button (→ You).
- **Hero check-in card** (teal gradient, soft circles): "MORNING CHECK-IN" / "How are you feeling today?" / "A gentle 2-minute reflection. Just where you are — no right answers." / "Begin →" pill. Tapping launches Check-in. (Adapt greeting + AM/PM label by time of day; PM = "Evening reflection".)
- Two stat cards: **Gentle streak** ("11 days · 1 freeze left") and **Mood, 7-day** mini bar chart (colored by mood scale).
- **TODAY** list of `CopeCard` rows: Morning medications (→ Meds, shows "2 due" clay badge + taken count), Weekly PHQ-9 check (→ Assessment, "from Dr. Alvarez · due today"), Dr. Alvarez replied (→ Care, with unread dot), and the dashed **safety** affordance.
- Data: `GET /daily-entries/today` (done?), `GET /medications/today`, `GET /assessments/pending`, last message preview, streak from local history.

### 6.4 Daily check-in — THE HERO (`/stills/02-light.png`, `/stills/02-dark.png`)

Full-screen flow. Top: back chevron + `ProgressBar` + close. Step label "Step n of 10 · [Domain]". Sticky bottom CTA ("Continue" / "Complete check-in"). **One question per screen, calm, generous whitespace.** Steps (`/stills/01-feature.png` = step 1, `/stills/bodymap2.png` = step 5):

0. **Mood** — `MoodDial` (color + number) + Fraunces mood word + `MoodSlider` (1–10) + "Really low / Really good" end labels.
1. **In words (feeling-words picker) — NEW.** "When you sit with it, what's there?" A wrap of multi-select `ChoiceChip` feeling words (Numb, On edge, Heavy, Hollow, Wired but tired, Foggy, Restless, Overwhelmed, Irritable, Disconnected, Lonely, Ashamed, Hopeful, Calm). Lets patients who can't rate a number still *name* the experience (alexithymia support) — much richer signal for the care team than a slider alone. Footer hint: "Can't find the word? You can write it your own way at the end." Persist as an array on the daily entry (extend additively).
2. **Sleep** — `TealSlider` hours (0–12, 0.5 step, big Fraunces "Xh") + `SegmentedChoice` quality (Restless / Okay / Restful).
3. **Energy & interest** — `TealSlider` energy (0–10, word label) + anhedonia `ChoiceChip` row (Yes mostly / A little less / Not really).
4. **Anxiety** — centered word + `ClaySlider` (0–10) + Calm/Very anxious labels.
5. **Where you feel it (body map) — NEW.** "Where do you feel it?" A minimalist tappable body figure (head, chest, stomach, arms, legs — build from rounded shapes, not a complex illustration). Tapping a region fills it teal and adds it to a summary line; an "It's all over" pill captures diffuse/whole-body sensation. Somatic, pre-verbal input for anxiety/panic that's hard to put in words. Persist selected regions as an array (additive).
6. **Energy regulation (mania pole) — ADAPTIVE.** Show only for patients flagged bipolar in their care plan (badge "Tailored to your care plan"). "Any racing or speeding up?" with three `StackedOption`s (Not at all / A little / Quite a bit). For unipolar patients, **skip this step**.
7. **What's present** — multi-select `ChoiceChip` grid (Work/school, Relationships, Sleep, Money, Health, Substance use, Feeling alone). Maps to triggers catalogue.
8. **Safety (C-SSRS, gentle)** — "One gentle, important question" / "Over the past day, have you had thoughts that you'd be better off not alive, or of hurting yourself?" Four `StackedOption`s (Not at all / Fleeting / Some of the time / A lot). **If ≥ "Some of the time", reveal an inline clay support card** ("Thank you for telling us… You're not alone") with **"Open my safety plan"** + **"Call or text 988 now"**. This is the most important interaction in the app — see §7 escalation.
9. **Reflection** — optional free-text note + **"Speak instead"** voice affordance (→ `/voice/transcribe`) + a recap card (Mood, Sleep, Anxiety). CTA "Complete check-in".

> Feeling-words and body-map are **expression aids** — they exist to help patients who struggle to articulate their state share it anyway. Keep both fully optional and never required to advance. Add the same feeling-words picker to the Journal compose screen.

**Offline-first:** write a local draft (file-protected) on every change; restore on open; submit via outbox. `POST /daily-entries` then `PATCH /daily-entries/:id/submit`. A positive C-SSRS answer is a **high-priority sync op** + may fire a CRITICAL path server-side. Never lose check-in data on process death.

### 6.5 Safety plan (`/stills/03-dark.png` = dark; capture light from prototype "Safety")

Stanley-Brown plan, patient-facing, signable.
- **Crisis card at top** (clay gradient): "IF YOU'RE IN CRISIS RIGHT NOW / You deserve support this moment." + **Call 988** + **Text 988** (real `tel:`/`sms:` to 988; deep-links must use the verified numbers — 988 lifeline, Crisis Text Line 741741). Caption "Built with Dr. Alvarez · Stanley-Brown safety plan".
- Numbered sections (`CopeCard` each, teal numeral badge): 1 Warning signs · 2 Things that help me cope · 3 Reasons to keep going (clay pills) · 4 People I can reach out to (contact rows with call buttons) · 5 Making my space safer (means restriction).
- Data: `GET /safety/my-plan` (404 → empty state inviting them to build it with their clinician), `GET /safety/resources`, `POST /safety/my-plan/sign`. **Cache locally so it works offline** — the plan must open instantly with no network.

### 6.6 Care / secure messaging — TOP DIFFERENTIATOR (`/stills/04-light.png`, `/stills/04-dark.png`)

Care-team-scoped (one thread with the team, not per-clinician).
- Header: overlapped team avatars + "Your care team" + status dot "Usually replies within 1 business day."
- Conversation: day separators; clinician bubbles (`surface`, left, tail bottom-left); patient bubbles (teal gradient, right, white, "Read" receipt).
- **Escalation trust card** (teal `FeatureCard`, shield-check): "YOUR TEAM IS LOOKING OUT FOR YOU / After this morning's check-in, Sam was notified and will reach out today. You don't need to do anything." — shown when a safety signal fired; never a dead end.
- **Structured between-visit prompt** card from clinician: small "QUICK CHECK-IN" label + question + quick-reply chips (Better / Same / Worse) that post a structured response.
- Composer: rounded input + teal send FAB. **Footer micro-copy (required):** "Not for emergencies — in a crisis, tap for 988 & your safety plan" → opens Safety.
- Data: `messages` resource + `/messages` REST + WS `message.created` (additive backend touch-point per doc 03 §3.1). No message body in push payloads.

### 6.7 Insights (`/stills/03-light.png`, `/stills/03-dark.png`)

- Title "Insights" + "Patterns from your check-ins — yours alone to share."
- **Mood card:** Swift Charts line (14 days) with soft teal area gradient + end dot; "Last 14 days"; Jun 8 → Today axis.
- **Correlation `FeatureCard`** (teal): trend-up icon + "A PATTERN WORTH NOTICING" + "On days you moved your body, your mood the next morning was **+1.8 higher** on average." (Back with `patient_correlation_cache`.)
- Two stat cards: Sleep avg (6.8h + mini bars) and PHQ-9 (9, "↓ from 14", "Moving from moderate toward mild").
- **Weekly reflection (AI) card** — only when `ai_insights` consent + BAA gate on; lock icon caption "Generated privately, with your consent · not a diagnosis." Never imply diagnosis/treatment.
- Data: `GET /insights/me?days=30`, `…/risk-scores`, `…/ai` (gated).

### 6.8 Assessments — PHQ-9 (`/stills/01-light2.png` = intro; dark question in `/stills/02-dark.png`)

- **Intro:** checkmark-seal tile, "A weekly check on your mood", "Dr. Alvarez asked for this… Nine questions, about five minutes." + framing card "Over the last 2 weeks, how often have you been bothered by each…". CTA "Begin".
- **Per question (1–9):** progress bar + "QUESTION n OF 9" + "Over the last 2 weeks…" + Fraunces question + four `StackedOption`s: Not at all (0) / Several days (1) / More than half the days (2) / Nearly every day (3). Auto-advance on pick; back navigates.
- **Result:** score circle (`/27`) + interpretation band (Minimal <5 · Mild 5–9 · Moderate 10–14 · Mod-severe 15–19 · Severe 20+) + "shared securely with Dr. Alvarez" + comparison to prior ("↓ from 14 two weeks ago"). 
- **C-SSRS / item 9 safety:** if the suicide item is answered > 0, trigger the **safety handoff** (resources + safety plan + 988), same as §7. Do not let a positive land silently.
- Use the **same generic flow** for GAD-7, ASRM, ISI, WHODAS, QIDS-SR (different item text + ranges). **Use approved/licensed instrument wording and validated scoring** — see §13. Data: `GET /assessments/pending`, `POST /assessments`, `GET /assessments/:id/fhir`.

### 6.9 Medications (`/stills/04-v.png` from earlier set / prototype "Meds")

- Header "Medications" + `+` add. Summary card "1/3 · Today's doses · Keeping a steady rhythm helps your levels stay even."
- Grouped by time ("MORNING · 8:00 AM", "EVENING · 9:00 PM"); each med row = pill icon tile + name + dose + `MedToggle` (adherence). Toggling writes `POST /medications/:id/logs` via outbox.
- Side-effect prompt (dashed card): "Noticing a side effect? Log it for your team →".
- **Local reminders** per med (§11). Data: `GET /medications/today`, `POST /medications`, `POST /medications/:id/logs`.

### 6.10 Journal (`/stills/02-light2.png` / prototype "Journal")

- Compose card "What's on your mind today?" with **Write** + **Speak** (voice) actions.
- "Gentle prompt" clay card (rotating prompt: "What's one small thing that felt okay today?").
- Entry list cards: mood dot + datetime + Fraunces title + excerpt + **shared/voice badges**. Tapping → **detail/edit** view (rich text, share-with-care-team toggle, delete). FTS search.
- Append-only / versioned for clinical audit; edits never silently overwrite. Voice via `POST /voice/transcribe` (multipart — do **not** force JSON content-type). Data: `GET/POST/PATCH /journal`, `PATCH /journal/:id/share`.

### 6.11 You / Profile & privacy (`/stills/03-light2.png` / prototype "Profile")

- Header: avatar + name + org ("Bayview Behavioral Health").
- **Privacy `FeatureCard`** (featured, teal): lock + "Your privacy, in plain terms" + "Your journals and messages are encrypted. We never sell or advertise on your data — ever." + row "See who's viewed your data →" (patient-facing access log).
- Settings list (`SettingsRow`s): Notifications & reminders · Face ID & app lock (On) · Apple Health data · Care team & sharing · Export my data. Then "Replay onboarding" + footer "COPE v1.1 · 988 built in".
- Consent controls map to the canonical consent enum (care data required; research, AI insights, journal sharing, emergency-contact, push all optional/toggleable). `GET/POST /consent`, `GET/PUT /notifications/prefs`. In-app **account deletion** (App Store 5.1.1).

---

### 6.12 Pre-visit prep — agenda & summary — NEW (`/stills/04-feature.png`)

**Purpose:** help patients *arrive heard* — turn two weeks of data into a story and let them choose what to raise, before the appointment. Entry points: a Today card ("Visit Thursday — let's prepare") and from the appointment record.
- Header "Before your visit" + appointment card (clinician, date/time, telehealth).
- Intro: "A quiet summary of your two weeks. Choose what you want to make sure you talk about — it'll be ready before you meet, so you don't have to find the words in the moment."
- **Auto-summary** ("Your last two weeks"): stat cards — Mood (4.8→6.4, trending up), Sleep (6.8h avg), PHQ-9 (14→9, improving), and a clay "Worth flagging" card (e.g. "Anxiety still spikes midweek"). Generated from existing data (`/insights/me`, assessments, correlation cache) — patient does not author the numbers.
- **Editable agenda** ("What I want to talk about"): a list of suggested items each with an include/exclude checkbox (teal when included) + "Add something else…". Pre-seeds from recent signals (the new dose, midweek anxiety, uneven sleep).
- Footer: "Share with Dr. Alvarez · N items" (posts to the care-team thread / appointment as a pre-visit note) + "Only you and your care team can see this."
- This implements doc 04 W1 #3 (pre-visit summary & shared agenda / shared decision-making). Keep it calm and non-clinical; it is a *preparation* surface, not a form.

## 7. The safety escalation pattern (build once, reuse)

A single `SafetyHandoff` surface, triggered by: check-in C-SSRS ≥ "Some of the time", assessment suicide-item > 0, or any crisis language. It must:
1. Acknowledge warmly ("Thank you for telling us. You're not alone in this.").
2. Offer **one-tap**: Open safety plan · Call 988 · Text 988.
3. Show a trustworthy "your team has been notified" state in Care (never a dead end).
4. Submit the signal as a **high-priority** sync op; server raises the CRITICAL alert + care-team notification.
5. **Thresholds are provisional and require licensed-clinician sign-off before pilot** (decision OQ-004) — keep them in `CopeCore` constants, not scattered.

---

## 8. Security & HIPAA on device

- **Keychain** tokens `…WhenUnlockedThisDeviceOnly` + `.biometryCurrentSet`, wrapped with Secure Enclave. Biometric unlock **bound to a Keychain/Enclave crypto op** (not `evaluatePolicy` alone).
- **SQLCipher** (AES-256) for the local DB + `NSFileProtectionComplete`; key in Keychain/Enclave. Field-level encryption (CryptoKit AES.GCM) for highest-sensitivity PHI (journals, notes, messages).
- **ATS on** + SPKI cert pinning (≥1 backup pin). Best-effort jailbreak detection (gate sensitive actions, not launch). **Blur overlay** on `resignActive` (app-switcher privacy). Auto-logoff 2–5 min → clear in-memory PHI.
- **No PHI in logs/crash/analytics.** No hardcoded secrets (proxy 3rd-party keys via backend). Explicit **data wipe on logout** (Keychain + encrypted DB).

---

## 9. Backend contract (consume as-is — no backend changes for parity)

Base: `/api/v1`. Tokens: 15-min access, 7-day rotating refresh (reuse-detected).
- **Auth:** `POST /auth/login` → optional `mfa_pending` → `POST /auth/mfa/verify`; `POST /auth/refresh`; `POST /auth/change-password`; OIDC `GET /auth/oidc/redirect` + `POST /auth/oidc/exchange`.
- **Profile/intake:** `GET /patients/me`, `PATCH /patients/me`, `PATCH /patients/me/intake`.
- **Daily entries:** `GET /daily-entries/today`, `POST /daily-entries`, `PATCH /daily-entries/:id/submit` (21 clinical-domain columns).
- **Assessments:** `GET /assessments/pending`, `POST /assessments`, `POST /assessments/:scale/responses`, `GET /assessments/:id/fhir`.
- **Medications:** `GET /medications/today`, `POST /medications`, `GET /medications/:id/logs`, `POST /medications/:id/logs`.
- **Journal:** `GET /journal`, `POST /journal`, `PATCH /journal/:id`, `PATCH /journal/:id/share`.
- **Safety:** `GET /safety/resources`, `GET /safety/my-plan`, `POST /safety/my-plan/sign`.
- **Insights:** `GET /insights/me?days=30`, `GET /insights/me/ai…` (gated), `GET /insights/me/risk-scores`.
- **Passive health:** `POST /health-data/sync` (batch upsert), `GET /health-data/me`.
- **Catalogues/consent/notifications/voice:** `GET /catalogues/{triggers,symptoms,strategies}`, `GET|POST /consent`, `GET|PUT /notifications/prefs`, `POST /notifications/push-token`, `POST /voice/transcribe` (multipart).
- **Offline sync:** `GET /sync/pull?last_pulled_at=…&schema_version=…`, `POST /sync/push` — WatermelonDB-shaped changesets (created/updated/deleted per table, `last_pulled_at` unix-ms, server returns `server_id`+`updated_at`). Implement the **same wire protocol** against GRDB. Clinical records (assessments, journal) are **append-only/versioned**. New entities (messages) extend the changeset additively + bump `schema_version`.
- **Messaging (additive, for §6.6):** new `messages` resource + `/messages` REST + WS `message.created`.

**Codegen:** generate Swift DTOs from the API's OpenAPI 3.1 artifact (`docs/api/openapi.json`) — don't hand-write models that already exist there.

---

## 10. Offline & sync engine

Local DB is the single source of truth. **Lazy writes** (write local + enqueue), WebSocket invalidation triggers pulls, an **outbox** queues pushes. Conflict: field-level last-write-wins on server timestamps for single-author records; **explicit merge UI** for co-edited free text (shared safety plan, journal on two devices) — never silently drop PHI. Background sync via `BGTaskScheduler` + background `URLSession` + silent push; expedite a just-submitted C-SSRS.

---

## 11. Notifications

- **Local reminders:** `UNCalendarNotificationTrigger` for check-in + medication times (set in onboarding/profile). Survive restart + permission changes.
- **Push (APNs):** `.timeSensitive` for med/check-in reminders; **`.critical`** (Apple-reviewed entitlement) **reserved for clinically-validated crisis events only**; a Notification Service Extension composes a **PHI-free** banner.
- **Never put PHI in any payload/banner.** Neutral copy only. Register device token via `POST /notifications/push-token`.

---

## 12. HealthKit

Opt-in, revocable, per-type. Read sleep stages, steps, exercise time, `mindfulSession`, heart rate, **HRV (SDNN)**, mobility. Write COPE mood logs to **`HKStateOfMind`** and native PHQ-9/GAD-7 types. Background: `HKObserverQuery` + `enableBackgroundDelivery` + `HKAnchoredObjectQuery`. **Cannot detect denied read → design for empty results.** Sync derived snapshots to `POST /health-data/sync`. Process features on-device; transmit derived indicators, not raw traces. Patient-visible permissions + revoke flow.

---

## 13. Clinical scoring (in `CopeCore`, unit-tested)

Implement validated scoring + interpretation for PHQ-9, GAD-7, ASRM, ISI, C-SSRS, WHODAS, QIDS-SR with **golden fixture tests** (so iOS never diverges from server/Android). PHQ-9: sum 0–27; bands Minimal/Mild/Moderate/Mod-severe/Severe at 5/10/15/20; **item-9 > 0 → safety handoff**. Encode MBC numbers: PHQ-9 reliable change ~5 pts / remission <5; GAD-7 MCID ~4 / remission <5; prefer Reliable Change Index for individuals. **Use licensed/approved instrument wording.** All `ALERT_THRESHOLDS` are provisional pending clinician sign-off — centralize them.

---

## 14. Build order

1. **Foundations:** `DesignSystem` (tokens, type, all §4 components), `CopeCore` (models + scoring + golden tests), `Networking` (auth + refresh actor), `Persistence` (GRDB + SQLCipher). Verify against a health endpoint.
2. **Auth & shell:** login/MFA/forced-password-change, Keychain, biometric unlock, auto-logoff, `MainTabView`.
3. **Check-in (hero):** full 8-step flow, adaptive mania step, **C-SSRS safety branch + handoff**, offline draft + outbox.
4. **Today** dashboard wired to real data.
5. **Safety plan** (cached offline) + global reachability.
6. **Assessments** (PHQ-9 first, then the generic engine for the rest).
7. **Medications** + local reminders. **Journal** (list/detail/voice/FTS/share).
8. **Insights** (Swift Charts) + **HealthKit** ingest.
9. **Care / secure messaging** + WS + structured prompts + escalation trust state.
10. **Profile/privacy/consent**, account deletion, notifications hardening, full **sync** engine.
11. **Onboarding** (5 steps) front-to-back.
12. **A11y pass** (WCAG 2.2 AA, Dynamic Type to largest, VoiceOver, Accessibility Nutrition Labels), security hardening (MASVS), store metadata + Privacy Nutrition Labels.

---

## 15. Accessibility & tone (apply throughout)

- `.accessibilityLabel/Hint/Value/Traits` on every control; **Dynamic Type** to largest sizes (don't truncate Fraunces titles — allow wrap); honor `accessibilityReduceMotion`.
- **3.2.6 Consistent Help:** 988 / safety placement is fixed and predictable. **3.3.7 Redundant Entry:** don't re-ask known answers in assessments. **3.3.8 Accessible Authentication:** paste + biometric.
- Trauma-informed copy: warm, second-person, non-clinical on the surface ("How are you feeling today?" not "Complete your PHQ-2"). One primary action per screen. Autosave + undo for journals. Never shame a missed day.

---

### Asset checklist
- Fonts: **Fraunces** (variable) + **Figtree** (400–700) bundled & registered.
- App icon + onboarding logo: rounded-square teal tile, Fraunces "c" (replace with final brand mark when available).
- SF Symbols for all iconography (no custom SVGs needed).
- Verified crisis numbers: **988** (call/text), Crisis Text Line **741741**.

> Build it to feel like the stills: warm paper, teal calm, generous space, one gentle step at a time. The app should feel like a trusted companion that quietly keeps a patient connected to the people helping them.
