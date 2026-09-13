import { query } from '../db.js';

const COLS = 'id, session_id, seconds, logged_at, created_at';
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export default async function meditationRoutes(app) {
  app.addHook('onRequest', app.authenticate);

  // GET /v1/meditation-logs?since=<ISO timestamp>   (delta sync)
  app.get('/v1/meditation-logs', async (req) => {
    const since = req.query?.since;
    const params = [req.user.sub];
    let where = 'user_id = $1';
    if (since && !Number.isNaN(Date.parse(since))) {
      params.push(new Date(since).toISOString());
      where += ` and logged_at > $${params.length}`;
    }
    const { rows } = await query(
      `select ${COLS} from meditation_logs where ${where} order by logged_at desc limit 1000`,
      params,
    );
    return { logs: rows };
  });

  // POST /v1/meditation-logs   { seconds, session_id?, logged_at? }
  app.post('/v1/meditation-logs', async (req, reply) => {
    const b = req.body ?? {};
    if (!(Number.isInteger(b.seconds) && b.seconds > 0)) {
      return reply.code(422).send({ error: 'invalid', fields: ['seconds'] });
    }
    const sessionId = typeof b.session_id === 'string' && UUID_RE.test(b.session_id) ? b.session_id : null;
    const loggedAt = b.logged_at && !Number.isNaN(Date.parse(b.logged_at))
      ? new Date(b.logged_at).toISOString()
      : new Date().toISOString();

    const { rows } = await query(
      `insert into meditation_logs (user_id, session_id, seconds, logged_at)
         values ($1, $2, $3, $4)
       returning ${COLS}`,
      [req.user.sub, sessionId, b.seconds, loggedAt],
    );
    return reply.code(201).send(rows[0]);
  });
}
