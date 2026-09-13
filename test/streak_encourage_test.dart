import 'package:an/models/mood.dart';
import 'package:an/services/streak_encourage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const streaks = [1, 2, 4, 6, 7, 12, 30, 100, 366];
  const tags = [null, 'Công việc', 'Gia đình', 'Giấc ngủ', 'Bản thân'];

  test('every combination produces a clean, well-formed sentence', () {
    for (final mood in Mood.values) {
      for (final trend in MoodTrend.values) {
        for (final streak in streaks) {
          for (final tag in tags) {
            for (var i = 0; i < 20; i++) {
              final msg = generateStreakMessage(mood, streak, tagLabel: tag, trend: trend);
              expect(msg, isNotEmpty);
              expect(msg.contains('{streak}'), isFalse, reason: 'unfilled {streak}: $msg');
              expect(msg.contains('{tag}'), isFalse, reason: 'unfilled {tag}: $msg');
              expect(msg.endsWith('.'), isTrue, reason: 'no end stop: $msg');
              // First character is upper-case (bug being fixed).
              expect(msg[0], equals(msg[0].toUpperCase()), reason: 'lower-case start: $msg');
              expect(msg.contains('..'), isFalse, reason: 'double stop: $msg');
              // Clause after ". " starts upper-case or a digit, never lower.
              final m = RegExp(r'\. ([a-zđ])').firstMatch(msg);
              expect(m, isNull, reason: 'lower-case second sentence: $msg');
            }
          }
        }
      }
    }
  });

  test('a hard-day mood never gets a celebratory streak clause', () {
    const celebratory = ['nhịp rất đẹp', 'thói quen tử tế đang lớn', 'cứ tiếp tục nhé'];
    for (final mood in [Mood.loLang, Mood.buon, Mood.cangThang, Mood.tucGian]) {
      for (var i = 0; i < 400; i++) {
        final msg = generateStreakMessage(mood, 12, trend: MoodTrend.none);
        for (final phrase in celebratory) {
          expect(msg.contains(phrase), isFalse, reason: '$mood got "$phrase": $msg');
        }
      }
    }
  });

  test('milestone day: mood clause first, milestone clause second', () {
    for (var i = 0; i < 300; i++) {
      final msg = generateStreakMessage(Mood.buon, 30);
      final parts = msg.split('. ');
      expect(parts.length, greaterThanOrEqualTo(2), reason: 'not two clauses: $msg');
      // The last clause is the milestone one.
      final last = parts.last.toLowerCase();
      expect(
        last.contains('tháng') || last.contains('ba mươi ngày'),
        isTrue,
        reason: 'milestone clause not last: $msg',
      );
    }
  });
}
