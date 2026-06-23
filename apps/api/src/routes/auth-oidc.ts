// =============================================================================
// COPE API — Authentik OIDC SSO routes (ADDITIVE — does not touch auth.ts)
// GET  /api/v1/auth/providers       — advertises which sign-in methods are live
// GET  /api/v1/auth/oidc/redirect   — start the Authorization-Code + PKCE flow
// GET  /api/v1/auth/oidc/callback   — exchange code, validate id_token, reconcile
// POST /api/v1/auth/oidc/exchange   — SPA swaps one-time code for a COPE session
//
// The handshake hands the COPE session (same shape as POST /auth/login) to the
// SPA via a one-time code, so tokens never ride in a URL. Local bcrypt + MFA
// auth in auth.ts is untouched; this is purely additional.
// =============================================================================

import type { FastifyInstance } from 'fastify';
import { sql } from '@cope/db';
import { config } from '../config.js';
import { auditLog } from '../middleware/audit.js';
import { issueRefreshToken } from '../services/refresh-tokens.js';
import type { JwtPayload } from '../plugins/auth.js';
import {
  getOidcProviderConfig,
  isOidcPubliclyAvailable,
} from '../services/auth/oidc/providerConfig.js';
import { fetchOidcDiscovery } from '../services/auth/oidc/discovery.js';
import { validateOidcIdToken } from '../services/auth/oidc/tokenValidator.js';
import {
  consumeHandshake,
  generateNonce,
  generatePkceVerifier,
  sha256Base64Url,
  storeHandshake,
} from '../services/auth/oidc/handshakeStore.js';
import {
  OidcAccessDeniedError,
  reconcileOidcUser,
} from '../services/auth/oidc/reconciliation.js';

const RATE_LIMIT = { config: { rateLimit: { max: 20, timeWindow: '1 minute' } } };

export default async function authOidcRoutes(fastify: FastifyInstance): Promise<void> {
  // ---------------------------------------------------------------------------
  // GET /providers — which sign-in methods this deployment offers
  // ---------------------------------------------------------------------------
  fastify.get('/providers', async () => {
    const provider = getOidcProviderConfig();
    const oidcEnabled = isOidcPubliclyAvailable(provider);

    return {
      success: true,
      data: {
        local_enabled: true,
        oidc_enabled: oidcEnabled,
        oidc_label: oidcEnabled ? provider.label : null,
        oidc_redirect_path: oidcEnabled ? '/auth/oidc/redirect' : null,
      },
    };
  });

  // ---------------------------------------------------------------------------
  // GET /oidc/redirect — kick off Authorization Code + PKCE
  // ---------------------------------------------------------------------------
  fastify.get('/oidc/redirect', RATE_LIMIT, async (_request, reply) => {
    const provider = getOidcProviderConfig();
    if (!isOidcPubliclyAvailable(provider)) {
      return reply.status(404).send({
        success: false,
        error: { code: 'OIDC_DISABLED', message: 'OIDC sign-in is not enabled' },
      });
    }

    const discovery = await fetchOidcDiscovery(provider.discoveryUrl);
    const codeVerifier = generatePkceVerifier();
    const nonce = generateNonce();
    const state = await storeHandshake('state', { nonce, codeVerifier }, provider.stateTtlSeconds);

    const authorizeUrl = new URL(discovery.authorization_endpoint);
    authorizeUrl.searchParams.set('response_type', 'code');
    authorizeUrl.searchParams.set('client_id', provider.clientId);
    authorizeUrl.searchParams.set('redirect_uri', provider.redirectUri);
    authorizeUrl.searchParams.set('scope', provider.scopes.join(' '));
    authorizeUrl.searchParams.set('state', state);
    authorizeUrl.searchParams.set('nonce', nonce);
    authorizeUrl.searchParams.set('code_challenge', sha256Base64Url(codeVerifier));
    authorizeUrl.searchParams.set('code_challenge_method', 'S256');

    return reply.redirect(authorizeUrl.toString());
  });

  // ---------------------------------------------------------------------------
  // GET /oidc/callback — exchange code, validate, reconcile, mint exchange code
  // ---------------------------------------------------------------------------
  fastify.get('/oidc/callback', RATE_LIMIT, async (request, reply) => {
    const query = request.query as {
      code?: string;
      state?: string;
      error?: string;
    };

    if (query.error) {
      return reply.redirect(`${config.webAppUrl}/login?oidc_error=${encodeURIComponent(query.error)}`);
    }
    if (!query.code || !query.state) {
      return reply.status(400).send({
        success: false,
        error: { code: 'OIDC_BAD_CALLBACK', message: 'OIDC callback is missing code or state' },
      });
    }

    const statePayload = await consumeHandshake<{ nonce: string; codeVerifier: string }>(
      query.state,
      'state',
    );
    if (!statePayload) {
      return reply.status(400).send({
        success: false,
        error: { code: 'OIDC_STATE_INVALID', message: 'OIDC state is invalid or expired' },
      });
    }

    const provider = getOidcProviderConfig();
    if (!isOidcPubliclyAvailable(provider)) {
      return reply.status(404).send({
        success: false,
        error: { code: 'OIDC_DISABLED', message: 'OIDC sign-in is not enabled' },
      });
    }

    const discovery = await fetchOidcDiscovery(provider.discoveryUrl);
    const form = new URLSearchParams({
      grant_type: 'authorization_code',
      code: query.code,
      redirect_uri: provider.redirectUri,
      client_id: provider.clientId,
      code_verifier: statePayload.codeVerifier,
    });
    if (provider.clientSecret) {
      form.set('client_secret', provider.clientSecret);
    }

    const tokenResponse = await fetch(discovery.token_endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: form,
    });

    if (!tokenResponse.ok) {
      fastify.log.warn({ status: tokenResponse.status }, '[oidc] token exchange failed');
      return reply.redirect(`${config.webAppUrl}/login?oidc_error=token_exchange_failed`);
    }

    const tokenBody = (await tokenResponse.json()) as { id_token?: string };
    if (!tokenBody.id_token) {
      return reply.redirect(`${config.webAppUrl}/login?oidc_error=missing_id_token`);
    }

    try {
      const claims = await validateOidcIdToken(
        tokenBody.id_token,
        discovery,
        provider,
        statePayload.nonce,
      );
      const user = await reconcileOidcUser(claims, provider);
      const exchangeCode = await storeHandshake(
        'exchange',
        { userId: user.id },
        provider.exchangeTtlSeconds,
      );

      await auditLog({
        actor: { sub: user.id, email: user.email, role: 'clinician', org_id: user.organisation_id },
        action: 'login',
        resourceType: 'auth',
        resourceId: user.id,
        ipAddress: request.ip,
        userAgent: request.headers['user-agent'],
        newValues: { provider: 'authentik' },
      });

      return reply.redirect(`${config.webAppUrl}/auth/callback?code=${encodeURIComponent(exchangeCode)}`);
    } catch (err) {
      const code = err instanceof OidcAccessDeniedError ? 'access_denied' : 'validation_failed';
      fastify.log.warn({ err }, '[oidc] callback validation failed');
      return reply.redirect(`${config.webAppUrl}/login?oidc_error=${code}`);
    }
  });

  // ---------------------------------------------------------------------------
  // POST /oidc/exchange — SPA trades the one-time code for a COPE session
  // Returns the same shape as POST /auth/login.
  // ---------------------------------------------------------------------------
  fastify.post('/oidc/exchange', RATE_LIMIT, async (request, reply) => {
    const body = request.body as { code?: string };
    if (!body?.code) {
      return reply.status(400).send({
        success: false,
        error: { code: 'MISSING_CODE', message: 'code is required' },
      });
    }

    const payload = await consumeHandshake<{ userId: string }>(body.code, 'exchange');
    if (!payload) {
      return reply.status(400).send({
        success: false,
        error: { code: 'CODE_INVALID', message: 'OIDC exchange code is invalid or expired' },
      });
    }

    const [clinician] = await sql<{
      id: string;
      email: string;
      organisation_id: string;
      role: string;
      must_change_password: boolean;
    }[]>`
      SELECT id, email, organisation_id, role, must_change_password
      FROM clinicians
      WHERE id = ${payload.userId}::uuid AND is_active = TRUE
      LIMIT 1
    `;

    if (!clinician) {
      return reply.status(404).send({
        success: false,
        error: { code: 'USER_NOT_FOUND', message: 'Account not found or disabled' },
      });
    }

    // Admins land in the admin experience; everyone else is a clinician session.
    const jwtRole: JwtPayload['role'] = clinician.role === 'admin' ? 'admin' : 'clinician';
    const accessToken = fastify.jwt.sign(
      {
        sub: clinician.id,
        email: clinician.email,
        role: jwtRole,
        org_id: clinician.organisation_id,
      } satisfies JwtPayload,
      { expiresIn: config.jwtAccessExpiry },
    );
    const refreshToken = await issueRefreshToken({
      userId: clinician.id,
      role: jwtRole,
      orgId: clinician.organisation_id,
    });

    await sql`UPDATE clinicians SET last_login_at = NOW() WHERE id = ${clinician.id}`;

    await auditLog({
      actor: { sub: clinician.id, email: clinician.email, role: jwtRole, org_id: clinician.organisation_id },
      action: 'login',
      resourceType: 'auth',
      resourceId: clinician.id,
      ipAddress: request.ip,
      userAgent: request.headers['user-agent'],
      newValues: { provider: 'authentik', step: 'exchange' },
    });

    return reply.send({
      success: true,
      data: {
        access_token: accessToken,
        refresh_token: refreshToken,
        clinician_id: clinician.id,
        org_id: clinician.organisation_id,
        role: clinician.role,
        must_change_password: clinician.must_change_password,
        user: {
          id: clinician.id,
          email: clinician.email,
          role: clinician.role,
          org_id: clinician.organisation_id,
          must_change_password: clinician.must_change_password,
        },
      },
    });
  });
}
