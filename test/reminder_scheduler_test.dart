import 'package:an/models/mood.dart';
import 'package:an/services/notifications/reminder_copy.dart';
import 'package:an/services/notifications/reminder_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 6, 1, 9, 0); // fixed "today" 09:00
  final longAgo = DateTime(2026, 1, 1);

  List<DateTime> entriesForDays(int n, {int hour = 12, int minute = 0}) =>
      List.generate(n, (i) => DateTime(2026, 6, 1).subtract(Duration(days: i)).add(Duration(hours: hour, minutes: minute)));

  ScheduleResult run({
    List<DateTime>? entries,
    List<Mood>? moods,
    List<DateTime>? meds,
    MedSlot stored = MedSlot.evening,
    DateTime? storedSince,
    int streak = 3,
  }) =>
      ReminderScheduler.build(
        moodEnabled: true,
        medEnabled: true,
        entryTimes: entries ?? [],
        recentMoods: moods ?? [],
        streakDays: streak,
        meditationTimes: meds ?? [],
        storedMedSlot: stored,
        storedMedSlotSince: storedSince ?? longAgo,
        now: now,
      );

  DateTime? firstAt(ScheduleResult r, String payload) {
    for (final x in r.reminders) {
      if (x.payload == payload) return x.when;
    }
    return null;
  }

  test('new user: mood 17:45, meditation 21:15', () {
    final r = run();
    final mood = firstAt(r, 'checkin')!;
    expect(mood.hour, 17);
    expect(mood.minute, 45);
    final med = firstAt(r, 'meditate')!;
    expect(med.hour, 21);
    expect(med.minute, 15);
  });

  test('established user (day 25) checking in near the phase time → 20:15', () {
    // Entries near 20:00 so the behavioural override does not kick in.
    final r = run(entries: entriesForDays(25, hour: 20), moods: List.filled(25, Mood.tucGian));
    final mood = firstAt(r, 'checkin')!;
    expect(mood.hour, 20);
    expect(mood.minute, 15);
  });

  test('ramp day 19: mood around 19:00', () {
    final r = run(entries: entriesForDays(19, hour: 19), moods: List.filled(19, Mood.tucGian));
    final mood = firstAt(r, 'checkin')!;
    expect(mood.hour, 19);
  });

  test('behavioural override: user always checks in ~09:00 → reminder ~08:30', () {
    final r = run(
      entries: entriesForDays(8, hour: 9, minute: 0),
      moods: List.filled(8, Mood.vui),
      streak: 8,
    );
    final mood = firstAt(r, 'checkin')!;
    expect(mood.hour, 8);
    expect(mood.minute, 30);
  });

  test('meditation habit in the morning → reminder shifts to morning', () {
    // 4 mornings in the last 7 days, none in the evening.
    final meds = [
      for (var i = 1; i <= 4; i++) DateTime(2026, 6, 1).subtract(Duration(days: i)).add(const Duration(hours: 7, minutes: 0)),
    ];
    final r = run(meds: meds, storedSince: longAgo);
    expect(r.medSlot, MedSlot.morning);
    final med = firstAt(r, 'meditate')!;
    expect(med.hour, lessThan(11));
  });

  test('hysteresis: same pattern but slot changed recently → stays evening', () {
    final meds = [
      for (var i = 1; i <= 4; i++) DateTime(2026, 6, 1).subtract(Duration(days: i)).add(const Duration(hours: 7)),
    ];
    final r = run(meds: meds, storedSince: now.subtract(const Duration(days: 2)));
    expect(r.medSlot, MedSlot.evening);
    expect(firstAt(r, 'meditate')!.hour, 21);
  });

  test('checked in today → no mood reminder scheduled for today', () {
    final r = run(entries: [now.subtract(const Duration(hours: 1))], moods: [Mood.tucGian]);
    final today = r.reminders.where((x) => x.payload == 'checkin' && x.when.day == now.day);
    expect(today, isEmpty);
  });

  test('all copy is one short line, no unfilled placeholders', () {
    final r = run(entries: entriesForDays(30), moods: List.filled(30, Mood.loLang), streak: 12);
    expect(r.reminders, isNotEmpty);
    for (final x in r.reminders) {
      expect(x.body.length, lessThanOrEqualTo(62), reason: x.body);
      expect(x.body.contains('{'), isFalse, reason: x.body);
      expect(x.body.split('\n').length, 1);
    }
  });
}
