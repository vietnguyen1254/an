import { query } from '../db.js';
import { verifyIdToken } from '../firebase.js';

const PROVIDERS = new Set(['google', 'apple', 'facebook']);

export default async function authRoutes(app) {
  // POST /v1/auth/session
  // Header: Authorization: Bearer <firebase_id_token>
  // Body:   { provider, email?, name?, firebase_uid }
  // -> verifies the Firebase token, upserts the user, returns an app JWT.
  app.post('/v1/auth/session', async (req, reply) => {
    const header = req.headers.authorization ?? '';
    const idToken = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!idToken) return reply.code(401).send({ error: 'missing_bearer_token' });

    let decoded;
    try {
      decoded = await verifyIdToken(idToken);
    } catch (err) {
      if (err.statusCode === 503) {
        return reply.code(503).send({ error: 'auth_not_configured' });
      }
      req.log.warn({ err: err.message }, 'firebase token verify failed');
      return reply.code(401).send({ error: 'invalid_token' });
    }

    const body = req.body ?? {};
    const firebaseUid = decoded.uid;
    const email = decoded.email ?? body.email ?? null;
    const name = body.name ?? decoded.name ?? null;
    const provider = PROVIDERS.has(body.provider) ? body.provider : null;

    const { rows } = await query(
      `insert into users (firebase_uid, email, name, provider)
         values ($1, $2, $3, $4)
       on conflict (firebase_uid) do update set
         email      = coalesce(excluded.email, users.email),
         name       = coalesce(excluded.name, users.name),
         provider   = coalesce(excluded.provider, users.provider),
         updated_at = now()
       returning id, firebase_uid, email, name, provider, plan_tier`,
      [firebaseUid, email, name, provider],
    );
    const user = rows[0];

    const token = app.jwt.sign(
      { sub: user.id, uid: user.firebase_uid },
      { expiresIn: process.env.JWT_TTL ?? '30d' },
    );

    return reply.send({ token, user });
  });
}
