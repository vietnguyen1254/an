import { query } from '../db.js';

export default async function meRoutes(app) {
  app.addHook('onRequest', app.authenticate);

  // GET /v1/me
  app.get('/v1/me', async (req, reply) => {
    const { rows } = await query(
      'select id, firebase_uid, email, name, provider, plan_tier, created_at from users where id = $1',
      [req.user.sub],
    );
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    return rows[0];
  });

  // PATCH /v1/me  { name?, plan_tier? }
  app.patch('/v1/me', async (req, reply) => {
    const { name, plan_tier: planTier } = req.body ?? {};
    if (planTier !== undefined && !['free', 'monthly', 'yearly'].includes(planTier)) {
      return reply.code(422).send({ error: 'invalid_plan_tier' });
    }
    const { rows } = await query(
      `update users set
         name       = coalesce($2, name),
         plan_tier  = coalesce($3, plan_tier),
         updated_at = now()
       where id = $1
       returning id, firebase_uid, email, name, provider, plan_tier`,
      [req.user.sub, name ?? null, planTier ?? null],
    );
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    return rows[0];
  });
}
