// =============================================================================
// COPE API — Error handler plugin tests
// Verifies status-code mapping: validation → 4xx, infrastructure → 503,
// unexpected → 500. The 503 mapping is load-bearing: clients retry on 503 but
// surface 500 as a hard failure, and the login UI distinguishes the two.
// =============================================================================

import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import Fastify, { type FastifyInstance } from 'fastify';
import { z } from 'zod';
import errorHandlerPlugin from './error-handler.js';

/** Mimics the shape postgres.js gives its errors (name + SQLSTATE code). */
class FakePostgresError extends Error {
  code: string;

  constructor(code: string) {
    super(`postgres error ${code}`);
    this.name = 'PostgresError';
    this.code = code;
  }
}

function throwWithStatus(message: string, statusCode: number): never {
  const err = new Error(message) as Error & { statusCode: number };
  err.statusCode = statusCode;
  throw err;
}

describe('error-handler plugin', () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    app = Fastify({ logger: false });
    await app.register(errorHandlerPlugin);

    app.get('/zod', () => z.object({ email: z.string() }).parse({}));
    app.get('/client-error', () => throwWithStatus('nope', 404));
    app.get('/db-auth-failure', () => {
      throw new FakePostgresError('28P01'); // invalid_password
    });
    app.get('/db-conn-failure', () => {
      throw new FakePostgresError('08006'); // connection_failure
    });
    app.get('/db-shutdown', () => {
      throw new FakePostgresError('57P01'); // admin_shutdown
    });
    app.get('/db-schema-bug', () => {
      throw new FakePostgresError('42P01'); // undefined_table — a code bug, NOT an outage
    });
    app.get('/upstream-down', () => {
      throw new TypeError('fetch failed: getaddrinfo ENOTFOUND example.supabase.co');
    });
    app.get('/boom', () => {
      throw new Error('something unexpected');
    });

    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it('maps ZodError to 422 VALIDATION_ERROR', async () => {
    const res = await app.inject({ method: 'GET', url: '/zod' });
    expect(res.statusCode).toBe(422);
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
  });

  it('passes through client errors with their status code', async () => {
    const res = await app.inject({ method: 'GET', url: '/client-error' });
    expect(res.statusCode).toBe(404);
    expect(res.json().error.code).toBe('CLIENT_ERROR');
  });

  it.each([
    ['28P01 invalid password', '/db-auth-failure'],
    ['08006 connection failure', '/db-conn-failure'],
    ['57P01 admin shutdown', '/db-shutdown'],
  ])('maps %s to 503 DATABASE_UNAVAILABLE', async (_label, url) => {
    const res = await app.inject({ method: 'GET', url });
    expect(res.statusCode).toBe(503);
    expect(res.json().error.code).toBe('DATABASE_UNAVAILABLE');
  });

  it('does NOT mask schema bugs (42P01) as outages — stays 500', async () => {
    const res = await app.inject({ method: 'GET', url: '/db-schema-bug' });
    expect(res.statusCode).toBe(500);
    expect(res.json().error.code).toBe('INTERNAL_SERVER_ERROR');
  });

  it('maps undici fetch failures to 503 UPSTREAM_UNAVAILABLE', async () => {
    const res = await app.inject({ method: 'GET', url: '/upstream-down' });
    expect(res.statusCode).toBe(503);
    expect(res.json().error.code).toBe('UPSTREAM_UNAVAILABLE');
  });

  it('returns a generic 500 for unexpected errors without leaking the message', async () => {
    const res = await app.inject({ method: 'GET', url: '/boom' });
    expect(res.statusCode).toBe(500);
    const body = res.json();
    expect(body.error.code).toBe('INTERNAL_SERVER_ERROR');
    expect(JSON.stringify(body)).not.toContain('something unexpected');
  });
});
