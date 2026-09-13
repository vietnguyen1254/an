import crypto from 'node:crypto';
import { query } from '../db.js';

const PLAY_LINK_TTL_SECONDS = 600;

// Matches nginx's secure_link_md5 "$secure_link_expires$uri ${MEDIA_LINK_SECRET}"
// in nginx/an.conf.template — base64url, no padding, per the module's spec.
function signAudioPath(uriPath) {
  const expires = Math.floor(Date.now() / 1000) + PLAY_LINK_TTL_SECONDS;
  const md5 = crypto
    .createHash('md5')
    .update(`${expires}${uriPath} ${process.env.MEDIA_LINK_SECRET}`)
    .digest('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
  return `${uriPath}?md5=${md5}&expires=${expires}`;
}

const COLS =
  'id, slug, title, guide, categories, kind, duration_seconds, audio_path, image_path, is_free, series_name, series_index, series_total';

function toPublic(row) {
  return {
    id: row.id,
    slug: row.slug,
    title: row.title,
    guide: row.guide,
    categories: row.categories,
    kind: row.kind,
    duration_seconds: row.duration_seconds,
    audio_url: `/media/audio/${row.audio_path}`,
    image_url: row.image_path ? `/media/images/${row.image_path}` : null,
    is_free: row.is_free,
    series_name: row.series_name,
    series_index: row.series_index,
    series_total: row.series_total,
  };
}

const MOODS = ['tucGian', 'vui', 'binhThuong', 'loLang', 'buon', 'cangThang'];
const TOPIC_TAGS = ['cong-viec', 'gia-dinh', 'suc-khoe', 'giac-ngu', 'tai-chinh', 'moi-quan-he', 'ban-than'];

// Public catalog — no auth. Content is managed by hand on the server, not
// through the app, so this is read-only.
export default async function sessionRoutes(app) {
  app.get('/v1/sessions', async (req) => {
    const { guide, category } = req.query ?? {};
    const params = [];
    const clauses = [];
    if (guide) {
      params.push(guide);
      clauses.push(`guide = $${params.length}`);
    }
    if (category) {
      params.push(category);
      clauses.push(`categories @> array[$${params.length}]::text[]`);
    }
    const where = clauses.length ? `where ${clauses.join(' and ')}` : '';
    const { rows } = await query(
      `select ${COLS} from meditation_sessions ${where} order by created_at desc`,
      params,
    );
    return { sessions: rows.map(toPublic) };
  });

  // One session recommended for the check-in just recorded, scored on the
  // hidden `mood_weights`/`topic_tags`/`intensity_min`/`intensity_max`
  // (never included in the public catalog above) — mood match dominates,
  // topic overlap and intensity fit only break ties between equally-good
  // moods, so a small catalog never gets over-filtered to empty. Ties —
  // including "nothing scores above 0" — fall back to a uniform random pick.
  app.get('/v1/sessions/recommend', async (req) => {
    const { mood, tags, intensity } = req.query ?? {};
    const wantTags = (typeof tags === 'string' ? tags.split(',') : []).filter((t) => TOPIC_TAGS.includes(t));
    const wantIntensity = Number.isInteger(Number(intensity)) ? Number(intensity) : null;
    const { rows } = await query(
      `select ${COLS}, mood_weights, topic_tags, intensity_min, intensity_max from meditation_sessions`,
      [],
    );
    if (rows.length === 0) return { session: null };
    const scoreOf = (r) => {
      const moodScore = MOODS.includes(mood) && typeof r.mood_weights?.[mood] === 'number' ? r.mood_weights[mood] : 0;
      const topicOverlap = wantTags.filter((t) => r.topic_tags?.includes(t)).length;
      const intensityFit = wantIntensity != null && wantIntensity >= r.intensity_min && wantIntensity <= r.intensity_max ? 1 : 0;
      return moodScore * 10 + topicOverlap * 2 + intensityFit;
    };
    const best = Math.max(...rows.map(scoreOf));
    const pool = best > 0 ? rows.filter((r) => scoreOf(r) === best) : rows;
    const pick = pool[Math.floor(Math.random() * pool.length)];
    return { session: toPublic(pick) };
  });

  // A short-lived, signed audio_url for actual playback — the bare path
  // from /v1/sessions above 403s at nginx without one (see
  // nginx/an.conf.template). Requires auth, and a non-free session also
  // requires an active plan, matching the trust level the rest of the app's
  // premium gating already runs on (see project_subscriptions_faked).
  app.get('/v1/sessions/:id/play', { onRequest: [app.authenticate] }, async (req, reply) => {
    const { rows } = await query(
      'select audio_path, is_free from meditation_sessions where id = $1',
      [req.params.id],
    );
    const session = rows[0];
    if (!session) return reply.code(404).send({ error: 'not_found' });
    if (!session.is_free) {
      const { rows: userRows } = await query('select plan_tier from users where id = $1', [req.user.sub]);
      if ((userRows[0]?.plan_tier ?? 'free') === 'free') {
        return reply.code(402).send({ error: 'premium_required' });
      }
    }
    return { audio_url: signAudioPath(`/media/audio/${session.audio_path}`) };
  });
}
