// =============================================================================
// COPE API — OIDC user reconciliation (Authentik SSO)
// Resolves an Authentik identity to a COPE `clinicians` row inside one tx:
//   1. by linked provider_subject (sub)
//   2. by email match
//   3. JIT-create under the "Acumenus" org (group-gated)
// Group mapping: members of an admin group get clinicians.role = 'admin'.
// super-admin equivalents are never minted via SSO — the dev/local admin path
// remains the break-glass tier. Local bcrypt auth is untouched (additive).
// =============================================================================

import { sql } from '@cope/db';
import crypto from 'node:crypto';
import bcrypt from 'bcryptjs';
import type { OidcProviderConfig } from './providerConfig.js';
import type { ValidatedOidcClaims } from './tokenValidator.js';

export class OidcAccessDeniedError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'OidcAccessDeniedError';
  }
}

export interface ReconciledOidcUser {
  id: string;
  email: string;
  organisation_id: string;
  role: string;
  mfa_enabled: boolean;
  must_change_password: boolean;
  is_active: boolean;
}

// Org that owns JIT-provisioned SSO administrators.
const ADMIN_ORG_NAME = 'Acumenus';

const CLINICIAN_COLUMNS =
  'id, email, organisation_id, role, mfa_enabled, must_change_password, is_active';

function groupMatches(userGroups: string[], allowedGroups: string[]): boolean {
  const normalized = new Set(userGroups.map((g) => g.toLowerCase()));
  return allowedGroups.some((g) => normalized.has(g.toLowerCase()));
}

function splitName(name: string, email: string): { firstName: string; lastName: string } {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) {
    return { firstName: email.split('@')[0] ?? 'User', lastName: 'SSO' };
  }
  if (parts.length === 1) {
    return { firstName: parts[0] ?? 'User', lastName: 'SSO' };
  }
  return { firstName: parts[0] ?? 'User', lastName: parts.slice(1).join(' ') };
}

async function unusablePasswordHash(): Promise<string> {
  return bcrypt.hash(`oidc:${crypto.randomUUID()}:${crypto.randomBytes(24).toString('hex')}`, 12);
}

export async function reconcileOidcUser(
  claims: ValidatedOidcClaims,
  provider: OidcProviderConfig,
): Promise<ReconciledOidcUser> {
  const isAllowed = groupMatches(claims.groups, provider.allowedGroups);
  const isAdmin = groupMatches(claims.groups, provider.adminGroups);

  if (!isAllowed && !isAdmin) {
    throw new OidcAccessDeniedError('OIDC user is not a member of an allowed COPE group');
  }

  return sql.begin(async (tx) => {
    // 1. Match by linked provider subject.
    let [user] = (await tx.unsafe(
      `
      SELECT c.id, c.email, c.organisation_id, c.role, c.mfa_enabled,
             c.must_change_password, c.is_active
      FROM user_external_identities x
      JOIN clinicians c ON c.id = x.user_id
      WHERE x.provider_type = $1 AND x.provider_subject = $2
      LIMIT 1
      `,
      ['authentik', claims.sub],
    )) as ReconciledOidcUser[];

    // 2. Match by email.
    if (!user) {
      [user] = (await tx.unsafe(
        `SELECT ${CLINICIAN_COLUMNS} FROM clinicians WHERE lower(email) = lower($1) LIMIT 1`,
        [claims.email],
      )) as ReconciledOidcUser[];
    }

    if (user && !user.is_active) {
      throw new OidcAccessDeniedError('OIDC user maps to an inactive COPE account');
    }

    // 3. JIT-create under the Acumenus org.
    if (!user) {
      const [org] = (await tx.unsafe(
        `SELECT id FROM organisations WHERE name = $1 LIMIT 1`,
        [ADMIN_ORG_NAME],
      )) as { id: string }[];

      let orgId = org?.id;
      if (!orgId) {
        const [created] = (await tx.unsafe(
          `
          INSERT INTO organisations (name, type, country, timezone, locale)
          VALUES ($1, 'research', 'US', 'America/New_York', 'en-US')
          RETURNING id
          `,
          [ADMIN_ORG_NAME],
        )) as { id: string }[];
        if (!created) throw new Error('Failed to create Acumenus organisation for SSO admins');
        orgId = created.id;
      }

      const { firstName, lastName } = splitName(claims.name, claims.email);
      const role = isAdmin ? 'admin' : 'researcher';
      const passwordHash = await unusablePasswordHash();

      [user] = (await tx.unsafe(
        `
        INSERT INTO clinicians (
          organisation_id, email, first_name, last_name, role,
          password_hash, must_change_password, is_active, mfa_enabled
        )
        VALUES ($1::uuid, $2, $3, $4, $5, $6, FALSE, TRUE, FALSE)
        RETURNING ${CLINICIAN_COLUMNS}
        `,
        [orgId, claims.email, firstName, lastName, role, passwordHash],
      )) as ReconciledOidcUser[];
    }

    if (!user) {
      throw new Error('OIDC reconciliation failed to resolve or create a clinician');
    }

    // Promote existing non-admins who are in an admin group.
    if (isAdmin && user.role !== 'admin') {
      const [promoted] = (await tx.unsafe(
        `UPDATE clinicians SET role = 'admin', updated_at = NOW()
         WHERE id = $1::uuid RETURNING ${CLINICIAN_COLUMNS}`,
        [user.id],
      )) as ReconciledOidcUser[];
      user = promoted ?? user;
    }

    // Link / refresh the external identity.
    await tx.unsafe(
      `
      INSERT INTO user_external_identities (
        user_id, provider_type, provider_subject, email_at_link, claims, last_login_at
      )
      VALUES ($1::uuid, 'authentik', $2, $3, $4::jsonb, NOW())
      ON CONFLICT (provider_type, provider_subject)
      DO UPDATE SET
        user_id = EXCLUDED.user_id,
        email_at_link = EXCLUDED.email_at_link,
        claims = EXCLUDED.claims,
        last_login_at = NOW(),
        updated_at = NOW()
      `,
      [
        user.id,
        claims.sub,
        claims.email,
        JSON.stringify({ email: claims.email, name: claims.name, groups: claims.groups }),
      ],
    );

    await tx.unsafe(`UPDATE clinicians SET last_login_at = NOW() WHERE id = $1::uuid`, [user.id]);

    return user;
  });
}
