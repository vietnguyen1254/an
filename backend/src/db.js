import pg from 'pg';

// Keep DATE columns as plain 'YYYY-MM-DD' strings (no timezone shifting).
pg.types.setTypeParser(1082, (v) => v);

// One small pool — this box is memory-constrained and Postgres is capped at
// max_connections=20, so keep the app's slice modest.
export const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  max: Number(process.env.PG_POOL_MAX ?? 8),
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 10_000,
});

pool.on('error', (err) => {
  // A backend client can be dropped by Postgres (restart, timeout). Log and
  // let the pool recycle it rather than crashing the process.
  console.error('[db] idle client error', err.message);
});

export const query = (text, params) => pool.query(text, params);
