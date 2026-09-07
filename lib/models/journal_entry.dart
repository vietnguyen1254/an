import 'mood.dart';

class JournalEntry {
  final String id;
  final String dateLabel;
  final Mood mood;
  final int intensity;
  final List<String> tags;
  final String note;

  const JournalEntry({
    required this.id,
    required this.dateLabel,
    required this.mood,
    required this.intensity,
    required this.tags,
    required this.note,
  });
}
