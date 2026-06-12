// =============================================================================
// COPE API — Audit middleware tests
// Failed logins audit with sentinel actor values ('unknown'); these must be
// stored as NULL, not rejected by the uuid columns. A regression here silently
// drops the audit trail for the most security-relevant events.
// =============================================================================

import { describe, it, expect, vi, beforeEach } from 'vitest';

const sqlMock = vi.hoisted(() => {
  const fn = vi.fn(() => Promise.resolve([])) as ReturnType<typeof vi.fn> & {
    json: (v: unknown) => unknown;
  };
  fn.json = (v: unknown) => v; // pass-through stand-in for sql.json()
  return fn;
});
vi.mock('@cope/db', () => ({ sql: sqlMock }));

import { auditLog } from './audit.js';

// Interpolation order inside the INSERT — keep in sync with audit.ts.
const ARG = { ORG_ID: 1, ACTOR_TYPE: 2, ACTOR_ID: 3, NEW_VALUES: 11, SUCCESS: 12 } as const;

const CLINICIAN_ID = '7c9e6679-7425-40de-944b-e07fc1f90ae7';
const ORG_ID = 'f46cc7e7-163a-4291-acc3-148044a5b232';

describe('auditLog', () => {
  beforeEach(() => {
    sqlMock.mockClear();
    sqlMock.mockImplementation(() => Promise.resolve([]));
  });

  it('stores NULL actor/org for unauthenticated events instead of invalid uuids', async () => {
    await auditLog({
      actor: { sub: 'unknown', email: 'a@b.c', role: 'clinician', org_id: 'unknown' },
      action: 'login',
      resourceType: 'auth',
      newValues: { attempted_email: 'a@b.c' },
      success: false,
      failureReason: 'invalid_credentials',
    });

    expect(sqlMock).toHaveBeenCalledTimes(1);
    const args = sqlMock.mock.calls[0] as unknown[];
    expect(args[ARG.ORG_ID]).toBeNull();
    expect(args[ARG.ACTOR_ID]).toBeNull();
    expect(args[ARG.ACTOR_TYPE]).toBe('clinician');
    // Passed as a raw object — postgres.js owns JSON serialization. A manual
    // JSON.stringify here gets stringified AGAIN and lands as a jsonb string.
    expect(args[ARG.NEW_VALUES]).toEqual({ attempted_email: 'a@b.c' });
    expect(args[ARG.SUCCESS]).toBe(false);
  });

  it('passes real uuids through unchanged for authenticated events', async () => {
    await auditLog({
      actor: { sub: CLINICIAN_ID, email: 'a@b.c', role: 'admin', org_id: ORG_ID },
      action: 'login',
      resourceType: 'auth',
      resourceId: CLINICIAN_ID,
    });

    const args = sqlMock.mock.calls[0] as unknown[];
    expect(args[ARG.ORG_ID]).toBe(ORG_ID);
    expect(args[ARG.ACTOR_ID]).toBe(CLINICIAN_ID);
    expect(args[ARG.ACTOR_TYPE]).toBe('admin');
    expect(args[ARG.SUCCESS]).toBe(true);
  });

  it('swallows database errors but logs the cause', async () => {
    sqlMock.mockImplementation(() => Promise.reject(new Error('db down')));
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => undefined);

    await expect(
      auditLog({
        actor: { sub: CLINICIAN_ID, email: 'a@b.c', role: 'clinician', org_id: ORG_ID },
        action: 'read',
        resourceType: 'patient',
      }),
    ).resolves.toBeUndefined();

    expect(consoleSpy).toHaveBeenCalledWith(
      '[audit] Failed to write audit log entry:',
      expect.any(Error),
    );
    consoleSpy.mockRestore();
  });
});
