// =============================================================================
// COPE API — Local file storage (replaces Supabase Storage)
// Objects live under STORAGE_DIR/<bucket>/<objectPath>. Downloads go through
// GET /api/v1/files/<bucket>/<objectPath>?exp=...&sig=... — the HMAC signature
// is the authorization, so the URLs work as plain browser links exactly like
// the Supabase signed URLs they replace.
// =============================================================================

import { createHmac, timingSafeEqual } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { createReadStream, existsSync } from 'node:fs';
import type { ReadStream } from 'node:fs';
import { dirname, resolve, sep } from 'node:path';
import { config } from '../config.js';

const BUCKET_RE = /^[A-Za-z0-9_-]+$/;

/**
 * Resolve a bucket/object pair inside the storage root, refusing anything
 * that escapes it (path traversal) or uses a malformed bucket name.
 */
export function resolveObjectPath(bucket: string, objectPath: string): string {
  if (!BUCKET_RE.test(bucket)) {
    throw new Error(`Invalid bucket name: ${bucket}`);
  }
  const root = resolve(config.storageDir);
  const full = resolve(root, bucket, objectPath);
  if (full !== root && !full.startsWith(root + sep)) {
    throw new Error('Object path escapes storage root');
  }
  return full;
}

export async function saveObject(
  bucket: string,
  objectPath: string,
  data: Buffer,
): Promise<void> {
  const full = resolveObjectPath(bucket, objectPath);
  await mkdir(dirname(full), { recursive: true });
  await writeFile(full, data);
}

function signaturePayload(bucket: string, objectPath: string, expiresAtEpoch: number): string {
  return `${bucket}/${objectPath}:${expiresAtEpoch}`;
}

function computeSignature(bucket: string, objectPath: string, expiresAtEpoch: number): string {
  return createHmac('sha256', config.jwtSecret)
    .update(signaturePayload(bucket, objectPath, expiresAtEpoch))
    .digest('hex');
}

/**
 * Build a time-limited download URL. Relative by default (web and API share
 * an origin behind Apache); set API_PUBLIC_URL for absolute URLs.
 */
export function createSignedUrl(
  bucket: string,
  objectPath: string,
  expiresInSeconds: number,
): string {
  // Validates bucket + traversal before signing anything
  resolveObjectPath(bucket, objectPath);

  const exp = Math.floor(Date.now() / 1000) + expiresInSeconds;
  const sig = computeSignature(bucket, objectPath, exp);
  const encodedPath = objectPath.split('/').map(encodeURIComponent).join('/');
  return `${config.apiPublicUrl}/api/v1/files/${bucket}/${encodedPath}?exp=${exp}&sig=${sig}`;
}

export function verifySignedRequest(
  bucket: string,
  objectPath: string,
  exp: string,
  sig: string,
): boolean {
  const expiresAtEpoch = Number(exp);
  if (!Number.isInteger(expiresAtEpoch)) return false;
  if (expiresAtEpoch < Math.floor(Date.now() / 1000)) return false;

  const expected = Buffer.from(computeSignature(bucket, objectPath, expiresAtEpoch), 'hex');
  const provided = Buffer.from(sig, 'hex');
  if (expected.length !== provided.length || provided.length === 0) return false;
  return timingSafeEqual(expected, provided);
}

export function objectExists(bucket: string, objectPath: string): boolean {
  return existsSync(resolveObjectPath(bucket, objectPath));
}

export function openObjectStream(bucket: string, objectPath: string): ReadStream {
  return createReadStream(resolveObjectPath(bucket, objectPath));
}

const CONTENT_TYPES: Record<string, string> = {
  pdf: 'application/pdf',
  tsv: 'text/tab-separated-values',
  csv: 'text/csv',
  ndjson: 'application/x-ndjson',
  json: 'application/json',
  txt: 'text/plain',
};

export function contentTypeFor(objectPath: string): string {
  const ext = objectPath.split('.').pop()?.toLowerCase() ?? '';
  return CONTENT_TYPES[ext] ?? 'application/octet-stream';
}
