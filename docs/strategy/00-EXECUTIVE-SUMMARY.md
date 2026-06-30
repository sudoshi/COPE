# COPE Strategy — Executive Summary

**Document 0 of 5 · Strategy Series · 2026-06-27**

This series answers a four-part charge: (1) deeply examine COPE, (2) research current best practices for
clinician/patient mental-health communication, (3) plan **native iOS (Swift) + Android (Kotlin)** apps,
and (4) write a comprehensive plan to **enhance every aspect of COPE to supersede competitors.**

| # | Document | What it gives you |
|---|---|---|
| **01** | [Current-State Assessment](01-CURRENT-STATE-ASSESSMENT.md) | Evidence-based examination of the codebase as it really is |
| **02** | [Best Practices & Competitive Landscape](02-BEST-PRACTICES-AND-COMPETITIVE-LANDSCAPE.md) | Cited 2024–2026 evidence: patient, clinician/regulatory, native-mobile |
| **03** | [Native iOS + Android Plan](03-NATIVE-IOS-ANDROID-PLAN.md) | Full native-rebuild architecture, security, roadmap |
| **04** | [Competitive Enhancement Master Plan](04-COMPETITIVE-ENHANCEMENT-MASTERPLAN.md) | 8 workstreams, sequenced roadmap, metrics, anti-goals |

---

## The one-paragraph thesis
COPE is **far more mature than its README admits** — a v1.1a research-grade clinical platform (20
migrations / 52 tables, 70+ endpoints, real-time alerts, BAA-gated AI, OMOP CDM + FHIR R4, Stanley-Brown
crisis plans, OIDC SSO). Its value is **bottlenecked at the client tier**: the patient app is a ~65%-complete
Expo build and the clinician console is desktop-only. The market has a clean white space — consumer trackers
(Daylio/eMoods) are *islands* with no care-team link; clinical platforms (Lyra/Spring) are *employer-gated*
and thin on daily tracking; teletherapy incumbents (BetterHelp/Talkspace) are *FTC-scarred on privacy*.
**COPE's winning move is to own the trusted, clinically-connected loop between a patient's daily life and
their care team** — delivered through best-in-class native apps, closed by secure two-way communication,
measurement-based care, and safety planning, and sold into health systems via the collaborative-care billing
its architecture already fits.

## Five things that are true and decision-relevant
1. **The backend is the launch pad, not the bottleneck.** Native apps can light up capabilities that already
   exist server-side (passive health, assessments, crisis plans, AI insights, FHIR/OMOP).
2. **Communication is the #1 product gap** and the user's explicit focus. COPE has no clinician↔patient
   messaging today; building the secure, data-rich, safety-aware loop is the highest-leverage feature.
3. **Verification — not features — is the credibility gap.** The docs claim "80%+ test coverage"; the API has
   ~3%. Clinical alert thresholds are provisional and unsigned. For an FDA SaMD posture this must be fixed
   *before* a pilot. This is the biggest *non-feature* differentiator available.
4. **The regulated-device trigger is specific and known:** FDA's reissued **Jan 2026 CDS guidance** makes
   **time-critical, near-term (≤24h) suicide-risk alerts** the feature most likely to make COPE a **Class II
   device**. Everything else (transparent dashboards, trends, non-urgent suggestions) likely stays Non-Device
   CDS. Design accordingly; plan a PCCP if/when AI/ML or near-term alerting ships.
5. **The business model is collaborative care.** COPE's registry + PHQ-9/GAD-7 treat-to-target + caseload
   review **is literally the infrastructure CoCM/BHI billing requires** (99492–99494, 99484) plus RTM for
   self-report monitoring — a concrete ROI story consumer apps can't tell.

## Recommended native architecture (doc 03)
**KMP shared `commonMain` core (clinical scoring, validation, networking, offline-sync engine) behind fully
native SwiftUI + Jetpack Compose UIs.** GRDB/Room + **SQLCipher** offline (reusing COPE's existing `/sync`
protocol, hardened to append-only for clinical records); deep **HealthKit (State of Mind + native PHQ-9/GAD-7)
/ Health Connect (MindfulnessSession)** integration; crisis-grade native notifications; one-tap mood logging
via widgets/watch. Built to **OWASP MASVS L2+R** and **WCAG 2.2 AA**. **~7–9 months** to a pilot-ready
patient app on both platforms; clinician companion follows.

## Where to start (first 120 days)
- **Now (long-lead, start immediately):** engage a clinical advisor to sign off alert thresholds (OQ-004);
  stand up a real automated test suite + measured-coverage CI gate; begin SOC 2 Type II → HITRUST.
- **Build:** the `messages` backend (W1) + native foundation/auth/check-in (P0–P2); field-level encryption +
  audit-log immutability + prompt-injection hardening (W5).
- **Decide & sequence:** confirm KMP vs fully-native (team's Kotlin appetite); confirm the CoCM go-to-market
  as the primary enterprise wedge.

## Hard guardrails (anti-goals, doc 04)
No standalone "AI therapist" (augmentation only, with mandatory human escalation). No PDT-style standalone
prescribed-treatment business as the core model (the trap that bankrupted Pear). No guilt-based engagement
mechanics. No interruptive alerts for routine data. No third-party ad/tracking SDKs. No non-additive changes
to the protected auth system.

---

### Method note
This series draws on a deep multi-surface codebase examination (API, web, mobile, DB/migrations, docs,
prototype) plus three parallel research streams (~60+ web searches/fetches + PubMed) covering patient-facing
practice, clinician/regulatory practice, and native-mobile architecture. Every major external claim in doc
`02` carries an inline citation. Items the research flagged "verify at implementation time" are marked in
docs `02`/`03` (e.g., LOINC for ISI/ASRM/WHODAS, library versions, vendor BAA/HIPAA dates).
