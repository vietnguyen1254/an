import { query } from '../db.js';

const AVATAR_RE = /^[a-z0-9_-]{1,40}$/;

export default async function meRoutes(app) {
  app.addHook('onRequest', app.authenticate);

  // GET /v1/me
  app.get('/v1/me', async (req, reply) => {
    const { rows } = await query(
      'select id, firebase_uid, email, name, avatar, provider, plan_tier, created_at from users where id = $1',
      [req.user.sub],
    );
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    return rows[0];
  });

  // PATCH /v1/me  { name?, avatar?, plan_tier? }
  app.patch('/v1/me', async (req, reply) => {
    const { name, avatar, plan_tier: planTier } = req.body ?? {};
    if (planTier !== undefined && !['free', 'monthly', 'yearly'].includes(planTier)) {
      return reply.code(422).send({ error: 'invalid_plan_tier' });
    }
    if (avatar !== undefined && avatar !== null && !AVATAR_RE.test(avatar)) {
      return reply.code(422).send({ error: 'invalid_avatar' });
    }
    const { rows } = await query(
      `update users set
         name       = coalesce($2, name),
         avatar     = coalesce($3, avatar),
         plan_tier  = coalesce($4, plan_tier),
         updated_at = now()
       where id = $1
       returning id, firebase_uid, email, name, avatar, provider, plan_tier`,
      [req.user.sub, name ?? null, avatar ?? null, planTier ?? null],
    );
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    return rows[0];
  });

  // DELETE /v1/me — permanent account deletion. journal_entries and
  // meditation_logs are removed by their ON DELETE CASCADE.
  app.delete('/v1/me', async (req, reply) => {
    await query('delete from users where id = $1', [req.user.sub]);
    return reply.code(204).send();
  });
}
