# COPE Web UI — Typography & Iconography Remediation Plan

**Status:** Phases 0–2 + 4 shipped · Phase 3 pending · **Owner:** design system · **Created:** 2026-06-21
**North stars:** Medgnosis (`apps/web`, lucide-react + Tailwind tokens), MediCosts (`client/`, icon factory + CSS tokens)

---

## 1. Diagnosis (evidence-backed)

COPE's documented design system (`design/DESIGN_SYSTEM.md`) is sound, but the
rendered code diverged from it. The "incorrectly sized icons and fonts" trace to
five measurable root causes (counts captured 2026-06-21 from `apps/web/src`):

### #1 — No icon system; icons are emoji
- **102 emoji glyphs** used as icons across 13 files (`PatientDetailPage` 34,
  `DashboardPage` 16, `AppShell` 11, …).
- The whole sidebar nav is emoji: `<NavItem icon="🌐" …/>` etc. (`AppShell.tsx:256-326`).
- Only **15 ad-hoc SVGs**, inconsistently sized (`width="18" height="11"`,
  `width="20" height="16"` — non-square).
- Emoji size = parent `font-size`, render differently per OS, carry built-in
  padding/baseline offsets → inconsistent size + misalignment everywhere.
- **Clinical mood is encoded by emoji** (😊😴😟, `DashboardPage.tsx:257-260`) —
  meaning by hue/glyph alone; a readability + clinical-safety issue for a
  Class II SaMD.

### #2 — 491 inline `fontSize:` numbers bypass the scale
- **491** `style={{ fontSize: N }}` in `.tsx`. Distribution: 12(141×), 13(127×),
  11(109×), 14(30×), 10(22×), 9(3×), plus one-offs 15→48.
- **25 are below the documented 12px floor** (`9`, `10`).

### #3 — Two competing token vocabularies
- Documented: `--text-primary / --surface-base`. Inline styles use a legacy
  `--ink-*` vocab: `--ink-soft`(105×), `--ink-mid`(82×), `--ink`(82×),
  `--ink-ghost`(11×) = **280 refs**. Only resolves because `compat.css:102`
  aliases `--ink → --text-primary`.

### #4 — Hardcoded px in CSS, including sub-floor sizes
- **37** hardcoded `font-size:…px` in CSS. `navigation.css` & `badges.css` ship
  `10px`; `login.css` is entirely off-scale (`44/32/28/15/13/12/11px`).

### #5 — Dead / duplicate stylesheets
- `theme.css` is dead (never imported); `theme-legacy-backup.css` is loaded only
  under `VITE_USE_LEGACY_THEME`; both duplicate `.empty-state-icon` etc. →
  cascade ambiguity, three sources of truth.

**Conclusion:** spec is fine, enforcement is absent.

---

## 2. North-star principles

| Concern | Medgnosis | MediCosts |
|---|---|---|
| Icons | `lucide-react`, `size={px}` prop, `svg.lucide{}` | icon factory: 20×20, stroke 1.8, `currentColor` |
| Sizes | badges 11 · nav 20 · dropdown 14 · inputs 16–17 | nav 20 · topbar 14 · menu 15 · chevron 12 |
| Type | one token scale + `tabular-nums` for data | one `:root` block, explicit per-context, no inline numbers |
| Meaning | **"colour = signal, never decoration"**; severity = icon **+** label; decorative → `aria-hidden` | semantic domain colour tokens |
| Truth | one `tokens-*.css` + one config | one `index.css :root` |

Throughline: **one token scale, one icon component with a fixed size vocabulary,
icons inherit `currentColor`, meaning never carried by glyph/hue alone.**

---

## 3. Target system

- **Icons:** adopt `lucide-react` (matches Medgnosis). `<Icon>` primitive
  enforces a fixed size vocabulary; `svg.lucide { flex-shrink: 0 }`.
  - Sizes: `xs`12 · `sm`14 · `md`16 · `lg`20 · `xl`24 · `2xl`32. Stroke 1.5
    default, 2 active.
  - **Decision (deviation from Medgnosis):** size is explicit via the `size`
    prop, *not* `svg.lucide{width:1em}`. The whole point of this remediation is
    deterministic sizing; implicit `1em` sizing is what emoji already did wrong.
  - Mood → `<MoodGlyph value={1..10}>` = colour dot + number + label, never an
    emoji.
- **Typography:** keep the rem-based `--text-*` scale; add `.text-xs…4xl`
  utility classes so inline `fontSize` numbers can be deleted. Enforce the 12px
  floor (sub-12 → `--text-sm`, except uppercase letter-spaced labels → `--text-xs`).
- **Tokens:** new vocab is canonical; `compat.css` stays as a read-only bridge;
  migrate `--ink-*` as files are touched. Delete `theme.css`; retire the
  `VITE_USE_LEGACY_THEME` backup.

---

## 4. Phases

### Phase 0 — Foundation (no visual change) ← **current**
- [x] `lucide-react` installed in `@cope/web`
- [x] `src/components/ui/Icon.tsx` (size vocabulary + ARIA)
- [x] `src/components/ui/MoodGlyph.tsx`
- [x] `main.css`: `.text-*` utilities, `svg.lucide{flex-shrink}`, `.mood-glyph`
- [x] `DESIGN_SYSTEM.md` → v3.0 (icon table, stroke rules, colour=signal,
      inline-style ban, 12px floor)
- Verify: `tsc --noEmit` + `vite build` green.

### Phase 1 — Icon migration (kills the emoji) ✅ SHIPPED & DEPLOYED
Replace 102 emoji + 15 ad-hoc SVGs with `<Icon>`/lucide, file by file:
1. `AppShell.tsx` nav (highest visibility): 🌐→`Globe`, 👥→`Users`, 🔔→`Bell`,
   📈→`TrendingUp`, 📄→`FileText`, 🔬→`Microscope`, ⚙️→`Settings`, 🔍→`Search`,
   ➕→`Plus`, ✏→`PenLine` (all `size="lg"`).
2. `DashboardPage.tsx` + `MoodGlyph`; severity 🚨/⚠️/ℹ️ → `AlertTriangle/AlertCircle/Info`.
3. `PatientDetailPage` (34), then `Reports`, `Patients`, `Admin`, `Alerts`,
   `GlobalSearch`, modals.
- Verify per file: build green + Playwright screenshot diff reviewed.

### Phase 2 — Typography normalization ✅ SHIPPED & DEPLOYED
- **2a** (CSS): six `10px` floor violators (badges/nav) → `var(--text-xs)`;
  all 15 off-scale `login.css` sizes → tokens.
- **2b** (inline): all **472** inline `style={{ fontSize: <number> }}` →
  `fontSize: 'var(--text-*)'` via the floor-honoring map
  (9/10/11/12→sm, 13/14→base, 15→md, 16→lg, 17/18→xl, 20/22/24→2xl,
  26/28→3xl, 48→5xl). Sub-12px text raised to the 12px floor (mostly +1px).
- Verified: zero numeric inline `fontSize`, zero raw px text font-sizes in
  components/pages (only `*-icon` glyph-size rules remain); tsc/eslint/build green.
- Note: used `var(--text-*)` on the existing inline styles (lowest-risk) rather
  than extracting `.text-*` classes; the `--ink-*` colour vocabulary is Phase 3.

### Phase 3 — Token unification & dead-CSS removal
- Migrate inline `--ink-*` → classes/new vocab; shrink `compat.css` to a shim.
- Delete `theme.css`; retire `theme-legacy-backup.css` + the env flag.

### Phase 4 — Enforcement (no regression) ✅ SHIPPED
- `scripts/check-readability.sh` — fails on numeric inline `fontSize`,
  pictographic emoji in `.tsx`, or raw px font-size for text in CSS
  (`*-icon` glyph rules exempt). Wired into the CI `lint` job and exposed as
  `npm run check:readability`.
- ESLint (`apps/web`): `no-restricted-syntax` bans numeric `fontSize` literals
  in inline styles (mobile RN exempt).
- _Deferred:_ Playwright `e2e/theme/` visual-regression baselines (needs a
  running stack + seeded auth) — tracked as a follow-up.

---

## 5. Risk & sequencing
- Bulk work is mechanical (icon swaps, fontSize→class) — low logic risk.
- Main risk = visual drift during icon swap → mitigated by the existing
  Playwright screenshot suite + per-file commits on `main` (no long-lived
  worktree).
- Phases 1–2 deliver ~90% of perceived improvement; 3–4 are durability.

## Scope
This plan covers `apps/web` (clinician dashboard). `apps/mobile` (Expo) is a
separate styling stack and gets an equivalent audit as a follow-up track.
