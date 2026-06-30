# COPE — Best Practices & Competitive Landscape (2024–2026)

**Document 2 of 5 · Strategy Series**
**Date:** 2026-06-27 · **Author:** Research synthesis (web + PubMed, citations inline)

> The external evidence base for the strategy. Part A covers the **patient side** (engagement,
> efficacy, safety, MBC, communication, UX/equity, competitors, AI). Part B covers the **clinician
> side** (measurement-based care, workflow, interoperability, regulatory, billing, enterprise).
> Part C distills the **native-mobile architecture** evidence used in doc `03`. Every major claim is
> cited. The orienting source is **Torous, Linardon, Goldberg et al., "The evolving field of digital
> mental health," *World Psychiatry* 2025;24(2):156–174** ([DOI](https://doi.org/10.1002/wps.21299) ·
> [PMC12079407](https://pmc.ncbi.nlm.nih.gov/articles/PMC12079407/)).

---

## PART A — Patient-Facing Best Practices

### A1. The engagement problem (real, severe, central)
Clinical trials see up to ~60% fail to complete prescribed modules and ~70% disengage within weeks;
real-world **30-day retention for popular MH apps can be ~3%**, daily-active ~4%
([AJMC](https://www.ajmc.com/view/addressing-uptake-adherence-and-attrition-in-mental-health-apps);
[HCPLive](https://www.hcplive.com/view/mental-health-apps-gain-high-uptake-struggle-adherence-retention)).
"High uptake, poor adherence" is the defining pattern. Engagement correlates with outcomes but only
**modestly** — a 2025 meta-analysis (28 studies) found pooled r = 0.16 (95% CI 0.09–0.21)
([PMC12747297](https://pmc.ncbi.nlm.nih.gov/articles/PMC12747297/)). **Content quality matters more
than screen time.**

**What demonstrably improves retention** (Torous 2025 + reviews):
- **Human support ("supported" > self-guided)** — the most consistent driver of adherence and effect.
- **Digital navigators** — non-clinician helpers who onboard, troubleshoot, and tailor content; raise
  engagement *and* equity ([Springer 10.1007/s41347-025-00569-0](https://link.springer.com/article/10.1007/s41347-025-00569-0)).
  Directly applicable to a clinician-connected app like COPE.
- **Personalized notifications, gamification, peer support, JITAIs** — promising.

**Notifications & streaks — nuance, not "more is better."** Personalized, context-aware nudges help
short-term, but frequent alerts cause fatigue and can *inhibit* intrinsic habit formation
([habit RCT](https://journals.kmanpub.com/index.php/aitechbesosci/article/view/4724);
[microrandomized work, PMC6293241](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6293241/)). **Streaks
build habit but create guilt/pressure that backfires for depressed users** → favor *forgiving* streaks
(freeze days, miss-tolerant), self-scheduled reminders, and progress framing over loss-aversion.

### A2. Evidence-based modules to embed (not a standalone AI therapist)
- **Digital CBT-I (sleep) is the strongest single bet** and a leading indicator for both depression and
  bipolar relapse: moderate QoL effect (SMD 0.47), equivalent to face-to-face (Alimoradi 2022,
  [10.1016/j.smrv.2022.101646](https://doi.org/10.1016/j.smrv.2022.101646)); durable 12-month gains in a
  2025 RCT ([10.1038/s41746-025-01847-0](https://doi.org/10.1038/s41746-025-01847-0)).
- **Behavioral activation** translates well to mobile, low friction; 2025 review
  ([PMC12227033](https://pmc.ncbi.nlm.nih.gov/articles/PMC12227033/)); 2024 BA-app RCT large effect
  (d≈1.03, [10.3390/bs15111496](https://doi.org/10.3390/bs15111496)).
- **JITAIs / EMIs** (in-the-moment, context-triggered micro-interventions): 2025 meta-analysis g=0.15,
  durable to 6 months ([BMJ Ment Health 10.1136/bmjment-2025-301641](https://doi.org/10.1136/bmjment-2025-301641));
  also an equity lever ([Annu Rev Public Health 10.1146/annurev-publhealth-071723-103909](https://doi.org/10.1146/annurev-publhealth-071723-103909)).

**The PDT/FDA market is a cautionary tale.** *Rejoyn* (Otsuka/Click) became the **first FDA-cleared PDT
for MDD (Apr 2024)** but with **modest** effect (MADRS −8.78 vs −6.66) ([FDA Roundup](https://www.fda.gov/news-events/press-announcements/fda-roundup-april-2-2024)).
*Pear Therapeutics* (reSET/Somryst) **went bankrupt in 2023** over reimbursement failure
([Psychiatry Advisor](https://www.psychiatryadvisor.com/features/prescription-digital-therapeutics/)).
**Takeaway:** a *clinician-connected monitoring/wellness* product (not a standalone prescribed
treatment) embeds the same evidence-based modules while avoiding the reimbursement trap that killed Pear.

### A3. Safety: suicide risk, crisis, guardrails
- **Stanley-Brown Safety Planning Intervention** is the evidence-based standard, moving to smartphone
  format ([SPRC](https://sprc.org/resources/stanley-brown-safety-plan/)). The plan must be **instantly
  accessible in crisis**, support **regular review**, and ideally get consent to involve support people.
  *COPE already implements this (migration 013) — a real asset.*
- **988** is the integration point (17.7M+ contacts since July 2022); hardcode **988 (call/text/chat)** +
  **Crisis Text Line 741741** as one-tap, always-visible actions (COPE already does in `@cope/shared`).
- **C-SSRS digital screens have limited predictive accuracy** (AUC ~0.62–0.65) and false positives carry
  real harms ([PMC9811343](https://pmc.ncbi.nlm.nih.gov/articles/PMC9811343/)). Treat a positive as a
  **trigger for safety planning + human escalation**, never standalone risk stratification.

### A4. Measurement-based care from the patient side
- **MBC works and patients accept digital PROMs.** Remote-IOP MBC correlated with PHQ-9/GAD-7/WHO-5
  improvement (n=405; [JMIR Form Res 2024](https://formative.jmir.org/2024/1/e58994)); app PROM capture
  matched paper and was *preferred* (87% easier than visits; [PMC8054360](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8054360/)).
  This **directly validates COPE's daily-entry + assessment model.**
- **EMA + passive sensing / digital phenotyping** is the frontier: passive signals (mobility, screen-on,
  actigraphy/sleep) track affect; **bidirectional mobility↔mood links** matter for bipolar
  ([PMC11662189](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11662189/)). Correlations are **modest** —
  best for relapse-signal, not diagnosis. Two constraints: **EMA reactivity** (asking about mood changes
  it → keep prompts brief/sparse) and **privacy** (granular, revocable consent; on-device where possible).

### A5. Patient↔clinician communication & between-visit monitoring (COPE's wedge)
- Secure messaging + on-demand data sharing + progress tools improve attendance and follow-through
  ([iCANotes 2025](https://www.icanotes.com/2025/07/24/best-mental-health-patient-portal-features-in-2025/)).
- **Tech-enabled collaborative care beats usual care** — 2024 multisite RCT (*Lancet Digital Health*)
  via real-time data + escalation pathways. The winning 2026 model is **hybrid**: async messaging +
  video + in-person escalation in one pathway ([Validic 2026](https://validic.com/blog/2026-digital-health-trends--5-shifts-shaping-connected-care/)).
- **Shared decision-making** via secure async + pre-visit symptom capture is validated but
  under-implemented ([JMIR 2024](https://www.jmir.org/2024/1/e55753)). Patients expect responsiveness +
  control over what's shared. *COPE's journal-sharing + alert-feed architecture is well-aligned; the
  missing piece is the **messaging + trustworthy escalation loop**.*

### A6. UX, accessibility, equity
- **Trauma-informed design** beyond WCAG: reduce cognitive load (fewer options, plain language), give
  **control and predictability**, be transparent, avoid clinical/aggressive tone ([Sage/PMC12304634](https://pmc.ncbi.nlm.nih.gov/articles/PMC12304634/)).
- **Cognitive load for depressed users is a first-order constraint** → progressive disclosure, Daylio-low
  friction check-ins, forgiving flows.
- **Cultural/linguistic adaptation pays off measurably**: deep participatory adaptation associated with
  **dropout <11% and adherence >75%** vs. median ~18% attrition in less-adapted tools
  ([JMIR Ment Health/PMC12850045](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12850045/)).

### A7. Competitive landscape & the exploitable gap
Market went pandemic-boom → "post-hype reality" shakeout
([Second Opinion](https://secondopinion.media/p/behavioral-health-pandemic-boom-to-post-hype-reality)).

| Segment | Players | Strength | Weakness COPE exploits |
|---|---|---|---|
| Meditation/wellness (B2C/employer) | Headspace (70M+; "Therapy by Headspace" 2025), Calm/Calm Health | Content, brand | No clinical depth, no clinician connection |
| Employer/payer clinical (B2B) | Lyra (AI matching, **outcomes-based pricing**, ~$340/member savings), Spring Health, Brightside | Outcomes infra, payer integration | Employer-gated; thin daily patient-side tracking/journaling |
| Teletherapy (B2C, troubled) | BetterHelp (declining; **$7.8M FTC** data-sharing settlement), Talkspace, Cerebral | Scale, access | **Distrusted on privacy** sector-wide |
| Mood trackers (B2C, nearest analog) | Daylio (habit/simplicity), Bearable (correlations), **eMoods (bipolar gold standard)**, Sanvello, Wysa | Great UX/data depth | **Islands — no care-team link, no MBC loop, no safety escalation** |

**The wedge:** a polished, trauma-informed daily tracker that (a) feeds validated PROMs into a
**clinician dashboard with alerting**, (b) closes the **between-visit monitoring + secure-messaging
loop**, (c) bakes in **safety planning + 988**, (d) wins on **privacy/HIPAA transparency** against the
FTC-scarred field, and (e) **owns the bipolar niche** (eMoods leads tracking but connects to no one).

### A8. AI in mental health apps (2025–2026): heavy scrutiny
- **The reckoning:** APA warned federal regulators (Feb 2025) about AI chatbots posing as therapists,
  esp. **sycophancy** ([APA](https://www.apaservices.org/practice/business/technology/artificial-intelligence-chatbots-therapists));
  Character.AI faces wrongful-death suits; **Woebot shut its CBT chatbot June 30 2025**
  ([telehealth.org](https://telehealth.org/news/ai-psychotherapy-shutdown-what-woebots-exit-signals-for-clinicians/)).
- **FDA stance (Nov 2025):** 1,200+ AI devices authorized, **zero for mental health**; the **Digital
  Health Advisory Committee (Nov 6 2025)** signaled a **risk-based, total-product-lifecycle** framework —
  inclusive premarket evidence, **equitable performance across populations/languages, built-in human
  escalation, misuse controls, explainability, postmarket drift/bias/hallucination/sycophancy monitoring**
  ([FDA DHAC](https://www.fda.gov/medical-devices/digital-health-center-excellence/fda-digital-health-advisory-committee)).
- **Recommendations for COPE:** (1) **No open-ended "AI therapist."** Use LLMs for *augmentation* —
  journaling reflection, clinician-facing summarization, draft (clinician-reviewed) check-ins, content
  personalization. (2) Keep AI **rule-bounded** on anything clinical. (3) Mandatory **crisis-detection →
  human escalation** (never an AI dead-end). (4) Be transparent it's AI. (5) Guard against sycophancy.
  *COPE's existing BAA-gated, consent-checked, rule-fallback pattern is already a defensible posture.*

---

## PART B — Clinician-Facing Best Practices, Interoperability & Regulatory

> **Currency flags (these changed the landscape recently):** FDA **reissued** the CDS + General Wellness
> guidances **Jan 6, 2026**; most of **HTI-2 was withdrawn Dec 29, 2025**; the **Continuing
> Appropriations Act, 2026** (Feb 3, 2026) extended Medicare telehealth flexibilities through **Dec 31,
> 2027**; CMS added **2026 RPM/RTM** short-duration codes and (Jan 2025) **Digital Mental Health
> Treatment** codes **G0552–G0554**.

### B1. Measurement-based care (MBC) — strong but fidelity-dependent
- **Evidence:** Guo 2015 (*Am J Psychiatry*, N=120): MBC vs standard care **remission 73.8% vs 28.8%**,
  response 86.9% vs 62.7%, faster time-to-response ([PMID 26315978](https://pubmed.ncbi.nlm.nih.gov/26315978/)).
  But effect is **fidelity-dependent**; "just collecting scores" is non-significant
  ([JCP](https://www.psychiatrist.com/jcp/measurement-based-care-depression/)). The robust signal is the
  **feedback-system** literature: de Jong 2021 (58 studies; g≈0.14–0.15, larger for "Not-On-Track,"
  ~20% dropout reduction); Rognstad 2022 (**d=0.14 overall, d=0.29 for at-risk**); Lambert's OQ work —
  feedback **more than doubled** positive outcomes for at-risk cases (22.3%→55.5%, [PMID 26641368](https://pubmed.ncbi.nlm.nih.gov/26641368/)).
- **Design implication:** the *clinician-facing* panel captures most of the benefit; **prioritize
  surfacing deterioration / not-on-track patients.** COPE's nightly snapshots + risk history already
  compute this.
- **Validated numbers to encode (use exactly):**

  | | PHQ-9 (0–27) | GAD-7 (0–21) |
  |---|---|---|
  | Severity bands | 5/10/15/20 | 5/10/15 |
  | **Reliable change / MCID** | **5 points** | **4 points** |
  | Response | ≥50% reduction | ≥50% reduction |
  | **Remission** | **< 5** | **< 5** |

  Prefer the **Reliable Change Index** over a flat 50% rule for individual monitoring
  (Kroenke 2001; Löwe 2004 [PMID 15550799](https://pubmed.ncbi.nlm.nih.gov/15550799/); Spitzer/Löwe 2006).
- **Why adoption is low:** time/workflow/administrative burden + poor EHR integration; telehealth broke
  the "share-the-paper-measure" workflow ([PMC10923014](https://pmc.ncbi.nlm.nih.gov/articles/PMC10923014/)).
  Facilitators: training, **clinic champions**, EHR/feedback-system integration.

### B2. Clinical workflow & dashboards
- **The CoCM registry is the canon** (UW AIMS Center): track outcomes at **patient and caseload** level,
  summarize vs a **treat-to-target** goal, and enable **Systematic Caseload Review** prioritizing patients
  **not improving / new / complex** ([AIMS](https://aims.uw.edu/registries-for-collaborative-care/)).
  Treat-to-target: aim ≥50% reduction, re-measure each contact, **change plan at 10–12 weeks** if not
  improving ([AIMS T2T](https://aims.uw.edu/measurement-based-treatment-to-target/)).
- **Documentation burden is the clinician's lived reality:** ~2 hrs EHR work per 1 hr care (Sinsky 2016,
  [10.7326/M16-0961](https://www.acpjournals.org/doi/10.7326/M16-0961)); 5.9/11.4 workday hours in the EHR
  (Arndt 2017). **Ambient AI scribes** cut burnout 51.9%→38.8% in 30 days (*JAMA Netw Open* 2025,
  [PMC12492056](https://pmc.ncbi.nlm.nih.gov/articles/PMC12492056/)) — but with occasional clinically
  significant inaccuracies.
- **Dashboard design evidence:** clinicians rank **easy navigation, trend/history, simplicity, clarity**
  top; "AI predictive analytics" ranked **13th** ([PMC11618005](https://pmc.ncbi.nlm.nih.gov/articles/PMC11618005/)).
  EHR usability is famously bad (SUS 45.9, an "F"; each +1 SUS pt = 3% lower burnout odds, Melnick 2020).
  **Clarity and trend history beat AI sophistication.**
- **Alert fatigue is the central CDS risk:** clinicians override **49–96%** of interruptive alerts.
  Levers: **tier by severity, route by role**, non-interruptive by default, mine override reasons, kill
  alerts never acted on ("Getting Rid of Stupid Stuff," *NEJM* 2018). **Reserve interruption for
  genuinely actionable, validated signals** (C-SSRS-positive, reliable deterioration) — never routine entry.

### B3. Interoperability (FHIR / SMART / ONC / CMS)
- **FHIR R4 (4.0.1) is locked for US regulation**; current **US Core = STU 9.0.0**, but the **2026
  regulatory floor is USCDI v3 / US Core 6.1.0** (HTI-1); Cures API criterion is **§170.315(g)(10)**.
- **SMART App Launch v2.2.0** for EHR embedding: EHR launch + standalone + **Backend Services** (asymmetric
  JWT), OAuth2/OIDC + **PKCE**, `.well-known/smart-configuration`, **v2 granular scopes**.
- **Information-blocking disincentives are LIVE** (effective Jul 31, 2024): clinicians risk a **zero MIPS
  Promoting Interoperability score**; ONC publicly posts violators.
- **TEFCA** live with **11 QHINs** (Epic Nexus, eHealth Exchange, Health Gorilla, Oracle HIN…).
- **HTI-1 DSI** (live since Jan 1, 2025): certified IT must surface **31 source attributes for Predictive
  DSIs** + Intervention Risk Management — the de-facto **"model card"** buyers will expect (see B7).
  **HTI-2 was largely withdrawn Dec 29, 2025** — do not build to its withdrawn proposals.
- **Behavioral-health FHIR pattern:** capture **QuestionnaireResponse** (US Core) → derive scored
  **Observation** (`category=survey`, LOINC) via HL7 **SDC** extraction. Confirmed LOINC: **PHQ-9 total
  44261-6**, **GAD-7 total 70274-6**, **C-SSRS 93245-9 / screener 93373-9**. ⚠️ **ISI/ASRM/WHODAS LOINC not
  authoritatively pinned — verify at loinc.org.** Use **CarePlan** (safety plans), **RiskAssessment**
  (algorithmic risk), **Communication** (messaging), **Provenance** (required for exchange). Watch the
  **US Behavioral Health Profiles IG** (HL7/SAMHSA/ASTP).
- **Epic/Oracle practical path:** Epic via `fhir.epic.com` → sandbox → prod → Showroom/Connection Hub;
  Oracle via CernerCare code Console; both require OAuth2/OIDC + PKCE + US Core mapping; **per-site
  provisioning** (apps don't auto-activate across health systems).

### B4. Regulatory (FDA SaMD + HIPAA)
- **The CDS device line is COPE's central risk.** Software is *Non-Device CDS* only if it meets all four
  **§520(o)(1)(E)** criteria. The **reissued Jan 6, 2026 CDS guidance** ([PDF](https://www.fda.gov/media/191560/download))
  folds time-critical analysis into an **automation-bias** test. **What makes COPE a regulated Class II
  device:** time-critical **near-term risk alerts** the clinician must act on immediately (urgent
  suicide-risk alarm), black-box recommendations, and **compressed-timeframe risk prediction** —
  enforcement discretion is **explicitly withdrawn for predictions over a "compressed timeframe" (FDA's
  example: next 24 hours)**, which re-captures high-acuity suicide alerting. **Net:** a transparent
  dashboard of scores/trends/guidelines is likely Non-Device CDS; **time-critical near-term suicide alerts
  are the single feature most likely to trigger Class II** — exactly what COPE's own rules flag for
  clinical sign-off before pilot.
- **Class II pathway:** **21 CFR 882.5801** "Computerized behavioral therapy device," **Class II, Rx-only,
  product code PWE.** Cleared examples: reSET/Somryst, **Rejoyn** (De Novo 2024), Daylight, NightWare,
  Freespira. ~62% via 510(k), ~38% De Novo.
- **PCCP for AI/ML:** FDA **final guidance Dec 4, 2024** — Description of Modifications + Modification
  Protocol + Impact Assessment ([media/166704](https://www.fda.gov/media/166704/download)); + Jan 7, 2025
  draft AI lifecycle guidance. **No generative-AI mental-health device is FDA-authorized to date**
  (DHAC Nov 6, 2025 stressed human oversight, crisis escalation, hallucination/sycophancy/drift).
- **HIPAA:** audit controls are **already REQUIRED** (45 CFR 164.312(b)). The **Dec 27, 2024 Security Rule
  NPRM** (still proposed) would make nearly everything **required** (remove "addressable"), **mandate MFA**
  and **encryption at rest + in transit**, require asset inventory/network map, **6-month vuln scans +
  annual pen tests**, 72-hr restoration. **Build to the NPRM now.** BAAs required with **every** CSP
  touching PHI — even encrypted "no-view" hosting — and flow down to subcontractors.

### B5. Communication & telehealth policy
- **Behavioral-health telehealth is the most stable regime — PERMANENT:** no geographic restriction,
  **patient's home is a permanent originating site, audio-only permanently allowed.** The only catch: the
  **in-person requirement is waived through Dec 31, 2027** (returns Jan 1, 2028 unless Congress acts).
- **Secure messaging:** OCR's COVID enforcement discretion **ended May 2023** — full HIPAA + **BAA
  mandatory** with any vendor touching PHI. Best practice: transport/at-rest encryption, audit logs,
  strong auth, closed-system design; async vs sync per APA/ATA.
- **Billing message time:** online digital E/M **99421/99422/99423** (physicians) and **98970/98971/98972**
  (therapists), patient-initiated, established patient, 7-day rolling window; virtual check-in **98016**.
  **No federally mandated response-time SLA** — SLAs are organizational policy.

### B6. Collaborative & stepped care (COPE's enterprise wedge)
- **CoCM (IMPACT) is the most evidence-based model:** Unützer 2002 (*JAMA*, N=1,801) **45% vs 19%** achieved
  ≥50% reduction at 12 months (OR 3.45) ([PMID 12472325](https://pubmed.ncbi.nlm.nih.gov/12472325/));
  **>90 RCTs** support CoCM. Five principles: team-based, **population/registry-based**, **measurement-based
  treat-to-target**, evidence-based, accountable.
- **The billing maps onto COPE's architecture:** CoCM **99492/99493/99494/G2214**, BHI **99484**. CMS's six
  required elements — treating-provider order, **behavioral health care manager**, **psychiatric
  consultant**, a **registry with ≥1 validated measure (PHQ-9/GAD-7)**, time log, no duplicate E/M — are
  *literally COPE's feature set*. **A registry + treat-to-target dashboard is the product CoCM billing
  requires.** (Note: RHC/FQHC **G0511 ended Sept 30, 2025** → individual codes + new **G0568/G0569/G0570**.)
- **RTM is the right family for a self-report behavioral app** (allows non-physiologic self-reported data,
  therapist-billable): **98975** (setup), **98978** (monitoring supply), **98980/98981** (20-min mgmt) +
  new 2026 short-duration codes. RPM requires auto device-uploaded *physiologic* data. FDA-cleared DTx
  uses the dedicated **G0552–G0554** pathway (requires 21 CFR 882.5801 clearance).

### B7. Clinical decision support & suicide-risk prediction
- **State of the art:** MHRN/Kaiser (Simon/Coley) 90-day models prompt C-SSRS at predicted risk ≥~3%;
  VA **REACH VET** flags top ~0.1% — a 2025 *JAMA Netw Open* eval found fewer attempts/admissions **but no
  reduction in suicide mortality**.
- **Pitfalls:** Belsher 2019 (*JAMA Psychiatry*): good AUC but **PPV ≤0.01** — at base rates, ~58 true
  positives vs ~49,942 false positives ([PMID 30865249](https://pubmed.ncbi.nlm.nih.gov/30865249/)). A
  2025 *BMC Medicine* review of 167 models found calibration assessed in only 9% and **all developed
  models at high risk of bias**. **Bias is documented:** Coley 2021 — suicide models performed **poorly
  for Black and AI/AN patients** ([PMC8082428](https://pmc.ncbi.nlm.nih.gov/articles/PMC8082428/)).
- **Responsible presentation:** risk is a **flag that prompts assessment, never a verdict**; trigger safety
  planning at any level; surface 988 + 741741; show limitations/fairness caveats inline; log clinician
  acknowledgment; calibrate thresholds to limit false positives; **publish an HTI-1-style 31-attribute
  "model card" + Intervention Risk Management** voluntarily — both ethical and procurement-winning.

### B8. Enterprise readiness (what health systems/payers require to buy)
- **Security/compliance ladder:** **SOC 2 Type II** (table stakes, not HIPAA-specific) → **HITRUST CSF v11**
  (healthcare-specific; tiers e1→i1→**r2** gold standard; has a 2024 AI Security add-on) → **BAA** (legally
  required; encryption, MFA, RBAC, immutable audit logs, breach notification, subcontractor flow-down).
- **Enterprise identity:** **SAML 2.0 SSO** + **OIDC/OAuth2** + **SCIM 2.0** provisioning (≈mandatory at
  1000+ seats), multi-tenant isolation, MFA, audit logging. Buyers screen via **Shared Assessments SIG /
  VSA**. *COPE already has OIDC (Authentik) + MFA — SAML + SCIM are the gaps.*
- **Encryption** TLS 1.2+/1.3 + AES-256; **immutable audit logs** with anomalous-access alerting; **US data
  residency** often required. **HHS 405(d) HICP** attestation can mitigate OCR penalties (safe harbor).
- **Clinical-value validation** (payer differentiator): **PHTI** (Peterson/ICER framework), **DiMe V3+**,
  **ATA accreditation**.

> **Verify before implementation:** LOINC for ISI/ASRM/WHODAS; exact US Core must-support lists for your
> cert version; current QHIN roster; and whether the HIPAA Security Rule NPRM has been finalized.

---

## PART C — Native-Mobile Architecture Evidence (2025–2026)

> Condensed evidence base for the native build (full detail + stack table in doc `03`). Apple/Google
> docs are JS-rendered; version specifics flagged "verify" should be re-confirmed at implementation time.

- **iOS:** **SwiftUI-first** (Apple's strategic direction; UIKit escape hatch only for pathological
  media-heavy lists). **MVVM-lite with the Observation framework (`@Observable`, iOS 17+)** — cuts 30–50%
  of Combine boilerplate; reserve **TCA** for the multi-step assessment + safety-plan state machines.
  **Swift 6.2 strict concurrency + "Approachable Concurrency"** (default `@MainActor` isolation on).
  Native **URLSession** async/await (not Alamofire — fewer deps for a HIPAA audit). Local SPM-package
  modularization.
- **iOS data/offline:** **Avoid SwiftData for the sync layer** (slower, no FTS, CloudKit-only sync,
  iOS-26 migration regressions). Use **GRDB.swift** (FTS5 for journal search, **SQLCipher** AES-256) via
  Point-Free's **SQLiteData** wrapper. **Evaluate PowerSync** (bi-directional Postgres↔SQLite, Swift SDK,
  Sync Rules that map onto COPE's RLS; *HIPAA/SOC 2 claimed Jan 2026 — verify*).
- **Android:** **Jetpack Compose is the unambiguous default** (Google's "Compose First," May 2026; scroll
  parity reached Dec 2025; M3 1.4 `SecureTextField` for PHI). Google's **layered + UDF** architecture,
  ViewModel + **StateFlow** + `collectAsStateWithLifecycle()`, put scoring/thresholds in **domain use
  cases**. **Hilt + KSP** DI; **Retrofit + OkHttp + kotlinx.serialization**; **Navigation 3** (stable Nov
  2025); Now-in-Android modularization.
- **Android data/offline:** **Room 2.8 + KSP** (keep DAOs `suspend`/`Flow` for the Room 3.0 KMP rewrite),
  **WorkManager** for sync (expedited work for crisis assessments), **Proto DataStore** for non-PHI config.
  ⚠️ **Jetpack Security Crypto is DEPRECATED (2025)** — use **SQLCipher (`sqlcipher-android` 4.6+ with
  `SupportOpenHelperFactory`)** + **Google Tink**, keys in **Keystore/StrongBox**.
- **Health platforms:** **HealthKit** now has **State of Mind** (`HKStateOfMind`, valence/labels) and
  **native PHQ-9/GAD-7 types** (huge for COPE), plus sleep stages, **HRV (SDNN)**, mindful minutes,
  mobility; background via `HKObserverQuery` + `enableBackgroundDelivery`. **Health Connect 1.1** (stable
  Nov 2025) has **MindfulnessSessionRecord**, **HRV (RMSSD)**, sleep/steps/HR — but **no mood/valence
  equivalent** (build your own). **SensorKit is research/IRB-only** — for commercial passive sensing use
  HealthKit + CoreMotion (+ consented CoreLocation) / Health Connect + Activity Recognition, processing
  **derived features on-device**.
- **Security (HIPAA/MASVS):** Keychain/Keystore + Secure Enclave/StrongBox; **biometrics bound to a
  crypto operation** (not presence-only); AES-256 at rest; cert/SPKI pinning; **Play Integrity** /
  best-effort jailbreak detection (gate sensitive actions, server-verified); **`FLAG_SECURE`** + app-switcher
  blur to hide PHI; **auto-logoff ~2–5 min**; **no PHI in logs/payloads/analytics**; no hardcoded secrets
  (proxy 3rd-party keys via backend). Target **OWASP MASVS L2 + R**.
- **Push/background:** APNs **`.timeSensitive`** for reminders, **`.critical`** (Apple-reviewed entitlement)
  for clinically-validated crisis only; FCM **HTTP v1 data-only** + channels (`crisis_alerts` HIGH).
  **Never put PHI in a payload/banner.** **Quick-log surfaces:** WidgetKit interactive widgets + Control
  Center + Siri + watch complication (iOS); **Glance** widget + **Wear Tile** (Android) — one shared
  `LogMood` intent.
- **Accessibility/release:** WCAG **2.2 AA** incl. **3.3.8 Accessible Authentication** (allow paste +
  biometric — *interacts with COPE's forced-password-change modal*), **3.2.6 Consistent Help** (fixed 988
  placement). Apple **Accessibility Nutrition Labels** + **in-app account deletion**; Google Play
  **Medical Device labeling** + **org-account** + health declaration (relevant to SaMD posture).
- **Shared strategy (KMP):** **KMP shared `commonMain` core + fully native SwiftUI/Compose UIs**; skip
  Compose Multiplatform for v1. Share the **clinical assessment scoring** (divergence = patient-safety
  bug), validation, networking (Ktor), and the offline DB/sync engine (SQLDelight). **SKIE** for Swift
  interop. Use **OpenAPI Generator** off the Fastify spec to keep TS/Swift/Kotlin DTOs in sync (codegen
  shares *shapes*; KMP shares *behavior*).

> Bottom line: a **KMP-shared-core + native-UI** architecture, GRDB/Room + SQLCipher offline, deep
> HealthKit/Health Connect integration, crisis-grade native notifications, and quick-log widgets — built
> to MASVS L2+R and WCAG 2.2 AA — is the technical foundation for a best-in-class, defensible app.
