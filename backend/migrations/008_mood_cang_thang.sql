-- 008_mood_cang_thang — replace the "kietSuc" mood with "cangThang"
alter table journal_entries drop constraint journal_entries_mood_check;
alter table journal_entries add constraint journal_entries_mood_check
  check (mood in ('tucGian','vui','binhThuong','loLang','buon','cangThang'));
