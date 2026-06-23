// =============================================================================
// COPE API — OIDC provider configuration (Authentik SSO)
// Env-driven (see config.ts). OIDC is additive: local bcrypt auth stays primary
// and is unaffected. The button only appears when this provider is "publicly
// available" (enabled + discovery_url + client_id + redirect_uri all set).
// =============================================================================

import { config } from '../../../config.js';

export interface OidcProviderConfig {
  enabled: boolean;
  label: string;
  discoveryUrl: string;
  clientId: string;
  clientSecret: string;
  redirectUri: string;
  scopes: string[];
  allowedGroups: string[];
  adminGroups: string[];
  stateTtlSeconds: number;
  exchangeTtlSeconds: number;
}

export function getOidcProviderConfig(): OidcProviderConfig {
  return {
    enabled: config.oidcEnabled,
    label: config.oidcLabel,
    discoveryUrl: config.oidcDiscoveryUrl,
    clientId: config.oidcClientId,
    clientSecret: config.oidcClientSecret,
    redirectUri: config.oidcRedirectUri,
    scopes: config.oidcScopes,
    allowedGroups: config.oidcAllowedGroups,
    adminGroups: config.oidcAdminGroups,
    stateTtlSeconds: config.oidcStateTtlSeconds,
    exchangeTtlSeconds: config.oidcExchangeTtlSeconds,
  };
}

export function isOidcPubliclyAvailable(provider: OidcProviderConfig): boolean {
  return Boolean(
    provider.enabled &&
    provider.discoveryUrl &&
    provider.clientId &&
    provider.redirectUri,
  );
}
