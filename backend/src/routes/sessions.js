import { query } from '../db.js';

const COLS =
  'id, slug, title, guide, category, kind, duration_seconds, audio_path, image_path, is_free, series_name, series_index, series_total';

function toPublic(row) {
  return {
    id: row.id,
    slug: row.slug,
    title: row.title,
    guide: row.guide,
    category: row.category,
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
      clauses.push(`category = $${params.length}`);
    }
    const where = clauses.length ? `where ${clauses.join(' and ')}` : '';
    const { rows } = await query(
      `select ${COLS} from meditation_sessions ${where} order by created_at desc`,
      params,
    );
    return { sessions: rows.map(toPublic) };
  });
}
