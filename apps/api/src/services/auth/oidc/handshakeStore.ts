// =============================================================================
// COPE API — OIDC handshake store (Authentik SSO)
// Single-use, TTL'd server-side artifacts:
//   - 'state'    → { nonce, codeVerifier }  (outbound authorize request)
//   - 'exchange' → { userId }               (one-time SPA token-exchange code)
// Backed by the unauthenticated `oidc_handshakes` table (no RLS).
// =============================================================================

import { sql } from '@cope/db';
import crypto from 'node:crypto';

type HandshakeKind = 'state' | 'exchange';

function token(): string {
  return crypto.randomBytes(32).toString('base64url');
}

export function sha256Base64Url(value: string): string {
  return crypto.createHash('sha256').update(value).digest('base64url');
}

export async function storeHandshake(
  kind: HandshakeKind,
  payload: Record<string, unknown>,
  ttlSeconds: number,
): Promise<string> {
  const id = token();
  const expiresAt = new Date(Date.now() + ttlSeconds * 1000);

  await sql`
    INSERT INTO oidc_handshakes (id, kind, payload, expires_at)
    VALUES (${id}, ${kind}, ${JSON.stringify(payload)}::jsonb, ${expiresAt.toISOString()})
  `;

  return id;
}

export async function consumeHandshake<T extends Record<string, unknown>>(
  id: string,
  kind: HandshakeKind,
): Promise<T | null> {
  const [row] = await sql<{ payload: T }[]>`
    DELETE FROM oidc_handshakes
    WHERE id = ${id}
      AND kind = ${kind}
      AND expires_at > NOW()
    RETURNING payload
  `;

  return row?.payload ?? null;
}

export function generatePkceVerifier(): string {
  return token();
}

export function generateNonce(): string {
  return token();
}
