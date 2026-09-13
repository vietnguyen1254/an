import { query } from '../db.js';

const MOODS = new Set(['tucGian', 'vui', 'binhThuong', 'loLang', 'buon', 'cangThang']);

function validateEntry(body, { partial = false } = {}) {
  const errors = [];
  const has = (k) => body[k] !== undefined && body[k] !== null;

  if ((!partial || has('mood')) && !MOODS.has(body.mood)) errors.push('mood');
  if ((!partial || has('intensity')) &&
      !(Number.isInteger(body.intensity) && body.intensity >= 1 && body.intensity <= 10)) {
    errors.push('intensity');
  }
  if ((!partial || has('entry_date')) && !/^\d{4}-\d{2}-\d{2}$/.test(body.entry_date ?? '')) {
    errors.push('entry_date');
  }
  if (has('tags') && (!Array.isArray(body.tags) || body.tags.some((t) => typeof t !== 'string'))) {
    errors.push('tags');
  }
  if (has('note') && typeof body.note !== 'string') errors.push('note');
  return errors;
}

const COLS = 'id, mood, intensity, tags, note, entry_date, created_at, updated_at';

export default async function entryRoutes(app) {
  app.addHook('onRequest', app.authenticate);

  // GET /v1/entries?since=<ISO timestamp>   (delta sync)
  app.get('/v1/entries', async (req) => {
    const since = req.query?.since;
    const params = [req.user.sub];
    let where = 'user_id = $1';
    if (since && !Number.isNaN(Date.parse(since))) {
      params.push(new Date(since).toISOString());
      where += ` and updated_at > $${params.length}`;
    }
    const { rows } = await query(
      `select ${COLS} from journal_entries where ${where} order by entry_date desc, created_at desc limit 500`,
      params,
    );
    return { entries: rows };
  });

  // POST /v1/entries
  app.post('/v1/entries', async (req, reply) => {
    const b = req.body ?? {};
    const errors = validateEntry(b);
    if (errors.length) return reply.code(422).send({ error: 'invalid', fields: errors });

    const { rows } = await query(
      `insert into journal_entries (user_id, mood, intensity, tags, note, entry_date)
         values ($1, $2, $3, $4, $5, $6)
       returning ${COLS}`,
      [req.user.sub, b.mood, b.intensity, b.tags ?? [], b.note ?? '', b.entry_date],
    );
    return reply.code(201).send(rows[0]);
  });

  // PATCH /v1/entries/:id
  app.patch('/v1/entries/:id', async (req, reply) => {
    const b = req.body ?? {};
    const errors = validateEntry(b, { partial: true });
    if (errors.length) return reply.code(422).send({ error: 'invalid', fields: errors });

    const { rows } = await query(
      `update journal_entries set
         mood       = coalesce($3, mood),
         intensity  = coalesce($4, intensity),
         tags       = coalesce($5, tags),
         note       = coalesce($6, note),
         entry_date = coalesce($7, entry_date),
         updated_at = now()
       where id = $1 and user_id = $2
       returning ${COLS}`,
      [req.params.id, req.user.sub,
       b.mood ?? null, b.intensity ?? null, b.tags ?? null, b.note ?? null, b.entry_date ?? null],
    );
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    return rows[0];
  });

  // DELETE /v1/entries/:id
  app.delete('/v1/entries/:id', async (req, reply) => {
    const { rowCount } = await query(
      'delete from journal_entries where id = $1 and user_id = $2',
      [req.params.id, req.user.sub],
    );
    return reply.code(rowCount ? 204 : 404).send();
  });

  // GET /v1/streak  — consecutive days ending today or yesterday
  app.get('/v1/streak', async (req) => {
    const { rows } = await query(
      `select distinct entry_date from journal_entries
        where user_id = $1 order by entry_date desc limit 400`,
      [req.user.sub],
    );
    const days = rows.map((r) => r.entry_date); // already 'YYYY-MM-DD'
    const today = new Date().toISOString().slice(0, 10);
    const yesterday = new Date(Date.now() - 86_400_000).toISOString().slice(0, 10);

    let streak = 0;
    if (days[0] === today || days[0] === yesterday) {
      let cursor = new Date(days[0]);
      for (const d of days) {
        if (d === cursor.toISOString().slice(0, 10)) {
          streak++;
          cursor = new Date(cursor.getTime() - 86_400_000);
        } else {
          break;
        }
      }
    }
    return { streak, last_entry_date: days[0] ?? null };
  });
}
