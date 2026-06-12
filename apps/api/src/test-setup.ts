// =============================================================================
// MindLog API — Vitest setup
// config.ts validates required env vars at import time; provide test defaults
// for any not already supplied (CI sets DATABASE_URL/REDIS_URL/JWT_SECRET but
// not the Supabase pair).
// =============================================================================

process.env['DATABASE_URL'] ??= 'postgresql://test:test@localhost:5432/mindlog_test';
process.env['JWT_SECRET'] ??= 'vitest-jwt-secret-not-for-production';
process.env['SUPABASE_URL'] ??= 'http://127.0.0.1:54321';
process.env['SUPABASE_SERVICE_ROLE_KEY'] ??= 'vitest-service-role-key';
process.env['NODE_ENV'] ??= 'test';
