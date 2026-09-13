import 'mood.dart';

/// Old/unrecognised mood names (e.g. after a rename) fall back to
/// [Mood.binhThuong] instead of throwing, so a stale local cache or backend
/// row never crashes the app on load.
Mood _moodFromWire(String name) => Mood.values.asNameMap()[name] ?? Mood.binhThuong;

class JournalEntry {
  final String id;
  final Mood mood;
  final int intensity;
  final List<String> tags;
  final String note;

  /// Calendar day this entry belongs to (for week/month/year grouping).
  final DateTime entryDate;

  const JournalEntry({
    required this.id,
    required this.mood,
    required this.intensity,
    required this.tags,
    required this.note,
    required this.entryDate,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['entry_date'] as String);
    return JournalEntry(
      id: json['id'] as String,
      mood: _moodFromWire(json['mood'] as String),
      intensity: json['intensity'] as int,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      note: json['note'] as String? ?? '',
      entryDate: date,
    );
  }

  Map<String, dynamic> toJson() => {
        'mood': mood.name,
        'intensity': intensity,
        'tags': tags,
        'note': note,
        'entry_date': '${entryDate.year.toString().padLeft(4, '0')}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.day.toString().padLeft(2, '0')}',
      };

  /// Serialisation for the on-device cache (SharedPreferences). Unlike
  /// [toJson] — which matches the backend's write contract — this keeps the
  /// server [id] and the full [entryDate] timestamp so a cold start can
  /// render the journal (and the streak) before the backend responds.
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'mood': mood.name,
        'intensity': intensity,
        'tags': tags,
        'note': note,
        'entry_date': entryDate.toIso8601String(),
      };

  factory JournalEntry.fromCacheJson(Map<String, dynamic> j) {
    final date = DateTime.parse(j['entry_date'] as String);
    return JournalEntry(
      id: j['id'] as String,
      mood: _moodFromWire(j['mood'] as String),
      intensity: j['intensity'] as int,
      tags: (j['tags'] as List<dynamic>).cast<String>(),
      note: j['note'] as String? ?? '',
      entryDate: date,
    );
  }
}
