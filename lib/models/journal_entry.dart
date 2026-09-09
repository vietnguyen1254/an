import '../utils/vn_date.dart';
import 'mood.dart';

class JournalEntry {
  final String id;
  final String dateLabel;
  final Mood mood;
  final int intensity;
  final List<String> tags;
  final String note;

  /// Calendar day this entry belongs to (for week/month/year grouping).
  final DateTime entryDate;

  const JournalEntry({
    required this.id,
    required this.dateLabel,
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
      dateLabel: formatEntryDateLabel(date),
      mood: Mood.values.byName(json['mood'] as String),
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
}

/// "Thứ Ba, 1 tháng 9 · 21:12" — matches the seed entry's original format.
String formatEntryDateLabel(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${formatVietnameseDate(d)} · $hh:$mm';
}
