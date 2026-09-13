-- 010_meditation_topic_intensity — extends the hidden per-session metadata
-- from 009 (mood_weights) with:
--   description   — free-text note on what the session addresses; author-
--                   facing only, read when (re)generating the tags below,
--                   never scored on directly.
--   topic_tags    — overlap with the check-in topic vocabulary (see kTags
--                   in lib/state/app_state.dart), i.e. "what it's about".
--   intensity_min/max — the check-in intensity slider (1-10) range this
--                   session best fits (default 1-10 = any).
-- All hidden — never returned by /v1/sessions or /v1/sessions/recommend.
alter table meditation_sessions add column if not exists description text;
alter table meditation_sessions add column if not exists topic_tags text[] not null default '{}';
alter table meditation_sessions add column if not exists intensity_min int not null default 1;
alter table meditation_sessions add column if not exists intensity_max int not null default 10;

alter table meditation_sessions add constraint meditation_sessions_topic_tags_check
  check (topic_tags <@ array['cong-viec','gia-dinh','suc-khoe','giac-ngu','tai-chinh','moi-quan-he','ban-than']::text[]);
alter table meditation_sessions add constraint meditation_sessions_intensity_check
  check (intensity_min >= 1 and intensity_max <= 10 and intensity_min <= intensity_max);
