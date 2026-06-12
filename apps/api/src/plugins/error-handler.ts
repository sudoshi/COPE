// =============================================================================
// MindLog API — Global error handler plugin
// =============================================================================

import type { FastifyInstance, FastifyError } from 'fastify';
import fp from 'fastify-plugin';
import { ZodError } from 'zod';
import { captureException } from '../sentry.js';

async function errorHandlerPlugin(fastify: FastifyInstance): Promise<void> {
  fastify.setErrorHandler((error: FastifyError | ZodError | Error, request, reply) => {
    const log = fastify.log;

    // Zod validation errors → 422
    if (error instanceof ZodError) {
      return reply.status(422).send({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Request validation failed',
          details: error.flatten(),
        },
      });
    }

    // Fastify validation errors → 400
    if ('validation' in error && error.validation) {
      return reply.status(400).send({
        success: false,
        error: {
          code: 'BAD_REQUEST',
          message: error.message,
          details: error.validation,
        },
      });
    }

    // Known HTTP errors (statusCode set by Fastify)
    const statusCode = 'statusCode' in error && error.statusCode ? error.statusCode : 500;
    if (statusCode < 500) {
      return reply.status(statusCode).send({
        success: false,
        error: {
          code: 'CLIENT_ERROR',
          message: error.message,
        },
      });
    }

    // Infrastructure failures → 503 so clients see "try again later", not a generic 500.
    // DB: SQLSTATE classes 08 (connection), 28 (invalid authorization, e.g. bad
    // DATABASE_URL password), 3D (invalid catalog) + 57P01-57P03 (server shutdown).
    // Upstream: undici throws TypeError('fetch failed') when Supabase is unreachable.
    const sqlState = 'code' in error && typeof error.code === 'string' ? error.code : '';
    const isDbUnavailable =
      error.name === 'PostgresError' &&
      (['08', '28', '3D'].includes(sqlState.slice(0, 2)) ||
        ['57P01', '57P02', '57P03'].includes(sqlState));
    const isUpstreamUnavailable =
      error instanceof TypeError && error.message.startsWith('fetch failed');

    if (isDbUnavailable || isUpstreamUnavailable) {
      log.error(
        { err: error, req: { method: request.method, url: request.url } },
        'Infrastructure failure',
      );
      captureException(error, { method: request.method, url: request.url });

      return reply.status(503).send({
        success: false,
        error: {
          code: isDbUnavailable ? 'DATABASE_UNAVAILABLE' : 'UPSTREAM_UNAVAILABLE',
          message: 'A required service is temporarily unavailable. Please try again shortly.',
        },
      });
    }

    // Unexpected server errors — log + send to Sentry, return generic message
    log.error({ err: error, req: { method: request.method, url: request.url } }, 'Unhandled error');
    captureException(error, { method: request.method, url: request.url });

    return reply.status(500).send({
      success: false,
      error: {
        code: 'INTERNAL_SERVER_ERROR',
        message: 'An unexpected error occurred',
      },
    });
  });
}

export default fp(errorHandlerPlugin, { name: 'error-handler' });
