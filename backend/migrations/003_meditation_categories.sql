-- 003_meditation_categories — replace the category taxonomy:
-- (lo-lang, ngu, tap-trung, tho) -> (chua-lanh, lo-au, thu-gian, tich-cuc)
alter table meditation_sessions drop constraint meditation_sessions_category_check;

update meditation_sessions set category = 'lo-au' where category = 'lo-lang';
update meditation_sessions set category = 'thu-gian' where category in ('ngu', 'tho');
update meditation_sessions set category = 'tich-cuc' where category = 'tap-trung';

alter table meditation_sessions add constraint meditation_sessions_category_check
  check (category in ('chua-lanh', 'lo-au', 'thu-gian', 'tich-cuc'));
