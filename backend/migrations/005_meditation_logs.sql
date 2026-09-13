-- 005_meditation_logs — per-play meditation / breathing listened-time.
-- Previously client-local only (SharedPreferences 'meditation_log'); this is
-- the backing table so the total survives a reinstall and syncs across
-- devices. One row per logged chunk (the client flushes incrementally during
-- playback), not one row per session.
create table if not exists meditation_logs (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  session_id uuid references meditation_sessions(id) on delete set null,
  seconds    int not null check (seconds > 0),
  logged_at  timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists meditation_logs_user_logged_idx
  on meditation_logs (user_id, logged_at desc);
