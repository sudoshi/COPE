// =============================================================================
// COPE API — Nightly batch scheduler
// Runs every night at 02:00 America/New_York (≈ 07:00 UTC) to:
//   1. Evaluate RULE-002 (missed check-in) for all active patients
//   2. Generate per-clinician population_snapshots for the dashboard KPI cards
// =============================================================================

import { Worker, Queue } from 'bullmq';
import { sql } from '@cope/db';
import { connection, rulesQueue, type RulesJobData } from './rules-engine.js';
import { aiInsightsQueue, type AiInsightJobData } from './ai-insights-worker.js';
import { omopExportQueue, type OmopExportJobData } from './omop-export-worker.js';
import { config } from '../config.js';

const SCHEDULER_QUEUE_NAME = 'cope-nightly';

// ---------------------------------------------------------------------------
// Snapshot generation
// ---------------------------------------------------------------------------

async function generatePopulationSnapshots(dateStr: string): Promise<void> {
  // Compute per-clinician aggregates and upsert into population_snapshots.
  // All active clinicians who have ≥1 active patient are included.
  await sql`
    WITH base AS (
      SELECT DISTINCT
        c.organisation_id, ctm.clinician_id, p.id AS patient_id, p.status, p.risk_level
      FROM care_team_members ctm
      JOIN clinicians c ON c.id = ctm.clinician_id AND c.is_active = TRUE
      JOIN patients p
        ON p.id = ctm.patient_id AND ctm.unassigned_at IS NULL AND p.is_active = TRUE
    ),
    mood AS (
      SELECT patient_id, SUM(mood) AS mood_sum, COUNT(mood) AS mood_n,
             SUM(coping) AS coping_sum, COUNT(coping) AS coping_n
      FROM daily_entries WHERE entry_date >= ${dateStr}::DATE - 7 GROUP BY patient_id
    ),
    sleep AS (
      SELECT patient_id, SUM(total_minutes) AS sleep_sum, COUNT(total_minutes) AS sleep_n
      FROM sleep_logs WHERE entry_date >= ${dateStr}::DATE - 7 GROUP BY patient_id
    ),
    yesterday AS (
      SELECT DISTINCT patient_id FROM daily_entries
      WHERE entry_date = ${dateStr}::DATE - 1 AND submitted_at IS NOT NULL
    ),
    alerts AS (
      SELECT patient_id,
        COUNT(*) FILTER (WHERE severity = 'critical' AND auto_resolved = FALSE AND acknowledged_at IS NULL) AS crit,
        COUNT(*) FILTER (WHERE severity = 'warning'  AND auto_resolved = FALSE AND acknowledged_at IS NULL) AS warn
      FROM clinical_alerts GROUP BY patient_id
    )
    INSERT INTO population_snapshots (
      organisation_id, clinician_id, snapshot_date,
      total_patients, active_patients, crisis_patients,
      avg_mood_x10, avg_coping_x10, avg_sleep_minutes,
      risk_critical_count, risk_high_count, risk_moderate_count, risk_low_count,
      critical_alerts_count, warning_alerts_count, checkin_rate_pct, generated_at
    )
    SELECT
      b.organisation_id, b.clinician_id, ${dateStr}::DATE,
      COUNT(*)::SMALLINT,
      COUNT(*) FILTER (WHERE b.status = 'active')::SMALLINT,
      COUNT(*) FILTER (WHERE b.status = 'crisis')::SMALLINT,
      ROUND(10.0 * SUM(mood.mood_sum)   / NULLIF(SUM(mood.mood_n), 0))::SMALLINT,
      ROUND(10.0 * SUM(mood.coping_sum) / NULLIF(SUM(mood.coping_n), 0))::SMALLINT,
      ROUND(SUM(sleep.sleep_sum)::NUMERIC / NULLIF(SUM(sleep.sleep_n), 0))::SMALLINT,
      COUNT(*) FILTER (WHERE b.risk_level = 'critical')::SMALLINT,
      COUNT(*) FILTER (WHERE b.risk_level = 'high')::SMALLINT,
      COUNT(*) FILTER (WHERE b.risk_level = 'moderate')::SMALLINT,
      COUNT(*) FILTER (WHERE b.risk_level = 'low')::SMALLINT,
      COALESCE(SUM(alerts.crit), 0)::SMALLINT,
      COALESCE(SUM(alerts.warn), 0)::SMALLINT,
      CASE WHEN COUNT(*) > 0 THEN
        ROUND(100.0 * COUNT(*) FILTER (WHERE yesterday.patient_id IS NOT NULL) / COUNT(*))::SMALLINT
      END,
      NOW()
    FROM base b
    LEFT JOIN mood      ON mood.patient_id      = b.patient_id
    LEFT JOIN sleep     ON sleep.patient_id     = b.patient_id
    LEFT JOIN yesterday ON yesterday.patient_id = b.patient_id
    LEFT JOIN alerts    ON alerts.patient_id    = b.patient_id
    GROUP BY b.organisation_id, b.clinician_id
    ON CONFLICT (organisation_id, clinician_id, snapshot_date) DO UPDATE SET
      total_patients=EXCLUDED.total_patients, active_patients=EXCLUDED.active_patients,
      crisis_patients=EXCLUDED.crisis_patients, avg_mood_x10=EXCLUDED.avg_mood_x10,
      avg_coping_x10=EXCLUDED.avg_coping_x10, avg_sleep_minutes=EXCLUDED.avg_sleep_minutes,
      risk_critical_count=EXCLUDED.risk_critical_count, risk_high_count=EXCLUDED.risk_high_count,
      risk_moderate_count=EXCLUDED.risk_moderate_count, risk_low_count=EXCLUDED.risk_low_count,
      critical_alerts_count=EXCLUDED.critical_alerts_count, warning_alerts_count=EXCLUDED.warning_alerts_count,
      checkin_rate_pct=EXCLUDED.checkin_rate_pct, generated_at=NOW()
  `;
}

// ---------------------------------------------------------------------------
// Scheduler worker
// ---------------------------------------------------------------------------

export function startNightlyScheduler(): Worker {
  // The scheduler queue runs a single "tick" job on a cron schedule.
  // When the tick fires, we query all active patients and fan-out rules jobs.
  const schedulerQueue = new Queue(SCHEDULER_QUEUE_NAME, {
    connection,
    defaultJobOptions: { removeOnComplete: true, removeOnFail: 100 },
  });

  // Register the repeatable job (idempotent — BullMQ deduplicates by jobId)
  void schedulerQueue.add(
    'nightly-tick',
    {},
    {
      repeat: {
        // 02:00 EST/EDT (UTC-5 winter, UTC-4 summer) — approximated as 07:00 UTC
        // For production, use a timezone-aware cron library or set TZ=America/New_York
        pattern: '0 7 * * *',
      },
      jobId: 'nightly-tick-singleton',
    },
  );

  const worker = new Worker(
    SCHEDULER_QUEUE_NAME,
    async () => {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const dateStr = yesterday.toISOString().split('T')[0]!;

      // -----------------------------------------------------------------------
      // Step 1: Fan out rule evaluation jobs for all recently-active patients
      // -----------------------------------------------------------------------
      const patients = await sql<{ id: string; organisation_id: string }[]>`
        SELECT DISTINCT p.id, p.organisation_id
        FROM patients p
        JOIN daily_entries de ON de.patient_id = p.id
        WHERE de.entry_date >= CURRENT_DATE - INTERVAL '90 days'
          AND p.status = 'active'
      `;

      console.info(`[nightly] Processing ${patients.length} patients for ${dateStr}`);

      for (const patient of patients) {
        const jobData: RulesJobData = {
          patientId: patient.id,
          orgId: patient.organisation_id,
          entryDate: dateStr,
          triggeredBy: 'nightly_batch',
        };
        await rulesQueue.add('evaluate', jobData, {
          jobId: `nightly:${patient.id}:${dateStr}`,
        });
      }

      console.info(`[nightly] Enqueued ${patients.length} rule evaluation jobs`);

      // -----------------------------------------------------------------------
      // Step 2: Expire stale patient invites
      // -----------------------------------------------------------------------
      try {
        const expired = await sql`
          UPDATE patient_invites
          SET status = 'expired'
          WHERE status = 'pending'
            AND expires_at < NOW()
        `;
        if (expired.count > 0) {
          console.info(`[nightly] Expired ${expired.count} stale patient invite(s)`);
        }
      } catch (err) {
        console.error('[nightly] Invite expiry failed:', err);
      }

      // -----------------------------------------------------------------------
      // Step 3: Generate population snapshots for all clinicians
      // -----------------------------------------------------------------------
      try {
        await generatePopulationSnapshots(dateStr);
        console.info(`[nightly] Population snapshots generated for ${dateStr}`);
      } catch (err) {
        // Non-fatal — dashboard falls back to live counts if snapshot missing
        console.error('[nightly] Snapshot generation failed:', err);
      }

      // -----------------------------------------------------------------------
      // Step 4: Risk stratification for all active patients (rule-based, no AI)
      // Runs regardless of AI_INSIGHTS_ENABLED — score is pure rules engine.
      // -----------------------------------------------------------------------
      try {
        for (const patient of patients) {
          const jobData: AiInsightJobData = {
            patientId: patient.id,
            orgId:     patient.organisation_id,
            jobType:   'risk_stratification',
          };
          await aiInsightsQueue.add('risk_stratification', jobData, {
            jobId: `risk:${patient.id}:${dateStr}`,
          });
        }
        console.info(`[nightly] Enqueued ${patients.length} risk_stratification jobs`);
      } catch (err) {
        console.error('[nightly] Risk stratification fan-out failed:', err);
      }

      // -----------------------------------------------------------------------
      // Step 5: Weekly AI summaries (gated — only runs if AI is fully enabled)
      // Generates AI narratives for patients who have given ai_insights consent.
      // -----------------------------------------------------------------------
      if (config.aiInsightsEnabled && (config.aiProvider === 'ollama' || config.anthropicBaaSigned)) {
        try {
          const aiPatients = await sql<{ id: string; organisation_id: string }[]>`
            SELECT DISTINCT p.id, p.organisation_id
            FROM patients p
            JOIN consent_records cr
              ON cr.patient_id   = p.id
             AND cr.consent_type = 'ai_insights'
             AND cr.granted      = TRUE
            JOIN daily_entries de ON de.patient_id = p.id
            WHERE p.status      = 'active'
              AND de.entry_date >= CURRENT_DATE - INTERVAL '7 days'
          `;

          for (const patient of aiPatients) {
            const jobData: AiInsightJobData = {
              patientId:  patient.id,
              orgId:      patient.organisation_id,
              jobType:    'generate_weekly_summary',
              periodDays: 7,
            };
            await aiInsightsQueue.add('weekly_summary', jobData, {
              jobId: `ai_weekly:${patient.id}:${dateStr}`,
            });
          }
          console.info(`[nightly] Enqueued ${aiPatients.length} weekly AI summary jobs`);
        } catch (err) {
          // Non-fatal — AI summaries are supplementary
          console.error('[nightly] AI summary fan-out failed:', err);
        }
      }

      // -----------------------------------------------------------------------
      // Step 5B: Nightly deep analysis (gated — same as weekly summaries)
      // Fans out nightly_deep_analysis jobs for consented active patients
      // who have new daily_entries since their last deep analysis.
      // -----------------------------------------------------------------------
      if (config.aiInsightsEnabled && (config.aiProvider === 'ollama' || config.anthropicBaaSigned)) {
        try {
          const deepPatients = await sql<{ id: string; organisation_id: string }[]>`
            SELECT DISTINCT p.id, p.organisation_id
            FROM patients p
            JOIN consent_records cr
              ON cr.patient_id   = p.id
             AND cr.consent_type = 'ai_insights'
             AND cr.granted      = TRUE
            WHERE p.status = 'active'
              AND EXISTS (
                SELECT 1 FROM daily_entries de
                WHERE de.patient_id   = p.id
                  AND de.submitted_at IS NOT NULL
                  AND de.submitted_at > COALESCE(
                    (SELECT MAX(pai.generated_at)
                     FROM patient_ai_insights pai
                     WHERE pai.patient_id  = p.id
                       AND pai.insight_type = 'nightly_deep_analysis'),
                    '1970-01-01'::timestamptz
                  )
              )
          `;

          for (const patient of deepPatients) {
            const jobData: AiInsightJobData = {
              patientId:  patient.id,
              orgId:      patient.organisation_id,
              jobType:    'nightly_deep_analysis',
              periodDays: 30,
            };
            await aiInsightsQueue.add('nightly_deep_analysis', jobData, {
              jobId: `ai_deep:${patient.id}:${dateStr}`,
            });
          }
          console.info(`[nightly] Enqueued ${deepPatients.length} nightly deep analysis jobs`);
        } catch (err) {
          console.error('[nightly] Deep analysis fan-out failed:', err);
        }
      }

      // -----------------------------------------------------------------------
      // Step 6: OMOP CDM nightly export
      // Incremental ETL of clinical data to OMOP CDM v5.4 TSV files.
      // -----------------------------------------------------------------------
      try {
        const [exportRun] = await sql<{ id: string }[]>`
          INSERT INTO omop_export_runs (triggered_by, output_mode, full_refresh)
          VALUES ('nightly', 'tsv_upload', FALSE)
          RETURNING id
        `;

        if (exportRun) {
          const jobData: OmopExportJobData = {
            exportRunId: exportRun.id,
            triggeredBy: 'nightly',
            outputMode:  'tsv_upload',
            fullRefresh: false,
          };
          await omopExportQueue.add('omop-export', jobData, {
            jobId: `omop:nightly:${dateStr}`,
          });
          console.info(`[nightly] Enqueued OMOP CDM export ${exportRun.id}`);
        }
      } catch (err) {
        // Non-fatal — OMOP export failure doesn't block other nightly steps
        console.error('[nightly] OMOP export enqueue failed:', err);
      }
    },
    { connection, concurrency: 1 },
  );

  worker.on('failed', (_job, err) => {
    console.error('[nightly] Scheduler tick failed:', err.message);
  });

  return worker;
}
