import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';

const root = resolve(import.meta.dirname, '../../..');
const sourcePath = resolve(root, 'docs/api/openapi.json');
const outputPath = resolve(import.meta.dirname, '../openapi-mobile.json');

const mobilePaths = [
  '/health',
  '/api/v1/auth/login',
  '/api/v1/auth/register',
  '/api/v1/auth/mfa/verify',
  '/api/v1/auth/refresh',
  '/api/v1/patients/me',
  '/api/v1/patients/me/intake',
  '/api/v1/daily-entries/today',
  '/api/v1/daily-entries/',
  '/api/v1/daily-entries/{id}/submit',
  '/api/v1/journal/',
  '/api/v1/medications/today',
  '/api/v1/medications/',
  '/api/v1/medications/{id}/logs',
  '/api/v1/assessments/pending',
  '/api/v1/assessments/',
  '/api/v1/assessments/{scale}/responses',
  '/api/v1/sync/pull',
  '/api/v1/sync/push',
  '/api/v1/safety/resources',
  '/api/v1/safety/my-plan',
  '/api/v1/notifications/prefs',
  '/api/v1/notifications/push-token',
  '/api/v1/consent/',
  '/api/v1/consent/{type}',
];

const spec = JSON.parse(await readFile(sourcePath, 'utf8'));
const paths = {};

for (const path of mobilePaths) {
  if (spec.paths?.[path]) {
    paths[path] = spec.paths[path];
  }
}

const mobileSpec = {
  ...spec,
  info: {
    ...spec.info,
    title: `${spec.info?.title ?? 'COPE API'} - Mobile Contract`,
  },
  paths,
};

await mkdir(dirname(outputPath), { recursive: true });
await writeFile(outputPath, `${JSON.stringify(mobileSpec, null, 2)}\n`);
console.log(`Mobile OpenAPI document written to ${outputPath}`);
