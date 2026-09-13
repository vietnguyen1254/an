-- 009_meditation_mood_weights — hidden per-session fit score (0..1) for each
-- check-in mood, replacing the coarse "one category per mood" client-side
-- map. Never returned to the app; only /v1/sessions/recommend reads it.
alter table meditation_sessions add column if not exists mood_weights jsonb not null default '{}';

-- Backfill from the old mood->category mapping so recommendations keep
-- working as before; hand-tune per session from here.
update meditation_sessions set mood_weights = jsonb_build_object(
  'tucGian', case when categories @> array['lo-au'] then 1 else 0 end,
  'vui', case when categories @> array['tich-cuc'] then 1 else 0 end,
  'binhThuong', case when categories @> array['tich-cuc'] then 1 else 0 end,
  'loLang', case when categories @> array['lo-au'] then 1 else 0 end,
  'buon', case when categories @> array['chua-lanh'] then 1 else 0 end,
  'cangThang', case when categories @> array['thu-gian'] then 1 else 0 end
);
