-- 006_user_avatar — the profile avatar the user picked from the fixed set
-- (an icon id like 'cloud', 'moon', …; the app owns the catalogue). Part of
-- "Thông tin cá nhân", so it lives on the server and syncs across devices.
alter table users add column if not exists avatar text;
