import 'dart:math';

import '../models/meditation_session.dart';
import '../models/mood.dart';

const guideNames = {'justin': 'Justin Nguyễn', 'tram': 'Trâm Nguyễn'};

String guideName(String key) => guideNames[key] ?? key;

/// Which meditation category best matches each check-in mood.
const moodCategory = {
  Mood.binhYen: 'tich-cuc',
  Mood.vui: 'tich-cuc',
  Mood.binhThuong: 'tich-cuc',
  Mood.loLang: 'lo-au',
  Mood.buon: 'chua-lanh',
  Mood.kietSuc: 'thu-gian',
};

/// Picks a random session matching [mood]'s category, falling back to any
/// session if none match. Null if the catalog is empty.
MeditationSession? pickRecommendation(List<MeditationSession> sessions, Mood mood) {
  if (sessions.isEmpty) return null;
  final wantCategory = moodCategory[mood];
  final matches = sessions.where((s) => s.categories.contains(wantCategory)).toList();
  final pool = matches.isNotEmpty ? matches : sessions;
  return pool[Random().nextInt(pool.length)];
}
