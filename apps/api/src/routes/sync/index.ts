// =============================================================================
// COPE API — /sync routes
// Supports the WatermelonDB offline-first sync protocol.
//
// GET  /sync/pull  — return all server changes since lastPulledAt (per patient)
// POST /sync/push  — accept locally-created/updated/deleted records from patient
//
// Only patient-role users sync their own data.
// Clinicians pull via REST (no WDB), so this endpoint is patient-only.
// =============================================================================

import type { FastifyInstance } from 'fastify';
import { sql } from '@cope/db';
import { auditLog } from '../../middleware/audit.js';
import type { JwtPayload } from '../../plugins/auth.js';
import {
  syncPullRouteSchema,
  syncPushRouteSchema,
} from '../mobile-openapi-schemas.js';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface PullQuery {
  last_pulled_at?: string; // unix ms as string, '0' means full sync
  schema_version?: string;
  migration?: string;
}

interface SyncRow {
  id: string;
  [key: string]: unknown;
}

interface SyncTableChanges {
  created: SyncRow[];
  updated: SyncRow[];
  deleted: string[];
}

interface PushBody {
  last_pulled_at: number;
  changes: {
    daily_entries?: Partial<SyncTableChanges>;
    journal_entries?: Partial<SyncTableChanges>;
    daily_entry_triggers?: Partial<SyncTableChanges>;
    daily_entry_symptoms?: Partial<SyncTableChanges>;
    daily_entry_strategies?: Partial<SyncTableChanges>;
  };
}

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function uuidOrNull(value: unknown): string | null {
  return typeof value === 'string' && UUID_RE.test(value) ? value : null;
}

function roundSleepMinutes(sleepHours: number): { hours: number; minutes: 0 | 15 | 30 | 45 } {
  const hours = Math.floor(sleepHours);
  const rawMinutes = Math.round((sleepHours - hours) * 60);
  const minutes = ([0, 15, 30, 45] as const).reduce((prev, curr) =>
    Math.abs(curr - rawMinutes) < Math.abs(prev - rawMinutes) ? curr : prev,
  );
  return { hours, minutes };
}

// ---------------------------------------------------------------------------
// Route plugin
// ---------------------------------------------------------------------------

async function syncRoutes(fastify: FastifyInstance): Promise<void> {
  // ---------------------------------------------------------------------------
  // GET /sync/pull
  // ---------------------------------------------------------------------------
  fastify.get<{ Querystring: PullQuery }>(
    '/pull',
    { preHandler: [fastify.authenticate], schema: syncPullRouteSchema },
    async (request, reply) => {
      const user = request.user as JwtPayload;

      // Patients only — clinicians use REST endpoints
      if (user.role !== 'patient') {
        return reply.status(403).send({ success: false, error: { message: 'Patients only' } });
      }

      const lastPulledAtMs = parseInt(request.query.last_pulled_at ?? '0', 10);
      const sinceDate = lastPulledAtMs
        ? new Date(lastPulledAtMs).toISOString()
        : new Date(0).toISOString();

      const patientId = user.sub;
      const nowMs = Date.now();

      // -----------------------------------------------------------------------
      // Fetch changed rows in parallel
      // -----------------------------------------------------------------------
      const [
        entriesCreated, entriesUpdated, entriesDeleted,
        journalCreated, journalUpdated, journalDeleted,
        trigsCreated, trigsUpdated, trigsDeleted,
        symsCreated, symsUpdated, symsDeleted,
        stratsCreated, stratsUpdated, stratsDeleted,
        triggersAll, symptomsAll, strategiesAll,
      ] = await Promise.all([
        // daily_entries created after sinceDate
        sql<SyncRow[]>`
          SELECT de.id, de.patient_id, de.entry_date,
                 de.mood AS mood_score,
                 ROUND(sl.total_minutes::NUMERIC / 60, 2)::FLOAT8 AS sleep_hours,
                 el.duration_minutes AS exercise_minutes,
                 de.notes,
                 (de.submitted_at IS NOT NULL) AS is_complete,
                 de.completion_pct, de.core_complete, de.wellness_complete,
                 de.triggers_complete, de.symptoms_complete, de.journal_complete,
                 de.mania_score, de.racing_thoughts, de.decreased_sleep_need,
                 de.anxiety_score, de.somatic_anxiety, de.anhedonia_score,
                 de.suicidal_ideation, de.substance_use, de.substance_quantity,
                 de.social_score, de.social_avoidance, de.cognitive_score,
                 de.brain_fog, de.appetite_score, de.stress_score,
                 de.life_event_note,
                 de.submitted_at, de.created_at,
                 GREATEST(
                   de.updated_at,
                   COALESCE(sl.updated_at, de.updated_at),
                   COALESCE(el.created_at, de.updated_at)
                 ) AS updated_at,
                 de.id AS server_id
          FROM daily_entries de
          LEFT JOIN sleep_logs sl ON sl.daily_entry_id = de.id
          LEFT JOIN exercise_logs el ON el.daily_entry_id = de.id
          WHERE de.patient_id = ${patientId}
            AND de.created_at > ${sinceDate}::timestamptz
        `,
        // daily_entries updated (but not created) after sinceDate
        sql<SyncRow[]>`
          SELECT de.id, de.patient_id, de.entry_date,
                 de.mood AS mood_score,
                 ROUND(sl.total_minutes::NUMERIC / 60, 2)::FLOAT8 AS sleep_hours,
                 el.duration_minutes AS exercise_minutes,
                 de.notes,
                 (de.submitted_at IS NOT NULL) AS is_complete,
                 de.completion_pct, de.core_complete, de.wellness_complete,
                 de.triggers_complete, de.symptoms_complete, de.journal_complete,
                 de.mania_score, de.racing_thoughts, de.decreased_sleep_need,
                 de.anxiety_score, de.somatic_anxiety, de.anhedonia_score,
                 de.suicidal_ideation, de.substance_use, de.substance_quantity,
                 de.social_score, de.social_avoidance, de.cognitive_score,
                 de.brain_fog, de.appetite_score, de.stress_score,
                 de.life_event_note,
                 de.submitted_at, de.created_at,
                 GREATEST(
                   de.updated_at,
                   COALESCE(sl.updated_at, de.updated_at),
                   COALESCE(el.created_at, de.updated_at)
                 ) AS updated_at,
                 de.id AS server_id
          FROM daily_entries de
          LEFT JOIN sleep_logs sl ON sl.daily_entry_id = de.id
          LEFT JOIN exercise_logs el ON el.daily_entry_id = de.id
          WHERE de.patient_id = ${patientId}
            AND de.created_at <= ${sinceDate}::timestamptz
            AND GREATEST(
              de.updated_at,
              COALESCE(sl.updated_at, de.updated_at),
              COALESCE(el.created_at, de.updated_at)
            ) > ${sinceDate}::timestamptz
        `,
        // No soft-delete on entries yet — return empty
        sql<{ id: string }[]>`SELECT NULL::uuid AS id WHERE FALSE`,

        // journal_entries created
        sql<SyncRow[]>`
          SELECT je.id, je.daily_entry_id, je.patient_id, je.body, je.word_count,
                 je.is_shared_with_care_team, je.created_at, je.updated_at,
                 je.id AS server_id,
                 je.created_at::text AS created_at_iso
          FROM journal_entries je
          WHERE je.patient_id = ${patientId}
            AND je.created_at > ${sinceDate}::timestamptz
            AND je.updated_at = je.created_at
        `,
        // journal_entries updated
        sql<SyncRow[]>`
          SELECT je.id, je.daily_entry_id, je.patient_id, je.body, je.word_count,
                 je.is_shared_with_care_team, je.created_at, je.updated_at,
                 je.id AS server_id,
                 je.created_at::text AS created_at_iso
          FROM journal_entries je
          WHERE je.patient_id = ${patientId}
            AND je.updated_at > ${sinceDate}::timestamptz
            AND je.updated_at > je.created_at
        `,
        sql<{ id: string }[]>`SELECT NULL::uuid AS id WHERE FALSE`,

        // daily_entry_triggers created
        sql<SyncRow[]>`
          SELECT tl.id, tl.daily_entry_id, tl.trigger_id, tl.severity,
                 tl.created_at, tl.updated_at, tl.id AS server_id
          FROM trigger_logs tl
          JOIN daily_entries de ON de.id = tl.daily_entry_id
          WHERE de.patient_id = ${patientId}
            AND tl.created_at > ${sinceDate}::timestamptz
            AND tl.updated_at = tl.created_at
        `,
        // daily_entry_triggers updated
        sql<SyncRow[]>`
          SELECT tl.id, tl.daily_entry_id, tl.trigger_id, tl.severity,
                 tl.created_at, tl.updated_at, tl.id AS server_id
          FROM trigger_logs tl
          JOIN daily_entries de ON de.id = tl.daily_entry_id
          WHERE de.patient_id = ${patientId}
            AND tl.updated_at > ${sinceDate}::timestamptz
            AND tl.updated_at > tl.created_at
        `,
        sql<{ id: string }[]>`SELECT NULL::uuid AS id WHERE FALSE`,

        // daily_entry_symptoms created
        sql<SyncRow[]>`
          SELECT sl.id, sl.daily_entry_id, sl.symptom_id,
                 sl.intensity AS severity,
                 sl.created_at, sl.updated_at, sl.id AS server_id
          FROM symptom_logs sl
          JOIN daily_entries de ON de.id = sl.daily_entry_id
          WHERE de.patient_id = ${patientId}
            AND sl.created_at > ${sinceDate}::timestamptz
            AND sl.updated_at = sl.created_at
        `,
        // daily_entry_symptoms updated
        sql<SyncRow[]>`
          SELECT sl.id, sl.daily_entry_id, sl.symptom_id,
                 sl.intensity AS severity,
                 sl.created_at, sl.updated_at, sl.id AS server_id
          FROM symptom_logs sl
          JOIN daily_entries de ON de.id = sl.daily_entry_id
          WHERE de.patient_id = ${patientId}
            AND sl.updated_at > ${sinceDate}::timestamptz
            AND sl.updated_at > sl.created_at
        `,
        sql<{ id: string }[]>`SELECT NULL::uuid AS id WHERE FALSE`,

        // daily_entry_strategies created
        sql<SyncRow[]>`
          SELECT wl.id, wl.daily_entry_id, wl.strategy_id,
                 (wl.state = 'yes') AS helped,
                 wl.created_at, wl.updated_at, wl.id AS server_id
          FROM wellness_logs wl
          JOIN daily_entries de ON de.id = wl.daily_entry_id
          WHERE de.patient_id = ${patientId}
            AND wl.created_at > ${sinceDate}::timestamptz
            AND wl.updated_at = wl.created_at
        `,
        // daily_entry_strategies updated
        sql<SyncRow[]>`
          SELECT wl.id, wl.daily_entry_id, wl.strategy_id,
                 (wl.state = 'yes') AS helped,
                 wl.created_at, wl.updated_at, wl.id AS server_id
          FROM wellness_logs wl
          JOIN daily_entries de ON de.id = wl.daily_entry_id
          WHERE de.patient_id = ${patientId}
            AND wl.updated_at > ${sinceDate}::timestamptz
            AND wl.updated_at > wl.created_at
        `,
        sql<{ id: string }[]>`SELECT NULL::uuid AS id WHERE FALSE`,

        // Catalogues — full sync always (small tables, rarely change)
        sql<SyncRow[]>`
          SELECT id, name, category, created_at, created_at AS updated_at, id AS server_id
          FROM trigger_catalogue
          WHERE is_active = TRUE
            AND (is_system = TRUE OR organisation_id = ${user.org_id}::UUID OR patient_id = ${patientId})
          ORDER BY name
        `,
        sql<SyncRow[]>`
          SELECT id, name, is_safety_symptom, created_at, created_at AS updated_at, id AS server_id
          FROM symptom_catalogue
          WHERE is_active = TRUE
            AND (is_system = TRUE OR organisation_id = ${user.org_id}::UUID OR patient_id = ${patientId})
          ORDER BY name
        `,
        sql<SyncRow[]>`
          SELECT id, name, category, created_at, created_at AS updated_at, id AS server_id
          FROM wellness_strategies
          WHERE is_active = TRUE
            AND (is_system = TRUE OR organisation_id = ${user.org_id}::UUID OR patient_id = ${patientId})
          ORDER BY name
        `,
      ]);

      await auditLog({
        actor: user,
        action: 'read',
        resourceType: 'sync_pull',
        resourceId: patientId,
      });

      // Helper to filter out null ids from empty queries
      const cleanDeleted = (rows: { id: string }[]) =>
        rows.map((r) => r.id).filter(Boolean);

      return reply.send({
        success: true,
        data: {
          changes: {
            daily_entries: {
              created: entriesCreated,
              updated: entriesUpdated,
              deleted: cleanDeleted(entriesDeleted),
            },
            journal_entries: {
              created: journalCreated,
              updated: journalUpdated,
              deleted: cleanDeleted(journalDeleted),
            },
            daily_entry_triggers: {
              created: trigsCreated,
              updated: trigsUpdated,
              deleted: cleanDeleted(trigsDeleted),
            },
            daily_entry_symptoms: {
              created: symsCreated,
              updated: symsUpdated,
              deleted: cleanDeleted(symsDeleted),
            },
            daily_entry_strategies: {
              created: stratsCreated,
              updated: stratsUpdated,
              deleted: cleanDeleted(stratsDeleted),
            },
            triggers: {
              created: lastPulledAtMs === 0 ? triggersAll : [],
              updated: lastPulledAtMs > 0 ? triggersAll : [],
              deleted: [],
            },
            symptoms: {
              created: lastPulledAtMs === 0 ? symptomsAll : [],
              updated: lastPulledAtMs > 0 ? symptomsAll : [],
              deleted: [],
            },
            wellness_strategies: {
              created: lastPulledAtMs === 0 ? strategiesAll : [],
              updated: lastPulledAtMs > 0 ? strategiesAll : [],
              deleted: [],
            },
          },
          timestamp: nowMs,
        },
      });
    },
  );

  // ---------------------------------------------------------------------------
  // POST /sync/push
  // ---------------------------------------------------------------------------
  fastify.post<{ Body: PushBody }>(
    '/push',
    { preHandler: [fastify.authenticate], schema: syncPushRouteSchema },
    async (request, reply) => {
      const user = request.user as JwtPayload;
      if (user.role !== 'patient') {
        return reply.status(403).send({ success: false, error: { message: 'Patients only' } });
      }

      const patientId = user.sub;
      const { changes } = request.body;

      // -----------------------------------------------------------------------
      // Process daily_entries pushed from client
      // We use upsert via INSERT ... ON CONFLICT UPDATE
      // -----------------------------------------------------------------------
      const entryCreated = changes.daily_entries?.created ?? [];
      const entryUpdated = changes.daily_entries?.updated ?? [];
      const entryRefs = new Map<string, { id: string; entry_date: string }>();

      for (const row of [...entryCreated, ...entryUpdated]) {
        const requestedId = uuidOrNull(row.server_id) ?? uuidOrNull(row.id);
        const entryDate = row.entry_date as string;

        // Ensure the record belongs to this patient (never trust client patientId)
        const [entry] = await sql<{ id: string; entry_date: string }[]>`
          INSERT INTO daily_entries (
            id, patient_id, entry_date, mood, notes, completion_pct,
            core_complete, wellness_complete, triggers_complete, symptoms_complete,
            journal_complete,
            mania_score, racing_thoughts, decreased_sleep_need,
            anxiety_score, somatic_anxiety, anhedonia_score,
            suicidal_ideation, substance_use, substance_quantity,
            social_score, social_avoidance, cognitive_score,
            brain_fog, appetite_score, stress_score, life_event_note,
            submitted_at
          )
          VALUES (
            COALESCE(${requestedId}::UUID, gen_random_uuid()),
            ${patientId},
            ${entryDate},
            ${(row.mood_score as number | null) ?? null},
            ${(row.notes as string | null) ?? null},
            ${(row.completion_pct as number) ?? 0},
            ${Boolean(row.core_complete)},
            ${Boolean(row.wellness_complete)},
            ${Boolean(row.triggers_complete)},
            ${Boolean(row.symptoms_complete)},
            ${Boolean(row.journal_complete)},
            ${(row.mania_score as number | null) ?? null},
            ${(row.racing_thoughts as boolean | null) ?? null},
            ${(row.decreased_sleep_need as boolean | null) ?? null},
            ${(row.anxiety_score as number | null) ?? null},
            ${(row.somatic_anxiety as boolean | null) ?? null},
            ${(row.anhedonia_score as number | null) ?? null},
            ${(row.suicidal_ideation as number | null) ?? null},
            ${(row.substance_use as string | null) ?? null},
            ${(row.substance_quantity as number | null) ?? null},
            ${(row.social_score as number | null) ?? null},
            ${(row.social_avoidance as boolean | null) ?? null},
            ${(row.cognitive_score as number | null) ?? null},
            ${(row.brain_fog as boolean | null) ?? null},
            ${(row.appetite_score as number | null) ?? null},
            ${(row.stress_score as number | null) ?? null},
            ${(row.life_event_note as string | null) ?? null},
            ${(row.submitted_at as string | null) ?? null}
          )
          ON CONFLICT (patient_id, entry_date)
          DO UPDATE SET
            mood = EXCLUDED.mood,
            notes = EXCLUDED.notes,
            completion_pct = EXCLUDED.completion_pct,
            core_complete = EXCLUDED.core_complete,
            wellness_complete = EXCLUDED.wellness_complete,
            triggers_complete = EXCLUDED.triggers_complete,
            symptoms_complete = EXCLUDED.symptoms_complete,
            journal_complete = EXCLUDED.journal_complete,
            mania_score = EXCLUDED.mania_score,
            racing_thoughts = EXCLUDED.racing_thoughts,
            decreased_sleep_need = EXCLUDED.decreased_sleep_need,
            anxiety_score = EXCLUDED.anxiety_score,
            somatic_anxiety = EXCLUDED.somatic_anxiety,
            anhedonia_score = EXCLUDED.anhedonia_score,
            suicidal_ideation = EXCLUDED.suicidal_ideation,
            substance_use = EXCLUDED.substance_use,
            substance_quantity = EXCLUDED.substance_quantity,
            social_score = EXCLUDED.social_score,
            social_avoidance = EXCLUDED.social_avoidance,
            cognitive_score = EXCLUDED.cognitive_score,
            brain_fog = EXCLUDED.brain_fog,
            appetite_score = EXCLUDED.appetite_score,
            stress_score = EXCLUDED.stress_score,
            life_event_note = EXCLUDED.life_event_note,
            last_saved_at = NOW(),
            submitted_at = COALESCE(EXCLUDED.submitted_at, daily_entries.submitted_at)
          RETURNING id, entry_date::TEXT AS entry_date
        `;

        if (!entry) continue;

        const clientId = typeof row.id === 'string' ? row.id : null;
        const serverId = typeof row.server_id === 'string' ? row.server_id : null;
        if (clientId) entryRefs.set(clientId, entry);
        if (serverId) entryRefs.set(serverId, entry);
        entryRefs.set(entry.id, entry);

        if (typeof row.sleep_hours === 'number') {
          const sleep = roundSleepMinutes(row.sleep_hours);
          await sql`
            INSERT INTO sleep_logs (daily_entry_id, patient_id, entry_date, hours, minutes)
            VALUES (${entry.id}::UUID, ${patientId}, ${entry.entry_date}, ${sleep.hours}, ${sleep.minutes})
            ON CONFLICT (daily_entry_id) DO UPDATE
              SET hours = EXCLUDED.hours,
                  minutes = EXCLUDED.minutes
          `;
        }

        if (typeof row.exercise_minutes === 'number') {
          await sql`
            INSERT INTO exercise_logs (daily_entry_id, patient_id, entry_date, duration_minutes)
            VALUES (${entry.id}::UUID, ${patientId}, ${entry.entry_date}, ${row.exercise_minutes})
            ON CONFLICT (daily_entry_id) DO UPDATE
              SET duration_minutes = EXCLUDED.duration_minutes
          `;
        }
      }

      async function resolveEntry(ref: unknown): Promise<{ id: string; entry_date: string } | null> {
        if (typeof ref !== 'string') return null;
        const mapped = entryRefs.get(ref);
        if (mapped) return mapped;
        const serverId = uuidOrNull(ref);
        if (!serverId) return null;
        const [entry] = await sql<{ id: string; entry_date: string }[]>`
          SELECT id, entry_date::TEXT AS entry_date
          FROM daily_entries
          WHERE id = ${serverId}::UUID AND patient_id = ${patientId}
          LIMIT 1
        `;
        if (entry) entryRefs.set(ref, entry);
        return entry ?? null;
      }

      for (const row of [
        ...(changes.daily_entry_triggers?.created ?? []),
        ...(changes.daily_entry_triggers?.updated ?? []),
      ]) {
        const entry = await resolveEntry(row.daily_entry_id);
        if (!entry) continue;
        const logId = uuidOrNull(row.server_id) ?? uuidOrNull(row.id);
        await sql`
          INSERT INTO trigger_logs (id, daily_entry_id, patient_id, trigger_id, entry_date, is_active, severity)
          VALUES (
            COALESCE(${logId}::UUID, gen_random_uuid()),
            ${entry.id}::UUID,
            ${patientId},
            ${(row.trigger_id as string)}::UUID,
            ${entry.entry_date},
            TRUE,
            ${(row.severity as number) ?? null}
          )
          ON CONFLICT (daily_entry_id, trigger_id) DO UPDATE
            SET is_active = EXCLUDED.is_active,
                severity = EXCLUDED.severity
        `;
      }

      for (const row of [
        ...(changes.daily_entry_symptoms?.created ?? []),
        ...(changes.daily_entry_symptoms?.updated ?? []),
      ]) {
        const entry = await resolveEntry(row.daily_entry_id);
        if (!entry) continue;
        const logId = uuidOrNull(row.server_id) ?? uuidOrNull(row.id);
        await sql`
          INSERT INTO symptom_logs (id, daily_entry_id, patient_id, symptom_id, entry_date, is_present, intensity)
          VALUES (
            COALESCE(${logId}::UUID, gen_random_uuid()),
            ${entry.id}::UUID,
            ${patientId},
            ${(row.symptom_id as string)}::UUID,
            ${entry.entry_date},
            TRUE,
            ${(row.severity as number) ?? null}
          )
          ON CONFLICT (daily_entry_id, symptom_id) DO UPDATE
            SET is_present = EXCLUDED.is_present,
                intensity = EXCLUDED.intensity
        `;
      }

      for (const row of [
        ...(changes.daily_entry_strategies?.created ?? []),
        ...(changes.daily_entry_strategies?.updated ?? []),
      ]) {
        const entry = await resolveEntry(row.daily_entry_id);
        if (!entry) continue;
        const logId = uuidOrNull(row.server_id) ?? uuidOrNull(row.id);
        const state = row.helped === false ? 'no' : 'yes';
        await sql`
          INSERT INTO wellness_logs (id, daily_entry_id, patient_id, strategy_id, entry_date, state)
          VALUES (
            COALESCE(${logId}::UUID, gen_random_uuid()),
            ${entry.id}::UUID,
            ${patientId},
            ${(row.strategy_id as string)}::UUID,
            ${entry.entry_date},
            ${state}
          )
          ON CONFLICT (daily_entry_id, strategy_id) DO UPDATE
            SET state = EXCLUDED.state
        `;
      }

      // -----------------------------------------------------------------------
      // Process journal_entries
      // -----------------------------------------------------------------------
      const journalCreated = changes.journal_entries?.created ?? [];
      const journalUpdated = changes.journal_entries?.updated ?? [];

      for (const row of journalCreated) {
        const entry = await resolveEntry(row.daily_entry_id);

        await sql`
          INSERT INTO journal_entries (patient_id, daily_entry_id, body, word_count, is_shared_with_care_team)
          VALUES (
            ${patientId},
            ${entry?.id ?? null},
            ${(row.body as string)},
            ${(row.word_count as number) ?? 0},
            ${Boolean(row.is_shared_with_care_team)}
          )
          ON CONFLICT DO NOTHING
        `;
      }

      for (const row of journalUpdated) {
        if (!row.server_id) continue;
        await sql`
          UPDATE journal_entries
          SET body = ${(row.body as string)},
              word_count = ${(row.word_count as number) ?? 0},
              is_shared_with_care_team = ${Boolean(row.is_shared_with_care_team)}
          WHERE id = ${(row.server_id as string)} AND patient_id = ${patientId}
        `;
      }

      await auditLog({
        actor: user,
        action: 'create',
        resourceType: 'sync_push',
        resourceId: patientId,
      });

      return reply.send({ success: true });
    },
  );
}

export default syncRoutes;
