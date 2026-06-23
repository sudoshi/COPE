-- =============================================================================
-- Migration 020 — Authentik OIDC SSO foundation (ADDITIVE)
-- Adds the two tables the "Login with Authentik" flow needs. Local bcrypt auth
-- (migration 019) is untouched. These tables are intentionally NOT RLS-enabled:
-- the OIDC handshake runs pre-authentication.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Single-use, TTL'd handshake artifacts (PKCE/nonce state + one-time exchange code).
CREATE TABLE IF NOT EXISTS oidc_handshakes (
  id         TEXT PRIMARY KEY,
  kind       TEXT NOT NULL CHECK (kind IN ('state', 'exchange')),
  payload    JSONB NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_oidc_handshakes_expires
  ON oidc_handshakes(expires_at);

-- Links an external IdP subject (Authentik `sub`) to a local clinician.
CREATE TABLE IF NOT EXISTS user_external_identities (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES clinicians(id) ON DELETE CASCADE,
  provider_type     TEXT NOT NULL,
  provider_subject  TEXT NOT NULL,
  email_at_link     TEXT,
  claims            JSONB NOT NULL DEFAULT '{}'::jsonb,
  linked_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at     TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (provider_type, provider_subject)
);

CREATE INDEX IF NOT EXISTS idx_user_external_identities_user
  ON user_external_identities(user_id);

COMMENT ON TABLE oidc_handshakes IS 'Transient PKCE/nonce state + one-time SPA exchange codes for Authentik OIDC. Rows are single-use and TTL-expired.';
COMMENT ON TABLE user_external_identities IS 'Maps an Authentik subject to a local clinician for SSO sign-in (additive to local bcrypt auth).';
