-- 004_meditation_multi_category — a session can belong to more than one
-- category, so `category text` becomes `categories text[]`.
alter table meditation_sessions add column categories text[];
update meditation_sessions set categories = array[category];
alter table meditation_sessions alter column categories set default '{}';
alter table meditation_sessions alter column categories set not null;

alter table meditation_sessions drop constraint meditation_sessions_category_check;
alter table meditation_sessions drop column category;

alter table meditation_sessions add constraint meditation_sessions_categories_check
  check (categories <@ array['chua-lanh', 'lo-au', 'thu-gian', 'tich-cuc']::text[]);

drop index if exists meditation_sessions_category_idx;
create index meditation_sessions_categories_idx on meditation_sessions using gin (categories);
