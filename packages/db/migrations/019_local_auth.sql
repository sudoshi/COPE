-- =============================================================================
-- 019 — Local PostgreSQL auth (Supabase retirement)
--
-- The Supabase project backing the auth fallback, patient registration,
-- refresh tokens, and MFA was paused past its 90-day recovery window. All
-- auth is now backed by local PostgreSQL 17:
--   * clinicians AND patients get bcrypt password_hash + forced first-login
--     password change (these columns existed only in the prod DB until now —
--     001_initial never declared them, so a fresh DB was missing local auth)
--   * refresh tokens are first-party, opaque, stored hashed, rotated on use
--   * TOTP MFA secrets live on the clinician row (verified via otplib)
--
-- Every statement is idempotent (IF NOT EXISTS / guarded policy) so this is
-- safe on a fresh DB and on the prod DB that already has these objects.
-- =============================================================================

ALTER TABLE patients   ADD COLUMN IF NOT EXISTS password_hash        TEXT;
ALTER TABLE clinicians ADD COLUMN IF NOT EXISTS password_hash        TEXT;
ALTER TABLE clinicians ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE clinicians ADD COLUMN IF NOT EXISTS mfa_secret           TEXT;  -- declared in 001; kept for clarity

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL,
  user_role    TEXT        NOT NULL CHECK (user_role IN ('clinician', 'patient', 'admin')),
  org_id       UUID,
  token_hash   TEXT        NOT NULL UNIQUE,  -- sha256 of the opaque token; raw value never stored
  expires_at   TIMESTAMPTZ NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  revoked_at   TIMESTAMPTZ,
  replaced_by  UUID REFERENCES refresh_tokens (id)
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user    ON refresh_tokens (user_id, expires_at DESC);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires ON refresh_tokens (expires_at) WHERE revoked_at IS NULL;

ALTER TABLE refresh_tokens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "service_role_all" ON refresh_tokens;
CREATE POLICY "service_role_all" ON refresh_tokens USING (TRUE) WITH CHECK (TRUE);
