# COPE Codebase Remediation Plan

Created: 2026-06-13

## Goal

Bring the codebase back into alignment with its database schema, reduce auth and compliance risk, and add guardrails so future schema drift is caught by CI before it reaches runtime paths.

## Guiding Principles

- Prefer narrow, behavior-preserving repairs before broad redesign.
- Treat the SQL schema as the source of truth until generated DB types are introduced.
- Keep API DTO names stable for clients where possible; alias explicitly at SQL boundaries.
- Add tests around repaired behavior before or alongside any larger refactor.
- Avoid compliance claims in product copy unless they are backed by current legal and operational evidence.

## Phase 0 - Current Baseline

- [x] Run `npm run typecheck`.
- [x] Run `npm run test`.
- [x] Run `npm run build`.
- [x] Run `npm run lint`.
- [x] Run `npm audit --audit-level=high`.
- [x] Identify the highest-risk stale SQL references.

Known baseline:

- Typecheck passes.
- Unit tests pass, but only cover a small part of API behavior.
- Build passes with Vite chunk-size warnings.
- Lint currently fails on unused variables.
- Audit reports high and critical vulnerabilities.
- Several SQL-bearing routes reference stale column or table names.

## Phase 1 - Immediate Correctness Fixes

- [x] Fix web MFA session persistence.
  - [x] Add `refresh_token` to the MFA web response type.
  - [x] Store the MFA `refresh_token` through `authActions.login`.
  - [x] Remove the stale comment saying MFA verify does not return a refresh token.

- [x] Fix Expo push env-var drift.
  - [x] Accept both `EXPO_PUSH_ACCESS_TOKEN` and the documented `EXPO_ACCESS_TOKEN`.
  - [x] Update warnings and docs so the preferred name is clear.
  - [x] Keep backward compatibility for existing deployments.

- [x] Remove overstated compliance product copy.
  - [x] Replace "HIPAA Compliant" with a defensible readiness/control statement.
  - [x] Replace "SOC 2 Type II" with "SOC 2 planned" or another current-state phrase.
  - [x] Replace "FDA Class II" with "FDA assessment required" or equivalent.
  - [x] Update matching design artifacts if they are intended as source material.

- [x] Fix current lint failures.
  - [x] Re-run lint after implementation and confirm no current lint failures remain.

- [x] Fix mobile/API daily-entry field mismatch.
  - [x] Update mobile `useTodayEntry` to accept API `mood`.
  - [x] Preserve compatibility with any `mood_score` payloads if useful.
  - [ ] Add or update tests around the mapping if a suitable harness exists.

## Phase 2 - Schema Drift Repairs

- [ ] Repair sync route SQL.
  - [x] Decide whether mobile offline tables remain denormalized (`daily_entries` has `mood_score`, `sleep_hours`, etc.) while the server schema is normalized.
  - [x] For pull: project server rows into mobile sync shape with aliases and joins.
  - [x] For push: write core fields to `daily_entries`, sleep fields to `sleep_logs`, exercise fields to `exercise_logs`.
  - [x] Map mobile `daily_entry_triggers`, `daily_entry_symptoms`, and `daily_entry_strategies` to server `trigger_logs`, `symptom_logs`, and `wellness_logs`, or add compatibility views if that is safer.
  - [ ] Add integration coverage for pull and push against a migrated test DB.

- [ ] Repair FHIR SQL and mapping contracts.
  - [x] Replace stale patient address/diagnosis fields with existing patient/org/diagnosis sources.
  - [x] Join `sleep_logs` and `exercise_logs` for daily-entry observations.
  - [x] Use `medications_catalogue` and current `patient_medications` columns.
  - [x] Alias validated assessment columns from `scale`, `score`, `item_responses`, and `completed_at` into mapper-compatible names, or update mapper types.
  - [x] Replace synthetic patient diagnosis comments with `patient_diagnoses` where available.
  - [ ] Add route tests that validate generated FHIR resources from seeded data.

- [ ] Repair CDA generator SQL and section builders.
  - [x] Use current patient, medication, daily-entry, and assessment column names.
  - [x] Prefer `patient_diagnoses` over a non-existent patient diagnosis text field.
  - [ ] Add a smoke test for generating a CDA document.

- [ ] Repair research export SQL.
  - [x] Join sleep and exercise logs instead of selecting missing direct columns.
  - [ ] Ensure de-identification fields match the approved export schema.
  - [ ] Add a worker-level test with a tiny seeded dataset.

- [ ] Repair OMOP export worker SQL.
  - [x] Join sleep and exercise logs for measurement source values.
  - [ ] Confirm passive health and diagnosis mappings are still schema-current.
  - [ ] Add a worker smoke test that exports at least one patient.

## Phase 3 - Authorization and Tenant Boundaries

- [ ] Inventory all patient access checks.
- [ ] Introduce a shared patient-access helper.
  - [ ] Support patient self-access.
  - [ ] Support assigned clinician access.
  - [ ] Support org-scoped admin access.
  - [ ] Make global admin behavior explicit if it is intended.
- [ ] Replace duplicated `isAdminUser` helpers where practical.
- [ ] Prefer DB-current role/account status checks for sensitive operations.
- [ ] Add negative tests for cross-org and unassigned-patient access.

## Phase 4 - Database Security Contract

- [ ] Decide whether the API is intentionally service-role scoped.
- [ ] If RLS is intended:
  - [ ] Call `setRlsContext` at the request boundary.
  - [ ] Review all policies for tenant isolation.
  - [ ] Add tests that fail without the right context.
- [ ] If app-level scoping is intended:
  - [ ] Update docs that currently require `setRlsContext` before every query.
  - [ ] Add SQL-review guardrails and integration tests for tenant predicates.
- [ ] Remove or rewrite misleading RLS documentation.

## Phase 5 - Dependency and Supply-Chain Security

- [ ] Triage `npm audit --audit-level=high`.
- [ ] Group upgrades by blast radius.
  - [ ] Server/auth packages.
  - [ ] Web/router/build tooling.
  - [ ] Mobile/Expo packages.
  - [ ] Test tooling.
- [ ] Apply non-breaking fixes first.
- [ ] Create a breaking-upgrade branch or work item for Expo/Vitest/WatermelonDB changes.
- [ ] Raise CI audit policy from critical-only to high after the baseline is clean.

## Phase 6 - Test and CI Guardrails

- [ ] Add API integration tests with migrated Postgres and Redis.
- [ ] Cover auth, daily entries, sync, patients, reports, FHIR, CDA, research, and OMOP routes.
- [ ] Add a schema-contract smoke test that prepares representative SQL paths.
- [ ] Make Playwright E2E self-contained or clearly separate web-only tests.
- [ ] Add bundle-size tracking or intentional chunking for large Vite outputs.

## Phase 7 - Documentation Cleanup

- [ ] Update README architecture and migration count.
- [ ] Replace Supabase Auth references with local auth where applicable.
- [ ] Document the actual security model.
- [ ] Document Expo push token variable names.
- [ ] Update compliance wording to match current evidence.
- [ ] Keep `docs/DEVLOG.md` schema gotchas in sync with code.

## Implementation Order

1. Phase 1 small correctness fixes.
2. Research/OMOP export query repairs, because they are narrow and server-only.
3. FHIR/CDA repairs, because they share mapper contracts.
4. Sync repair, because it crosses API, mobile local schema, and normalized server schema.
5. Integration tests and generated schema guardrails.
6. Authorization/RLS clarification and hardening.
7. Dependency upgrades and CI policy tightening.

## Done Criteria

- `npm run typecheck`, `npm run lint`, `npm run test`, and `npm run build` pass.
- SQL-bearing repaired routes are covered by integration or worker smoke tests.
- Product copy no longer claims unverified compliance certifications.
- API/mobile field contracts are explicit and tested.
- Remaining high-risk work is tracked in this file or a linked issue tracker.
