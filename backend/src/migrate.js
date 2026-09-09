// Dead-simple forward-only migration runner. Applies every *.sql file in
// ./migrations in filename order, once, inside a transaction, and records it
// in schema_migrations. Run on deploy: `node src/migrate.js`.
import { readdir, readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { pool } from './db.js';

const migrationsDir = join(dirname(fileURLToPath(import.meta.url)), '..', 'migrations');

async function run() {
  const client = await pool.connect();
  try {
    await client.query(`
      create table if not exists schema_migrations (
        name text primary key,
        applied_at timestamptz not null default now()
      )
    `);

    const applied = new Set(
      (await client.query('select name from schema_migrations')).rows.map((r) => r.name),
    );

    const files = (await readdir(migrationsDir))
      .filter((f) => f.endsWith('.sql'))
      .sort();

    let ran = 0;
    for (const file of files) {
      if (applied.has(file)) continue;
      const sql = await readFile(join(migrationsDir, file), 'utf8');
      process.stdout.write(`[migrate] applying ${file} ... `);
      await client.query('begin');
      try {
        await client.query(sql);
        await client.query('insert into schema_migrations (name) values ($1)', [file]);
        await client.query('commit');
        console.log('ok');
        ran++;
      } catch (err) {
        await client.query('rollback');
        console.log('FAILED');
        throw err;
      }
    }
    console.log(ran ? `[migrate] ${ran} migration(s) applied` : '[migrate] up to date');
  } finally {
    client.release();
    await pool.end();
  }
}

run().catch((err) => {
  console.error('[migrate]', err);
  process.exit(1);
});
