-- 007_mood_tuc_gian — replace the "binhYen" mood with "tucGian"
alter table journal_entries drop constraint journal_entries_mood_check;
alter table journal_entries add constraint journal_entries_mood_check
  check (mood in ('tucGian','vui','binhThuong','loLang','buon','kietSuc'));
