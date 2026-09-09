-- 001_init — users + journal entries
create extension if not exists "pgcrypto";

create table if not exists users (
  id           uuid primary key default gen_random_uuid(),
  firebase_uid text unique not null,
  email        text,
  name         text,
  provider     text,
  plan_tier    text not null default 'free'
               check (plan_tier in ('free', 'monthly', 'yearly')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table if not exists journal_entries (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  mood       text not null
             check (mood in ('binhYen','vui','binhThuong','loLang','buon','kietSuc')),
  intensity  int not null check (intensity between 1 and 10),
  tags       text[] not null default '{}',
  note       text not null default '',
  entry_date date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists journal_entries_user_date_idx
  on journal_entries (user_id, entry_date desc);
create index if not exists journal_entries_user_updated_idx
  on journal_entries (user_id, updated_at desc);
