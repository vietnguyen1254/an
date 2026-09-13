import '../../models/mood.dart';
import 'notification_service.dart';
import 'reminder_copy.dart';

class ScheduleResult {
  final List<PlannedReminder> reminders;
  final MedSlot medSlot;
  final DateTime medSlotSince;
  const ScheduleResult(this.reminders, this.medSlot, this.medSlotSince);
}

/// Turns the recorded history into the next few days of reminder times + copy.
/// Pure — [AppState] feeds it data and persists the returned hysteresis state.
///
/// Timing model
///  • Mood check-in: 17:45 for the first 18 days (late-afternoon low), then
///    ramps to 20:15 (post-dinner calm) over days 18–21. If the user's own
///    check-ins cluster far from that, it follows them instead.
///  • Meditation: 21:15 by default; if the last 7 days of sessions clearly
///    favour another part of the day, it shifts there (≤ once/week).
class ReminderScheduler {
  static const _moodBaseEarly = 17 * 60 + 45; // 17:45
  static const _moodBaseLate = 20 * 60 + 15; // 20:15
  static const _medBaseEvening = 21 * 60 + 15; // 21:15
  static const _phaseDays = 18;
  static const _rampDays = 3;

  static ScheduleResult build({
    required bool moodEnabled,
    required bool medEnabled,
    required List<DateTime> entryTimes, // every entry's timestamp
    required List<Mood> recentMoods, // newest first
    required int streakDays,
    required List<DateTime> meditationTimes, // every logged chunk timestamp
    required MedSlot storedMedSlot,
    required DateTime storedMedSlotSince,
    DateTime? now,
    int days = 7,
  }) {
    final t = now ?? DateTime.now();
    final today = DateTime(t.year, t.month, t.day);

    // ---- mood timing ----
    final firstEntry = entryTimes.isEmpty
        ? null
        : entryTimes.reduce((a, b) => a.isBefore(b) ? a : b);
    final daysSinceStart = firstEntry == null
        ? 0
        : today.difference(DateTime(firstEntry.year, firstEntry.month, firstEntry.day)).inDays;

    int moodBaseFor(int d) {
      if (d < _phaseDays) return _moodBaseEarly;
      if (d >= _phaseDays + _rampDays) return _moodBaseLate;
      return (_moodBaseEarly +
              (_moodBaseLate - _moodBaseEarly) * (d - _phaseDays + 1) / (_rampDays + 1))
          .round();
    }

    // Behavioural override: if the user's own check-ins sit >90 min from the
    // phase time, meet them ~30 min before their usual moment.
    final recentEntryMins = entryTimes
        .where((e) => today.difference(DateTime(e.year, e.month, e.day)).inDays <= 14)
        .map((e) => e.hour * 60 + e.minute)
        .toList()
      ..sort();
    int? moodOverride;
    if (recentEntryMins.length >= 5) {
      final med = _median(recentEntryMins.take(7).toList()..sort());
      if ((med - moodBaseFor(daysSinceStart)).abs() > 90) {
        moodOverride = (med - 30).clamp(7 * 60, 22 * 60 + 30);
      }
    }

    final lastEntry = entryTimes.isEmpty
        ? null
        : entryTimes.reduce((a, b) => a.isAfter(b) ? a : b);
    final daysSinceLastEntry =
        lastEntry == null ? 999 : today.difference(DateTime(lastEntry.year, lastEntry.month, lastEntry.day)).inDays;
    final checkedInToday = daysSinceLastEntry == 0;
    final lastMood = recentMoods.isEmpty ? null : recentMoods.first;

    // ---- meditation timing ----
    final medWeek = meditationTimes
        .where((m) => today.difference(DateTime(m.year, m.month, m.day)).inDays <= 6)
        .toList();
    final slotEvents = <MedSlot, Set<String>>{
      MedSlot.morning: {},
      MedSlot.midday: {},
      MedSlot.evening: {},
    };
    for (final m in medWeek) {
      slotEvents[_slotOf(m.hour)]!.add('${m.year}-${m.month}-${m.day}');
    }
    final counts = slotEvents.map((k, v) => MapEntry(k, v.length));
    final total = counts.values.fold(0, (a, b) => a + b);
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    var candidate = MedSlot.evening;
    if (total >= 3 &&
        top.key != MedSlot.evening &&
        (top.value >= (total / 2).ceil() || top.value - counts[MedSlot.evening]! >= 2)) {
      candidate = top.key;
    }

    var medSlot = storedMedSlot;
    var medSince = storedMedSlotSince;
    if (candidate != storedMedSlot && t.difference(storedMedSlotSince).inDays >= 7) {
      medSlot = candidate;
      medSince = t;
    }

    int medMinute;
    if (medSlot == MedSlot.evening) {
      medMinute = _medBaseEvening;
    } else {
      final mins = medWeek
          .where((m) => _slotOf(m.hour) == medSlot)
          .map((m) => m.hour * 60 + m.minute)
          .toList()
        ..sort();
      medMinute = mins.isEmpty
          ? (medSlot == MedSlot.morning ? 7 * 60 : 12 * 60 + 30)
          : (_median(mins) - 15).clamp(5 * 60 + 30, 21 * 60);
    }

    final everMeditated = meditationTimes.isNotEmpty;
    final meditatedToday = medWeek.any((m) => today.difference(DateTime(m.year, m.month, m.day)).inDays == 0);
    final meditatedYesterday = medWeek.any((m) => today.difference(DateTime(m.year, m.month, m.day)).inDays == 1);
    final medStreak = _streak(meditationTimes, today);
    final recentDominantMood = _dominant(recentMoods.take(5).toList());

    // ---- assemble ----
    final out = <PlannedReminder>[];
    for (var k = 0; k < days; k++) {
      final day = today.add(Duration(days: k));

      if (moodEnabled && !(k == 0 && checkedInToday)) {
        final minute = moodOverride ?? moodBaseFor(daysSinceStart + k);
        final when = DateTime(day.year, day.month, day.day, minute ~/ 60, minute % 60);
        if (when.isAfter(t)) {
          out.add(PlannedReminder(
            id: 1000 + k,
            when: when,
            title: 'Mây',
            body: moodReminderLine(
              streakDays: streakDays,
              lastMood: lastMood,
              phaseNew: daysSinceStart + k < _phaseDays,
              daysSinceLastEntry: daysSinceLastEntry,
              reminderHour: minute ~/ 60,
            ),
            payload: 'checkin',
          ));
        }
      }

      if (medEnabled && !(k == 0 && meditatedToday)) {
        final when = DateTime(day.year, day.month, day.day, medMinute ~/ 60, medMinute % 60);
        if (when.isAfter(t)) {
          out.add(PlannedReminder(
            id: 2000 + k,
            when: when,
            title: 'Mây',
            body: meditationReminderLine(
              slot: medSlot,
              everMeditated: everMeditated,
              meditatedYesterday: meditatedYesterday,
              recentDominantMood: recentDominantMood,
              medStreakDays: medStreak,
            ),
            payload: 'meditate',
          ));
        }
      }
    }

    return ScheduleResult(out, medSlot, medSince);
  }

  static MedSlot _slotOf(int hour) {
    if (hour >= 5 && hour <= 10) return MedSlot.morning;
    if (hour >= 11 && hour <= 15) return MedSlot.midday;
    return MedSlot.evening;
  }

  static int _median(List<int> sorted) {
    if (sorted.isEmpty) return 0;
    final n = sorted.length;
    return n.isOdd ? sorted[n ~/ 2] : ((sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2).round();
  }

  static Mood? _dominant(List<Mood> moods) {
    if (moods.isEmpty) return null;
    final c = <Mood, int>{};
    for (final m in moods) {
      c[m] = (c[m] ?? 0) + 1;
    }
    return c.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Consecutive days (ending today or yesterday) with at least one timestamp.
  static int _streak(List<DateTime> times, DateTime today) {
    final days = times.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (days.isEmpty) return 0;
    final yesterday = today.subtract(const Duration(days: 1));
    if (days.first != today && days.first != yesterday) return 0;
    var streak = 0;
    var cursor = days.first;
    for (final d in days) {
      if (d == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
