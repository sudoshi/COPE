// =============================================================================
// COPE Mobile — WatermelonDB migrations
// =============================================================================

import { schemaMigrations, addColumns } from '@nozbe/watermelondb/Schema/migrations';

export const migrations = schemaMigrations({
  migrations: [
    {
      toVersion: 2,
      steps: [
        addColumns({
          table: 'daily_entries',
          columns: [
            { name: 'mania_score', type: 'number', isOptional: true },
            { name: 'racing_thoughts', type: 'boolean', isOptional: true },
            { name: 'decreased_sleep_need', type: 'boolean', isOptional: true },
            { name: 'anxiety_score', type: 'number', isOptional: true },
            { name: 'somatic_anxiety', type: 'boolean', isOptional: true },
            { name: 'anhedonia_score', type: 'number', isOptional: true },
            { name: 'suicidal_ideation', type: 'number', isOptional: true },
            { name: 'substance_use', type: 'string', isOptional: true },
            { name: 'substance_quantity', type: 'number', isOptional: true },
            { name: 'social_score', type: 'number', isOptional: true },
            { name: 'social_avoidance', type: 'boolean', isOptional: true },
            { name: 'cognitive_score', type: 'number', isOptional: true },
            { name: 'brain_fog', type: 'boolean', isOptional: true },
            { name: 'appetite_score', type: 'number', isOptional: true },
            { name: 'stress_score', type: 'number', isOptional: true },
            { name: 'life_event_note', type: 'string', isOptional: true },
          ],
        }),
      ],
    },
  ],
});
