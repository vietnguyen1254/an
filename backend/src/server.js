import Fastify from 'fastify';
import cors from '@fastify/cors';
import jwt from '@fastify/jwt';
import rateLimit from '@fastify/rate-limit';

import { pool } from './db.js';
import { firebaseReady, firebaseStatus } from './firebase.js';
import authRoutes from './routes/auth.js';
import meRoutes from './routes/me.js';
import entryRoutes from './routes/entries.js';
import meditationRoutes from './routes/meditation.js';
import sessionRoutes from './routes/sessions.js';

const PORT = Number(process.env.PORT ?? 8080);

const app = Fastify({
  logger: {
    level: process.env.LOG_LEVEL ?? 'info',
    // nginx already logs the client IP; keep app logs lean
    transport: process.env.NODE_ENV === 'production' ? undefined : { target: 'pino-pretty' },
  },
  trustProxy: true,
  bodyLimit: 64 * 1024, // 64 KB — text notes only
});

if (!process.env.JWT_SECRET) {
  app.log.error('JWT_SECRET is required');
  process.exit(1);
}
if (!process.env.MEDIA_LINK_SECRET) {
  app.log.error('MEDIA_LINK_SECRET is required');
  process.exit(1);
}

await app.register(cors, { origin: true });
await app.register(jwt, { secret: process.env.JWT_SECRET });
await app.register(rateLimit, {
  max: Number(process.env.RATE_LIMIT_MAX ?? 120),
  timeWindow: '1 minute',
});

// req.user is populated from a valid app JWT (Authorization: Bearer <token>)
app.decorate('authenticate', async (req, reply) => {
  try {
    await req.jwtVerify();
  } catch {
    return reply.code(401).send({ error: 'unauthorized' });
  }
});

app.get('/healthz', async () => {
  let db = 'down';
  try {
    await pool.query('select 1');
    db = 'up';
  } catch {
    /* reported below */
  }
  const ok = db === 'up';
  return {
    ok,
    db,
    firebase: firebaseReady() ? 'ready' : firebaseStatus(),
  };
});

await app.register(authRoutes);
await app.register(meRoutes);
await app.register(entryRoutes);
await app.register(meditationRoutes);
await app.register(sessionRoutes);

const close = async (signal) => {
  app.log.info(`${signal} received, shutting down`);
  await app.close();
  await pool.end();
  process.exit(0);
};
process.on('SIGTERM', () => close('SIGTERM'));
process.on('SIGINT', () => close('SIGINT'));

try {
  await app.listen({ port: PORT, host: '0.0.0.0' });
} catch (err) {
  app.log.error(err);
  process.exit(1);
}
