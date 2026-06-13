// =============================================================================
// COPE API — Vitest setup
// config.ts validates required env vars at import time; provide test defaults
// for any not already supplied.
// =============================================================================

process.env['DATABASE_URL'] ??= 'postgresql://test:test@localhost:5432/cope_test';
process.env['JWT_SECRET'] ??= 'vitest-jwt-secret-not-for-production';
process.env['NODE_ENV'] ??= 'test';
