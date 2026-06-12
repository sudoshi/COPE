// =============================================================================
// COPE — Migration Runner
// Usage: npm run db:migrate (from packages/db)
// =============================================================================

import { readdir, readFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import postgres from 'postgres';

const DATABASE_URL = process.env['DATABASE_URL'];
if (!DATABASE_URL) {
  throw new Error('DATABASE_URL environment variable is required');
}

// Dedicated single connection: several migrations contain explicit
// BEGIN/COMMIT blocks, which postgres.js rejects on a pooled connection
// (UNSAFE_TRANSACTION) — transaction state isn't tied to one socket there.
const sql = postgres(DATABASE_URL, { max: 1, onnotice: () => {} });

const __dirname = dirname(fileURLToPath(import.meta.url));
const MIGRATIONS_DIR = join(__dirname, '..', 'migrations');

async function ensureMigrationsTable(): Promise<void> {
  await sql`
    CREATE TABLE IF NOT EXISTS _migrations (
      id          SERIAL      PRIMARY KEY,
      filename    TEXT        NOT NULL UNIQUE,
      applied_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `;
}

async function getAppliedMigrations(): Promise<Set<string>> {
  const rows = await sql<{ filename: string }[]>`
    SELECT filename FROM _migrations ORDER BY id
  `;
  return new Set(rows.map((r) => r.filename));
}

async function applyMigration(filename: string, sqlContent: string): Promise<void> {
  console.log(`Applying migration: ${filename}`);
  // Run the migration SQL and record it in the same implicit transaction
  // postgres.js wraps each tagged-template call in a transaction by default
  // For multi-statement DDL we need unsafe (no prepared statements)
  await sql.unsafe(sqlContent);
  // ON CONFLICT: 015/016 self-insert their _migrations row inside the script
  await sql`INSERT INTO _migrations (filename) VALUES (${filename}) ON CONFLICT (filename) DO NOTHING`;
  console.log(`  ✓ Applied: ${filename}`);
}

async function migrate(): Promise<void> {
  console.log('COPE — Database Migration Runner');
  console.log('====================================');

  await ensureMigrationsTable();
  const applied = await getAppliedMigrations();

  const files = (await readdir(MIGRATIONS_DIR))
    .filter((f) => f.endsWith('.sql'))
    .sort(); // Alphabetical order ensures numeric prefix ordering

  let count = 0;
  for (const filename of files) {
    if (applied.has(filename)) {
      console.log(`  — Skipping (already applied): ${filename}`);
      continue;
    }
    const filepath = join(MIGRATIONS_DIR, filename);
    const content = await readFile(filepath, 'utf-8');
    await applyMigration(filename, content);
    count++;
  }

  if (count === 0) {
    console.log('\nAll migrations are up to date.');
  } else {
    console.log(`\nApplied ${count} migration(s).`);
  }

  await sql.end({ timeout: 5 });
}

migrate().catch((err: unknown) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
