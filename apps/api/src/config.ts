// =============================================================================
// COPE API — Environment configuration
// All env vars are validated at startup. Missing required vars cause a crash.
// =============================================================================

function required(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

function optional(key: string, fallback: string): string {
  return process.env[key] ?? fallback;
}

function optionalBool(key: string, fallback: boolean): boolean {
  const val = process.env[key];
  if (val === undefined) return fallback;
  return val === 'true';
}

function optionalList(key: string, fallback: string[]): string[] {
  const val = process.env[key];
  if (val === undefined) return fallback;
  return val.split(',').map((item) => item.trim()).filter(Boolean);
}

export const config = {
  // Server
  port: Number(optional('API_PORT', '3000')),
  host: optional('API_HOST', '0.0.0.0'),
  nodeEnv: optional('NODE_ENV', 'development'),
  corsOrigin: optional('CORS_ORIGIN', 'http://localhost:5173'),

  // Database
  databaseUrl: required('DATABASE_URL'),

  // Auth
  jwtSecret: required('JWT_SECRET'),
  jwtAccessExpiry: optional('JWT_ACCESS_EXPIRY', '15m'),
  jwtRefreshExpiry: optional('JWT_REFRESH_EXPIRY', '7d'),

  // Authentik OIDC SSO (additive — local bcrypt auth remains primary).
  // The "Login with Authentik" button only appears when enabled + client_id +
  // discovery_url + redirect_uri are all set.
  oidcEnabled: optionalBool('OIDC_ENABLED', false),
  oidcLabel: optional('OIDC_LABEL', 'Authentik'),
  oidcDiscoveryUrl: process.env['OIDC_DISCOVERY_URL'] ?? '',
  oidcClientId: process.env['OIDC_CLIENT_ID'] ?? '',
  oidcClientSecret: process.env['OIDC_CLIENT_SECRET'] ?? '',
  oidcRedirectUri: optional('OIDC_REDIRECT_URI', 'http://localhost:3000/api/v1/auth/oidc/callback'),
  oidcScopes: optionalList('OIDC_SCOPES', ['openid', 'profile', 'email', 'groups']),
  oidcAllowedGroups: optionalList('OIDC_ALLOWED_GROUPS', ['COPE Admins']),
  oidcAdminGroups: optionalList('OIDC_ADMIN_GROUPS', ['COPE Admins']),
  oidcStateTtlSeconds: Number(optional('OIDC_STATE_TTL_SECONDS', '300')),
  oidcExchangeTtlSeconds: Number(optional('OIDC_EXCHANGE_TTL_SECONDS', '60')),

  // Local file storage (reports, research exports) — replaces Supabase Storage
  storageDir: optional('STORAGE_DIR', './storage'),
  // Prefix for signed download URLs; empty = relative (web + API share an origin)
  apiPublicUrl: optional('API_PUBLIC_URL', ''),

  // Redis
  redisUrl: optional('REDIS_URL', 'redis://localhost:6379'),

  // Compliance gates — NEVER enable without BAA in place
  aiInsightsEnabled: optionalBool('AI_INSIGHTS_ENABLED', false),
  anthropicBaaSigned: optionalBool('ANTHROPIC_BAA_SIGNED', false),

  // AI provider: 'anthropic' (cloud, requires BAA) or 'ollama' (local, no BAA)
  aiProvider: optional('AI_PROVIDER', 'anthropic') as 'anthropic' | 'ollama',

  // Anthropic (gated — only used if both flags above are true)
  anthropicApiKey: process.env['ANTHROPIC_API_KEY'] ?? '',
  anthropicModel: optional('ANTHROPIC_MODEL', 'claude-sonnet-4-5-20250929'),

  // Ollama (local inference — no BAA required, data never leaves the machine)
  ollamaBaseUrl: optional('OLLAMA_BASE_URL', 'http://localhost:11434'),
  ollamaModel: optional('OLLAMA_MODEL', 'alibayram/medgemma:27b'),

  // Notifications — Expo Push + Resend email
  expoPushAccessToken: process.env['EXPO_PUSH_ACCESS_TOKEN'] ?? process.env['EXPO_ACCESS_TOKEN'] ?? '',
  resendApiKey: process.env['RESEND_API_KEY'] ?? '',
  emailFrom: optional('EMAIL_FROM', 'alerts@cope.app'),
  webAppUrl: optional('WEB_APP_URL', 'http://localhost:5173'),

  // Observability
  sentryDsn: process.env['SENTRY_DSN'] ?? '',

  // Crisis resources (US)
  crisisLinePhone: optional('CRISIS_LINE_PHONE', '988'),
  crisisTextNumber: optional('CRISIS_TEXT_NUMBER', '741741'),

  get isDev(): boolean {
    return this.nodeEnv === 'development';
  },
  get isProd(): boolean {
    return this.nodeEnv === 'production';
  },
} as const;
