# COPE — Competitive Enhancement Master Plan

**Document 4 of 5 · Strategy Series**
**Date:** 2026-06-27 · **Author:** Product & engineering strategy

> The plan to enhance *all aspects* of COPE to supersede competitors. It synthesizes the current-state
> assessment (doc `01`) and the evidence/landscape (doc `02`). Each workstream has: **thesis →
> what to build → why it wins → effort/sequence**. Regulatory, interoperability, and enterprise
> workstreams (W6–W8) draw on doc `02` Part B.

---

## 0. Strategic Thesis — Win the Connected Loop

The market has a structural gap (doc `02` A7):
- **Consumer trackers** (Daylio, Bearable, eMoods) have great UX but are **islands** — no care-team
  connection, no measurement-based-care loop, no safety escalation.
- **Employer/payer clinical platforms** (Lyra, Spring) have outcomes infrastructure but are
  **employer-gated** and thin on daily patient-side tracking/journaling.
- **Teletherapy incumbents** (BetterHelp, Talkspace, Cerebral) are **distrusted on privacy** (FTC actions).

**COPE's winning position:** *the trusted clinical loop between a patient's daily life and their care
team.* A trauma-informed daily tracker whose data flows into a clinician dashboard with alerting, closed
by **secure two-way communication, validated PROMs, and safety planning** — and which wins on
**privacy/HIPAA transparency** and **clinical depth (esp. bipolar)** where consumer apps cannot follow.

**Five pillars** (each a workstream below): **Communication · Engagement & Efficacy · Safety ·
Trust/Privacy · Clinical Validation & Interoperability.**

---

## W1 — Close the Communication Loop (highest-priority product gap)

**Thesis.** COPE's #1 missing capability and the user's explicit focus. Communication today is
one-directional (journal share, clinician notes, assessment requests). The evidence (doc `02` A5) shows
tech-enabled collaborative care with real-time data + escalation **beats usual care** (Lancet Digital
Health 2024), and the winning 2026 model is **hybrid** (async + video + in-person escalation).

**What to build.**
1. **Secure asynchronous messaging** (patient ↔ care team), care-team-scoped (not per-clinician, matching
   OQ-009 journal model). New `messages` table + `/messages` REST + WS `message.created`; native + web UI.
2. **Structured between-visit check-ins** — clinician sends a templated prompt ("How's the new dose?"),
   patient responds with text + optional structured data; threads attach to the patient timeline.
3. **Pre-visit summary & shared agenda** — auto-generated trend digest + patient-set agenda items for the
   next appointment (shared decision-making pattern, doc `02` A5).
4. **Escalation pathway, productized** — when a safety alert fires, messaging surfaces a clear,
   time-bound clinician action with audit trail; patient sees a trustworthy "your team has been notified"
   state (never a dead end).
5. **(Phase 2) Telehealth video** — integrate a HIPAA-BAA video vendor (e.g., Daily/Twilio; Twilio creds
   already in `.env`), launched from the appointment record.

**Why it wins.** Converts COPE from a tracker into a *care relationship*. No consumer tracker has it;
teletherapy apps have messaging but not the **data-rich, safety-aware** loop.

**Guardrails.** Messaging is **not** a crisis channel — must show response-time expectations and route
emergencies to 988/safety plan. Full audit logging (HIPAA). Clear consent + minimum-necessary scoping.

**Effort/sequence.** Backend `messages` + WS: **M**. Native + web UI: **M**. Telehealth: **L** (Phase 2).
Sequence: **first major post-native workstream** (or parallel with native build since backend-led).

---

## W2 — Engagement & Efficacy (retention is the make-or-break metric)

**Thesis.** Real-world 30-day retention can be ~3% (doc `02` A1). Engagement → outcomes is real but
modest; **human support + digital navigators + embedded evidence-based modules** are the proven levers.

**What to build.**
1. **Digital-navigator role** — a non-clinician "care guide" surface in the web console + an in-app
   onboarding/troubleshooting concierge. Highest-evidence retention lever; fits COPE's clinician model.
2. **Forgiving engagement mechanics** — gentle streaks with "freeze"/grace days, progress framing (not
   loss-aversion), self-scheduled reminders, split **AM (sleep) / PM (mood/activity)** prompts per the
   design-principles doc. Avoid guilt mechanics that backfire for depressed users.
3. **Embedded evidence-based micro-modules** (not a standalone AI therapist):
   - **Digital CBT-I** (strongest single bet; sleep is a bipolar/depression leading indicator).
   - **Behavioral activation** (activity scheduling tied to mood correlations COPE already computes).
   - **JITAIs / EMIs** — context-triggered micro-interventions using passive + EMA signals (e.g., a
     coping-skill nudge when mobility + mood drop together).
4. **Personalized, context-aware notifications** — timing-optimized, capped to avoid fatigue;
   per-patient learning of best send time.
5. **Insights that motivate** — "when you exercised, mood was +X" (COPE's `patient_correlation_cache`
   already backs this) rendered as native trend charts.

**Why it wins.** Directly attacks the dropout problem competitors lose on; modules are evidence-based and
avoid the PDT reimbursement trap (doc `02` A2 — Pear's collapse).

**Effort/sequence.** Mechanics + notifications: **S–M** (mostly client). CBT-I/BA modules: **M–L** each
(content + logic). JITAIs: **L** (needs passive-signal pipeline, W3/native). Sequence: mechanics first,
modules iteratively.

---

## W3 — Passive Sensing & Digital Phenotyping (the data moat)

**Thesis.** Passive signals (sleep, mobility, activity, HRV) track affect and **relapse risk**, with
bidirectional **mobility↔mood** links especially relevant to bipolar (doc `02` A4). COPE already has
`passive_health_snapshots` + ingest; native unlocks the full signal set + on-device processing.

**What to build.**
1. **Full native health integration** — HealthKit sleep *stages*, HRV, gait/mobility, mindful minutes;
   Health Connect equivalents incl. *Mental Wellbeing*; background delivery (doc `03` Part 7).
2. **On-device digital-phenotyping features** — derive sleep-regularity, activity-variance, and
   social/mobility proxies on-device; sync **derived features**, not raw location (privacy-first).
3. **Relapse-signal detection** — feed derived features into the rules engine (additive RULE-009+):
   e.g., *>2h sleep drop + reduced mobility + elevated ASRM* → early hypomania warning. **Provisional;
   requires clinical sign-off (OQ-004 discipline).**
4. **Patient-controlled, revocable, granular consent** — per-signal toggles; transparent "what we use
   and why" (EMA reactivity + privacy constraints, doc `02` A4).

**Why it wins.** A *clinically-connected* phenotyping loop is something no consumer tracker offers and no
teletherapy app instruments. It deepens the bipolar moat.

**Effort/sequence.** Native integration: **M** (part of native build). On-device features + relapse
rules: **L**. Sequence: integrate during native build; rules after clinical validation.

---

## W4 — Safety, Productized (a trust + clinical differentiator)

**Thesis.** COPE already has Stanley-Brown plans (migration 013), C-SSRS, the DB safety-symptom trigger,
and 988 constants — ahead of most competitors. The gap is the **workflow around** a positive signal.

**What to build.**
1. **One-tap safety surface everywhere** — patient safety plan + 988 (call/text/chat) + Crisis Text Line
   always ≤1 tap; means-restriction guidance; reasons-for-living.
2. **Automated, audited escalation** — on C-SSRS/SI threshold or safety symptom: CRITICAL alert (exists)
   **+** care-team notification with response SLA, **+** patient sees "your team is notified" + immediate
   resources. Optional emergency-contact pathway (consent-gated).
3. **Collaborative safety planning in-app** — patient + clinician co-edit, version, and sign the plan
   (backend supports versioning + signatures already).
4. **Crisis-aware AI guardrails** — any AI surface detects crisis language → hands off to human +
   resources, never a dead-end loop (doc `02` A8, FDA DHAC expectations).

**Why it wins.** Safety done right is both an ethical mandate and a procurement differentiator for health
systems; consumer apps treat it as a static resource list.

**Effort/sequence.** Surfaces + escalation UX: **M**. Co-editing: **S** (backend ready). Sequence: with
W1 (shares the escalation/messaging plumbing). **Thresholds need clinical sign-off before pilot.**

---

## W5 — Trust & Privacy as an Explicit Differentiator

**Thesis.** The entire teletherapy sector is FTC-scarred (BetterHelp $7.8M; sector-wide allegations,
doc `02` A7). COPE can make privacy a *marketed* feature, not just a compliance checkbox.

**What to build.**
1. **Field-level encryption** for highest-sensitivity PHI (journals, notes, messages) — closes risk R4.
2. **Encrypted local store on device** (native) + jailbreak/root detection + cert pinning (doc `03` P6).
3. **Transparent data practices** — in-app "what we collect, who sees it, how to revoke," plus honest
   App Store **Privacy Nutrition Labels** / Play **Data Safety**; no third-party ad SDKs, ever.
4. **Prompt-injection hardening** for AI snapshots (closes risk R5) — sanitize/segment user free-text
   before it enters any LLM context.
5. **Audit-log immutability** (append-only enforced; closes part of R9) and patient-facing access logs
   ("who viewed your data").

**Why it wins.** Direct contrast to the incumbents' privacy failures; resonates with both patients and
enterprise buyers (ties to W8).

**Effort/sequence.** Field encryption + audit immutability: **M**. Device hardening: **M** (native).
Prompt hardening: **S**. Sequence: early — it gates enterprise sales and SaMD posture.

---

## W6 — Clinical Validation, Quality & Regulatory Readiness (the credibility gate)

**Thesis.** To *supersede competitors* credibly as SaMD, COPE must close the **verification gap** (risk
R1: ~3% real test coverage vs. "80%" claimed) and the **clinical-threshold gap** (risk R2, OQ-004).
This is the biggest *non-feature* differentiator: defensible, validated, auditable.

**What to build / do.**
1. **Clinical advisory sign-off on every threshold** (RULE-001…008, assessment cutoffs, risk score) with
   documented rationale tied to literature (reliable-change indices for PHQ-9/GAD-7) — *prerequisite to pilot.*
2. **Real automated test suite** — rules-engine unit tests, auth/MFA/refresh integration tests,
   daily-entry→alert E2E, de-identification compliance tests, native UI tests; **measured coverage gate
   in CI** (the CI already runs typecheck + CodeQL + dep-scan; add coverage).
3. **Risk-score validation + bias/fairness review** (FDA DSI/HTI-1 transparency expectations, doc `02` B7).
4. **Regulatory workstream** — formal SaMD classification + HIPAA Security Risk Assessment + (if pursued)
   510(k)/De Novo path with a **Predetermined Change Control Plan** for any AI/ML (doc `02` B4).
5. **Reconcile docs to ground truth** — the DEVLOG "all phases complete / 80% coverage" claims must match
   reality for an FDA-grade quality record.

**Why it wins.** Validated, auditable safety + outcomes is exactly what payers/health-systems buy and
what consumer apps lack.

**Effort/sequence.** Tests + CI gate: **M**, *start immediately*. Clinical sign-off: **M** (external,
long-lead — start now). Regulatory: **L** (parallel track).

---

## W7 — Interoperability & EHR Embedding (kill the swivel-chair, unlock health-system sales)

**Thesis.** COPE already has FHIR R4 read endpoints + OMOP CDM + standard code systems — a real moat.
The next step is **bidirectional, embeddable** interoperability so COPE lives *inside* the EHR, not
beside it. Information-blocking disincentives are live (doc `02` B3); EHR integration is now table stakes.

**What to build.**
1. **SMART on FHIR App Launch v2.2.0** — EHR launch + standalone + **Backend Services** (asymmetric JWT),
   OAuth2/OIDC + PKCE, `.well-known/smart-configuration`, **v2 granular scopes**. Target **Epic
   (`fhir.epic.com` → Showroom/Connection Hub)** and **Oracle Health (CernerCare code Console)**.
2. **Conform to the regulatory floor** — **USCDI v3 / US Core 6.1.0** (advance to STU 9.0.0 via SVAP).
3. **Assessment → FHIR pattern done right** — capture **QuestionnaireResponse** → derive scored
   **Observation** (`category=survey`, LOINC) via HL7 **SDC**. Encode confirmed LOINC (PHQ-9 **44261-6**,
   GAD-7 **70274-6**, C-SSRS **93245-9/93373-9**); **verify ISI/ASRM/WHODAS LOINC** before shipping.
4. **FHIR write + key resources** — extend beyond read-only to `CarePlan` (safety/treatment plans),
   `RiskAssessment` (algorithmic risk), `Communication` (messaging/outreach), `Provenance` (required).
   Track the **US Behavioral Health Profiles IG**.
5. **TEFCA-awareness** — design for QHIN-mediated exchange as it matures (11 QHINs live).

**Why it wins.** Embedding in Epic/Oracle removes the #1 clinician objection (swivel-chair / documentation
burden, doc `02` B2) and is something no consumer competitor can do. It also satisfies info-blocking
expectations for institutional buyers.

**Effort/sequence.** SMART launch + US Core conformance: **L**. FHIR write + resources: **M**. Sequence:
after W1/W6, as the enterprise go-to-market track.

---

## W8 — Enterprise Readiness & the Collaborative-Care Billing Play (the business model)

**Thesis.** The strongest mental-health businesses are B2B (Lyra, Spring). COPE's registry + treat-to-target
dashboard **is literally the infrastructure CoCM/BHI billing requires** (doc `02` B6) — a concrete ROI
story that consumer trackers can't tell. Pair it with the enterprise security ladder to be buyable.

**What to build / do.**
1. **Productize the CoCM registry** — COPE already has the registry, PHQ-9/GAD-7, caseload review, and
   psychiatric-consultant notes. Add: explicit **treat-to-target** tracking (≥50% reduction, plan-change
   prompt at **10–12 weeks**), a **behavioral-health-care-manager** workflow, a **CoCM time log**, and
   billing-ready summaries for **99492/99493/99494/G2214** + BHI **99484**.
2. **RTM support** — model **98975/98978/98980/98981** (the correct family for self-reported behavioral
   data) so practices can bill between-visit monitoring; (DTx pathway **G0552–G0554** only if a module is
   FDA-cleared under 21 CFR 882.5801).
3. **Encode the validated MBC numbers** (doc `02` B1) — PHQ-9 reliable change **5 pts** / remission **<5**;
   GAD-7 MCID **4 pts** / remission **<5**; prefer **Reliable Change Index** over flat 50% for individuals;
   **flag deterioration / not-on-track, not routine entries** (alert-fatigue discipline).
4. **Enterprise security ladder** — **SOC 2 Type II → HITRUST i1/r2**, BAA program, **SAML 2.0 SSO + SCIM
   2.0** provisioning (COPE has OIDC + MFA already; SAML + SCIM are the gaps), US data residency, immutable
   audit logs with anomalous-access alerting, **405(d) HICP** attestation.
5. **Clinical-value validation** — pursue **PHTI / DiMe V3+** evaluation to differentiate with payers.

**Why it wins.** Turns COPE's existing clinical depth into a reimbursable, auditable, enterprise-sellable
product — the durable business model the troubled B2C teletherapy players lack.

**Effort/sequence.** CoCM/RTM productization: **M** (mostly UI + reporting over existing data). SOC 2 →
HITRUST: **L** (long-lead, start early). SAML/SCIM: **M**. Validation: **L** (parallel).

---

## Consolidated Roadmap (sequenced, dependency-aware)

> Effort key: **S** ≈ 1–2 wks · **M** ≈ 1–2 mo · **L** ≈ 3–6 mo · all assume the native build (doc `03`)
> proceeds in parallel. Clinical sign-off (W6) and SOC 2/HITRUST (W8) are **long-lead — start immediately.**

**Horizon 1 — Foundations & credibility (months 0–4)**
- W6 *(start now)*: real test suite + measured-coverage CI gate; clinical advisory engagement for
  threshold sign-off; reconcile docs to ground truth.
- W5: field-level encryption (journals/notes/messages), audit-log immutability, prompt-injection hardening.
- W1 (backend-led): `messages` table + `/messages` + WS `message.created`.
- Native build Phase 1–2 (doc `03`): foundation, auth, daily check-in parity.

**Horizon 2 — The connected loop & engagement (months 3–8, overlapping)**
- W1: secure messaging UI (native + web), structured between-visit check-ins, pre-visit summary, productized escalation.
- W4: one-tap safety surfaces, automated audited escalation, in-app collaborative safety planning.
- W2: forgiving engagement mechanics, personalized notifications, digital-navigator surface, first CBT-I/BA module.
- W3: full native HealthKit/Health Connect; on-device derived features.
- Native build Phases 3–6: full feature parity + widgets/watch quick-log.

**Horizon 3 — Enterprise & interoperability (months 6–14, overlapping)**
- W8: CoCM registry productization + RTM; SAML/SCIM; SOC 2 Type II → HITRUST.
- W7: SMART on FHIR v2.2 launch (Epic/Oracle), US Core conformance, FHIR write + key resources.
- W6: regulatory track — SaMD classification, HIPAA SRA to the Dec-2024 NPRM, PCCP if AI/ML shipped.
- W3: relapse-signal rules (post clinical validation); W2: JITAIs.

**Horizon 4 — Outcomes & scale (12+ months)**
- Clinical-value validation (PHTI/DiMe); outcomes-based pricing story; telehealth video; bipolar-relapse
  early-warning as a flagship, validated differentiator; multi-language + cultural adaptation (dropout lever).

---

## Success Metrics (how we'll know it's working)

| Pillar | Leading metric | Target signal |
|---|---|---|
| Engagement | 30-day retention; weekly active check-in rate | Beat the ~3% real-world benchmark by an order of magnitude in connected-care cohorts |
| Communication | % patients with ≥1 two-way thread/month; clinician response within policy SLA | Majority active; SLA adherence auditable |
| Clinical (MBC) | % at-risk patients surfaced & actioned; time-to-response | Faster response/remission vs. baseline (Guo-style) |
| Safety | Time from SI/safety signal → clinician acknowledgment | Minutes, fully audited; zero AI dead-ends |
| Trust | Privacy incidents; audit completeness | Zero; immutable, patient-visible access logs |
| Enterprise | SOC 2 Type II + HITRUST achieved; EHR live integrations; CoCM-billable orgs | Certifications obtained; ≥1 Epic/Oracle integration; reimbursement demonstrated |
| Quality | Measured test coverage; thresholds clinically signed off | Coverage gate enforced; 100% of clinical thresholds signed off pre-pilot |

---

## What COPE Should NOT Do (anti-goals)
- **No standalone "AI therapist"** — regulatory + ethical risk (doc `02` A8/B4). AI = augmentation only.
- **No PDT-style standalone prescribed-treatment business** as the core model — the reimbursement trap that
  bankrupted Pear (doc `02` A2). Be the connected-care platform; pursue FDA clearance only for specific
  modules where it unlocks reimbursement (G0552–G0554).
- **No guilt-based engagement mechanics** — they backfire for depressed users (doc `02` A1).
- **No interruptive alerts for routine data** — reserve interruption for actionable validated signals (B2).
- **No third-party ad/tracking SDKs, ever** — privacy is a marketed differentiator (W5).
- **No changes to the protected auth system** beyond additive enhancements (project rule).

