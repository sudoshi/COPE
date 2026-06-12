import { defineConfig } from 'vitest/config';

// Unit tests only — the specs under e2e/ are Playwright journeys and must not
// be collected by vitest (they run via `npm run test:e2e`).
export default defineConfig({
  test: {
    environment: 'node',
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
  },
});
