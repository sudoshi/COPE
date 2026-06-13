// =============================================================================
// COPE API — First-party refresh tokens (PostgreSQL-backed)
// Opaque 256-bit tokens, stored as sha256 hashes, rotated on every use.
// Presenting an already-rotated token is treated as theft: every session for
// that user is revoked (RFC 6819 refresh-token reuse detection).
// =============================================================================

import { createHash, randomBytes } from 'node:crypto';
import { sql } from '@cope/db';
import { config } from '../config.js';

export type RefreshableRole = 'clinician' | 'patient' | 'admin';

export interface RefreshTokenOwner {
  userId: string;
  role: RefreshableRole;
  orgId: string | null;
}

export function hashToken(rawToken: string): string {
  return createHash('sha256').update(rawToken).digest('hex');
}

/** '15m' / '7d' style durations (as used for JWT_*_EXPIRY) → seconds. */
export function parseDurationSeconds(duration: string): number {
  const match = /^(\d+)([smhd])$/.exec(duration.trim());
  if (!match) {
    throw new Error(`Unsupported duration format: ${duration}`);
  }
  const value = Number(match[1]);
  const unit = match[2] as 's' | 'm' | 'h' | 'd';
  const multiplier = { s: 1, m: 60, h: 3600, d: 86400 }[unit];
  return value * multiplier;
}

export async function issueRefreshToken(owner: RefreshTokenOwner): Promise<string> {
  const rawToken = randomBytes(32).toString('base64url');
  const ttlSeconds = parseDurationSeconds(config.jwtRefreshExpiry);

  await sql`
    INSERT INTO refresh_tokens (user_id, user_role, org_id, token_hash, expires_at)
    VALUES (
      ${owner.userId},
      ${owner.role},
      ${owner.orgId},
      ${hashToken(rawToken)},
      NOW() + ${ttlSeconds} * INTERVAL '1 second'
    )
  `;

  return rawToken;
}

export interface RotationResult {
  owner: RefreshTokenOwner;
  newToken: string;
}

/**
 * Validate a presented refresh token and rotate it. Returns null when the
 * token is unknown, expired, or revoked. A revoked (already-used) token also
 * revokes every live session for its user.
 */
export async function rotateRefreshToken(rawToken: string): Promise<RotationResult | null> {
  const [existing] = await sql<{
    id: string; user_id: string; user_role: RefreshableRole; org_id: string | null;
    expired: boolean; revoked: boolean;
  }[]>`
    SELECT id, user_id, user_role, org_id,
           (expires_at <= NOW())     AS expired,
           (revoked_at IS NOT NULL)  AS revoked
    FROM refresh_tokens
    WHERE token_hash = ${hashToken(rawToken)}
    LIMIT 1
  `;

  if (!existing) return null;

  if (existing.revoked) {
    // Reuse of a rotated token — assume compromise, kill all sessions.
    await revokeAllForUser(existing.user_id);
    return null;
  }
  if (existing.expired) return null;

  const owner: RefreshTokenOwner = {
    userId: existing.user_id,
    role: existing.user_role,
    orgId: existing.org_id,
  };
  const newToken = await issueRefreshToken(owner);

  await sql`
    UPDATE refresh_tokens
    SET revoked_at = NOW(),
        replaced_by = (SELECT id FROM refresh_tokens WHERE token_hash = ${hashToken(newToken)})
    WHERE id = ${existing.id}
  `;

  return { owner, newToken };
}

export async function revokeAllForUser(userId: string): Promise<void> {
  await sql`
    UPDATE refresh_tokens
    SET revoked_at = NOW()
    WHERE user_id = ${userId} AND revoked_at IS NULL
  `;
}
