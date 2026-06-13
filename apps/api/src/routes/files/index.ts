// =============================================================================
// COPE API — Signed file downloads
// GET /api/v1/files/:bucket/*?exp=<epoch>&sig=<hmac>
// No JWT preHandler: the HMAC signature (issued by createSignedUrl) IS the
// authorization, so these URLs work as plain <a href> links in the dashboard,
// matching the Supabase signed-URL behaviour they replace.
// =============================================================================

import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import {
  contentTypeFor,
  objectExists,
  openObjectStream,
  verifySignedRequest,
} from '../../services/storage.js';

const QuerySchema = z.object({
  exp: z.string().regex(/^\d+$/),
  sig: z.string().regex(/^[0-9a-f]{64}$/),
});

const ParamsSchema = z.object({
  bucket: z.string().regex(/^[A-Za-z0-9_-]+$/),
  '*': z.string().min(1).max(1024),
});

export default async function fileRoutes(fastify: FastifyInstance): Promise<void> {
  fastify.get('/:bucket/*', async (request, reply) => {
    const { bucket, '*': objectPath } = ParamsSchema.parse(request.params);
    const { exp, sig } = QuerySchema.parse(request.query);

    if (!verifySignedRequest(bucket, objectPath, exp, sig)) {
      return reply.status(401).send({
        success: false,
        error: { code: 'INVALID_SIGNATURE', message: 'Download link is invalid or has expired' },
      });
    }

    let exists: boolean;
    try {
      exists = objectExists(bucket, objectPath);
    } catch {
      // resolveObjectPath rejected the path (traversal attempt)
      return reply.status(400).send({
        success: false,
        error: { code: 'BAD_REQUEST', message: 'Invalid object path' },
      });
    }

    if (!exists) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'File not found' },
      });
    }

    const filename = objectPath.split('/').pop() ?? 'download';
    return reply
      .header('Content-Type', contentTypeFor(objectPath))
      .header('Content-Disposition', `attachment; filename="${filename}"`)
      .send(openObjectStream(bucket, objectPath));
  });
}
