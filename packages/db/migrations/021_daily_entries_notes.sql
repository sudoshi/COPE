-- =============================================================================
-- COPE — Migration 021: Add free-text notes column to daily_entries
-- The POST /api/v1/daily-entries handler (and CreateDailyEntrySchema, which
-- carries a `notes` field up to 1000 chars) has always written to a
-- daily_entries.notes column, but no prior migration ever created it — the
-- column existed only in the handler's INSERT/ON CONFLICT/RETURNING. As a
-- result every contract-valid check-in submission failed with
--   42703: column "notes" of relation "daily_entries" does not exist
-- and returned HTTP 500. This adds the missing column.
--
-- `notes` is the patient's general free-text note for the day and is distinct
-- from `life_event_note` (migration 004), which is specifically "a significant
-- event today". Both are intended to coexist on daily_entries.
-- =============================================================================

ALTER TABLE daily_entries
    ADD COLUMN IF NOT EXISTS notes TEXT;

COMMENT ON COLUMN daily_entries.notes IS
    'Patient free-text note for the day''s check-in (<=1000 chars). NULL = none. Distinct from life_event_note.';
