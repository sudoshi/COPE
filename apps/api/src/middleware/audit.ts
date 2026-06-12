// =============================================================================
// COPE API — Audit logging middleware
// Call auditLog() inside route handlers for HIPAA audit trail.
// =============================================================================

import { sql } from '@cope/db';
import type { JwtPayload } from '../plugins/auth.js';

export type AuditAction =
  | 'read'
  | 'create'
  | 'update'
  | 'delete'
  | 'export'
  | 'share'
  | 'acknowledge'
  | 'login'
  | 'logout'
  | 'consent_granted'
  | 'consent_revoked';

interface AuditLogParams {
  actor: JwtPayload;
  action: AuditAction;
  resourceType: string;
  resourceId?: string | undefined;
  patientId?: string | undefined;
  ipAddress?: string | undefined;
  userAgent?: string | undefined;
  oldValues?: Record<string, unknown> | undefined;
  newValues?: Record<string, unknown> | undefined;
  success?: boolean | undefined;
  failureReason?: string | undefined;
}

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Unauthenticated events (e.g. failed logins) carry sentinel actor values like
 * 'unknown' — store NULL rather than violating the uuid columns.
 */
function asUuidOrNull(value: string): string | null {
  return UUID_RE.test(value) ? value : null;
}

/**
 * Write an entry to the HIPAA audit_log table.
 * Fire-and-forget — errors are swallowed to avoid disrupting the primary operation.
 * Critical failures should be caught by log monitoring (Pino → CloudWatch/Datadog).
 */
export async function auditLog(params: AuditLogParams): Promise<void> {
  try {
    await sql`
      INSERT INTO audit_log (
        organisation_id, actor_type, actor_id,
        action, resource_type, resource_id, patient_id,
        ip_address, user_agent,
        old_values, new_values,
        success, failure_reason
      ) VALUES (
        ${asUuidOrNull(params.actor.org_id)},
        ${params.actor.role === 'admin' ? 'admin' : params.actor.role},
        ${asUuidOrNull(params.actor.sub)},
        ${params.action},
        ${params.resourceType},
        ${params.resourceId ?? null},
        ${params.patientId ?? null},
        ${params.ipAddress ?? null},
        ${params.userAgent ?? null},
        ${params.oldValues ? sql.json(params.oldValues as Parameters<typeof sql.json>[0]) : null},
        ${params.newValues ? sql.json(params.newValues as Parameters<typeof sql.json>[0]) : null},
        ${params.success ?? true},
        ${params.failureReason ?? null}
      )
    `;
  } catch (err) {
    // Do not surface to caller, but keep the cause — a silent audit gap is a
    // HIPAA monitoring blind spot (this exact catch hid a uuid violation that
    // dropped every failed-login audit entry).
    console.error('[audit] Failed to write audit log entry:', err);
  }
}
