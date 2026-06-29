// =============================================================================
// COPE API - OpenAPI export
// Generates docs/api/openapi.json from the Fastify route registry.
// =============================================================================

import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

process.env['DATABASE_URL'] ??= 'postgres://openapi:openapi@localhost:5432/openapi';
process.env['JWT_SECRET'] ??= 'openapi-export-placeholder';
process.env['OPENAPI_EXPORT'] = 'true';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(scriptDir, '../../../..');
const outputPath = resolve(repoRoot, 'docs/api/openapi.json');

let exitCode = 0;
const { buildApp } = await import('../app.js');
const app = await buildApp();

try {
  await app.ready();
  const spec = app.swagger();
  const contents = typeof spec === 'string' ? spec : `${JSON.stringify(spec, null, 2)}\n`;

  await mkdir(dirname(outputPath), { recursive: true });
  await writeFile(outputPath, contents, 'utf8');

  app.log.info({ outputPath }, 'OpenAPI document generated');
} catch (err) {
  exitCode = 1;
  console.error(err);
} finally {
  await app.close();
  process.exit(exitCode);
}
