import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const specPath = resolve(import.meta.dirname, '../../../docs/api/openapi.json');
const spec = JSON.parse(await readFile(specPath, 'utf8'));

export const requiredPaths = [
  '/health',
  '/api/v1/auth/login',
  '/api/v1/auth/register',
  '/api/v1/auth/mfa/verify',
  '/api/v1/auth/refresh',
  '/api/v1/patients/me',
  '/api/v1/daily-entries/today',
  '/api/v1/daily-entries/',
  '/api/v1/journal/',
  '/api/v1/medications/today',
  '/api/v1/assessments/pending',
  '/api/v1/assessments/',
  '/api/v1/assessments/{scale}/responses',
  '/api/v1/sync/pull',
  '/api/v1/sync/push',
  '/api/v1/safety/resources',
  '/api/v1/safety/my-plan',
  '/api/v1/notifications/prefs',
  '/api/v1/notifications/push-token',
];

const missingPaths = requiredPaths.filter((path) => !spec.paths?.[path]);
if (missingPaths.length > 0) {
  throw new Error(`Missing mobile OpenAPI paths:\n${missingPaths.join('\n')}`);
}

const syncDailyEntryProperties = spec
  .paths['/api/v1/sync/pull']
  .get
  .responses['200']
  .content['application/json']
  .schema
  .properties
  .data
  .properties
  .changes
  .properties
  .daily_entries
  .properties
  .created
  .items
  .properties;

const requiredDailyEntryFields = [
  'mania_score',
  'racing_thoughts',
  'decreased_sleep_need',
  'anxiety_score',
  'somatic_anxiety',
  'anhedonia_score',
  'suicidal_ideation',
  'substance_use',
  'substance_quantity',
  'social_score',
  'social_avoidance',
  'cognitive_score',
  'brain_fog',
  'appetite_score',
  'stress_score',
  'life_event_note',
];

const missingDailyEntryFields = requiredDailyEntryFields.filter(
  (field) => !syncDailyEntryProperties[field],
);

if (missingDailyEntryFields.length > 0) {
  throw new Error(`Missing sync daily-entry fields:\n${missingDailyEntryFields.join('\n')}`);
}

console.log('Mobile OpenAPI contract validation passed.');
