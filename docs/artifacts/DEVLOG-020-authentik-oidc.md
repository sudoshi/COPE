# DEVLOG 020 — "Login with Authentik" (OIDC SSO)

**Date:** 2026-06-22
**Author:** Sanjay Udoshi (with Claude Code)
**Status:** Shipped to production (cope.acumenus.net)
**Migration:** `packages/db/migrations/020_authentik_oidc.sql`
**Commit:** `feat(auth): add Login with Authentik (OIDC SSO), additive`

---

## Summary

COPE now offers a **"Continue with Authentik"** button on the login screen alongside
the existing email/password sign-in. It implements the OpenID Connect
**Authorization Code flow with PKCE**, federating authentication to the Acumenus
Authentik IdP (`auth.acumenus.net`). The same 7 people who administer Parthenon
(the "Parthenon Admins") can now sign into COPE as administrators with their
Authentik identity.

This work is **purely additive**. The protected local-auth subsystem
(`apps/api/src/routes/auth.ts`, bcrypt + MFA + rotating refresh tokens, the
forced-password-change flow) is untouched, per `.claude/rules/auth-system.md`.

## Why

COPE was the fourth of five Acumenus apps to receive a uniform SSO experience.
Parthenon, Medgnosis, Aurora and Zephyrus already had it; COPE and MediCosts did
not. The goal: a single Authentik login that mirrors admin access across the
fleet, so the team has one identity and one set of credentials everywhere.

## Architecture

Mirrors the Medgnosis/Parthenon "library-light, hand-rolled" OIDC pattern. Tokens
never ride in a URL: a one-time exchange code hands the COPE session to the SPA.

```
SPA login → GET /api/v1/auth/providers (is SSO enabled?)
          → click → GET /api/v1/auth/oidc/redirect
                    (PKCE verifier + nonce stored under random `state`, 302 to Authentik)
Authentik → GET /api/v1/auth/oidc/callback?code&state
                    (consume state → token exchange → validate id_token (jose) →
                     reconcile clinician → store one-time exchange code →
                     302 to /auth/callback?code=…)
SPA       → POST /api/v1/auth/oidc/exchange { code }
                    (consume code → mint COPE JWT + refresh token → { token, user })
          → authActions.login(...) → /dashboard
```

### New backend files (`apps/api/src/`)
| File | Role |
|------|------|
| `services/auth/oidc/discovery.ts` | Fetch + 1h-cache the Authentik `.well-known/openid-configuration` |
| `services/auth/oidc/handshakeStore.ts` | Single-use, TTL'd `state`/`exchange` artifacts in `oidc_handshakes` |
| `services/auth/oidc/tokenValidator.ts` | `jose` JWKS verify — issuer, audience, 15m maxAge, nonce |
| `services/auth/oidc/providerConfig.ts` | Env-driven config + `isOidcPubliclyAvailable()` |
| `services/auth/oidc/reconciliation.ts` | sub → email → JIT-create clinician (group-gated) |
| `routes/auth-oidc.ts` | The 4 routes; registered under `/auth` in `routes/index.ts` (auth.ts untouched) |

### Changed files
- `apps/api/src/config.ts` — added `oidc*` config block + `optionalList()` helper
- `apps/api/src/routes/index.ts` — register `authOidcRoutes` under `/auth`
- `apps/api/package.json` — add `jose`
- `apps/web/src/pages/LoginPage.tsx` — SSO button (gated on `/auth/providers`)
- `apps/web/src/pages/OidcCallbackPage.tsx` — new `/auth/callback` page
- `apps/web/src/App.tsx` — public `/auth/callback` route

### Database (migration 020)
- `oidc_handshakes` — `id TEXT PK, kind('state'|'exchange'), payload JSONB, expires_at` (no RLS; pre-auth)
- `user_external_identities` — links Authentik `sub` → `clinicians.id`, unique `(provider_type, provider_subject)`

Applied to `copedemo` via `claude_dev`; both tables **owned by the app user `smudoshi`**
(critical — claude_dev-owned tables would 42501 the app). Recorded in `_migrations`.

## Identity reconciliation & roles

`reconcileOidcUser()` runs in one transaction:
1. Match by linked `provider_subject` (sub).
2. Else match by `lower(email)`.
3. Else **JIT-create** a `clinicians` row under a find-or-create **"Acumenus"** org
   (clinicians.organisation_id is `NOT NULL`), with an unusable bcrypt password
   and `must_change_password=false`.

Group → role: members of `OIDC_ADMIN_GROUPS` ("COPE Admins") get `clinicians.role='admin'`;
the exchange then mints a JWT with `role:'admin'` (mirroring the dev-admin path).
super-admin is never minted via SSO. Access is gated: a user not in any allowed
group is rejected with `access_denied`.

## Authentik provisioning

`scripts/authentik/provision_cope_oidc.py` (idempotent) created:
- OAuth2/OpenID provider **"COPE OIDC"** (pk 49), confidential, S256, includes the
  `groups` claim mapping, redirect `https://cope.acumenus.net/api/v1/auth/oidc/callback` (strict).
- Application slug **`cope-oidc`**.
- Group **"COPE Admins"** with the 7 admins
  (`sudoshi, ebruno, kpatel, jdawe, dmuraco, gbock, admin`), bound to the app.

The generated `OIDC_CLIENT_ID`/`OIDC_CLIENT_SECRET` were written to
`.env.production` (gitignored, never committed) along with `WEB_APP_URL`.

## Deployment

Prod = `cope.acumenus.net`, systemd `cope-api` (port 3080, Apache reverse proxy,
`EnvironmentFile=.env.production`). Deploy model: commit to `main` → the
`cope-auto-deploy` daemon detects the new HEAD and runs `npm run build` +
`systemctl restart cope-api cope-worker` + a static-asset `chmod a+rX` self-heal.
The daemon never `git reset`s, so uncommitted edits are safe.

## Verification

- `GET /api/v1/auth/providers` → `{ oidc_enabled: true, oidc_label: "Authentik" }`
- `GET /api/v1/auth/oidc/redirect` → `302` to Authentik authorize with valid
  `client_id`, `redirect_uri`, `scope=openid profile email groups`, `code_challenge_method=S256`
- Discovery doc resolves; SPA bundle contains the button.
- Authentik authorize URL accepts the client (no `invalid_client` / redirect mismatch).

## Gotchas captured

1. **postgres.js tagged templates on the transaction handle (`tx`) don't type-check**
   cleanly — use `tx.unsafe(query, params)` inside `sql.begin` (as Medgnosis does).
2. **Table ownership**: tables created by `claude_dev` must be `ALTER TABLE … OWNER TO smudoshi`
   or the app (connecting as `smudoshi`) gets permission errors.
3. JIT clinicians need an org (`organisation_id NOT NULL`) → find-or-create "Acumenus".
4. `WEB_APP_URL` must be the public origin or the callback redirects to localhost.
