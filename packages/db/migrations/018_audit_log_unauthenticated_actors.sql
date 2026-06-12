-- =============================================================================
-- 018 — Allow unauthenticated actors in audit_log
--
-- Failed login attempts have no authenticated actor or organisation, but
-- actor_id and organisation_id were NOT NULL uuid columns. The middleware
-- passed the sentinel string 'unknown', so every failed-login audit INSERT
-- was rejected (22P02 invalid uuid) and silently dropped — the audit trail
-- was missing exactly the security events HIPAA monitoring needs most.
--
-- NULL actor_id/organisation_id now means "unauthenticated request"; the
-- attempted identity is recorded by the API in new_values.attempted_email.
-- =============================================================================

ALTER TABLE audit_log ALTER COLUMN actor_id DROP NOT NULL;
ALTER TABLE audit_log ALTER COLUMN organisation_id DROP NOT NULL;
