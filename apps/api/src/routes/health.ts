// =============================================================================
// COPE API — Health check route
// GET /health  →  200 { status: 'ok', ... }
// =============================================================================

import { createRequire } from 'node:module';
import type { FastifyInstance } from 'fastify';
import { sql } from '@cope/db';

// Resolves to apps/api/package.json from both src/ and dist/ layouts;
// createRequire keeps the JSON file outside the tsc rootDir.
const pkgRequire = createRequire(import.meta.url);
const { version: API_VERSION } = pkgRequire('../../package.json') as { version: string };

export default async function healthRoutes(fastify: FastifyInstance): Promise<void> {
  fastify.get('/health', { logLevel: 'silent' }, async (_request, reply) => {
    // Check DB connectivity
    let dbOk = false;
    try {
      await sql`SELECT 1`;
      dbOk = true;
    } catch {
      fastify.log.warn('Health check: DB unreachable');
    }

    const status = dbOk ? 'ok' : 'degraded';
    const httpStatus = dbOk ? 200 : 503;

    return reply.status(httpStatus).send({
      status,
      timestamp: new Date().toISOString(),
      version: API_VERSION,
      db: dbOk ? 'connected' : 'unreachable',
    });
  });
}
