import '../models/mood.dart';

const guideNames = {'justin': 'Justin Nguyễn', 'tram': 'Trâm Nguyễn'};

String guideName(String key) => guideNames[key] ?? key;

/// Which meditation category theme fits each check-in mood, for the
/// streak-encouragement copy (see [streak_encourage.dart]) — actual session
/// picking is scored server-side, see `SessionsApi.recommend`.
const moodCategory = {
  Mood.tucGian: 'lo-au',
  Mood.vui: 'tich-cuc',
  Mood.binhThuong: 'tich-cuc',
  Mood.loLang: 'lo-au',
  Mood.buon: 'chua-lanh',
  Mood.cangThang: 'thu-gian',
};
