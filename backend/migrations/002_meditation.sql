-- 002_meditation — guided meditation / breathing sessions
create table if not exists meditation_sessions (
  id               uuid primary key default gen_random_uuid(),
  slug             text unique not null,
  title            text not null,
  guide            text not null check (guide in ('justin', 'tram')),
  category         text not null check (category in ('lo-lang', 'ngu', 'tap-trung', 'tho')),
  kind             text not null check (kind in ('breathing', 'guided')) default 'guided',
  duration_seconds int not null check (duration_seconds > 0),
  audio_path       text not null,
  image_path       text,
  is_free          boolean not null default false,
  series_name      text,
  series_index     int,
  series_total     int,
  created_at       timestamptz not null default now()
);

create index if not exists meditation_sessions_guide_idx on meditation_sessions (guide);
create index if not exists meditation_sessions_category_idx on meditation_sessions (category);
