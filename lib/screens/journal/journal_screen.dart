import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/journal_entry.dart';
import '../../models/mood.dart';
import '../../services/mood_insight.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import 'day_detail_screen.dart';

const _rangeTabs = ['Tuần', 'Tháng'];
const _weekdayShort = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
const _emptyDayColor = Color(0x0F1B2420); // matches AppColors.ink @ 6%

String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

class _TopTag {
  final String label;
  final int count;
  const _TopTag(this.label, this.count);
}

_TopTag? _topTag(List<JournalEntry> entries) {
  final counts = <String, int>{};
  for (final e in entries) {
    for (final t in e.tags) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
  }
  if (counts.isEmpty) return null;
  final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
  final label = kTags.firstWhere((t) => t.key == top.key, orElse: () => TagDef(top.key, top.key)).label;
  return _TopTag(label, top.value);
}

String _rangeHeaderLabel(bool isWeek, DateTime start, DateTime end) {
  if (!isWeek) return 'Tháng ${start.month}, ${start.year}';
  if (start.month == end.month) return 'Tuần ${start.day} – ${end.day} thg ${start.month}';
  return 'Tuần ${start.day} thg ${start.month} – ${end.day} thg ${end.month}';
}

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _tab = 0; // 0 = Tuần, 1 = Tháng

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<AppState>().entries;
    final now = DateTime.now();
    final isWeek = _tab == 0;

    final rangeStart = isWeek
        ? DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1))
        : DateTime(now.year, now.month, 1);
    final rangeDays = isWeek ? 7 : DateTime(now.year, now.month + 1, 0).day;
    final rangeEnd = rangeStart.add(Duration(days: rangeDays - 1));

    final byDay = <String, JournalEntry>{};
    for (final e in entries) {
      byDay[_dayKey(e.entryDate)] = e;
    }

    final entriesInRange = entries.where((e) {
      final d = DateTime(e.entryDate.year, e.entryDate.month, e.entryDate.day);
      return !d.isBefore(rangeStart) && !d.isAfter(rangeEnd);
    }).toList();

    final recordedDays = List.generate(rangeDays, (i) => rangeStart.add(Duration(days: i))).where((d) => byDay.containsKey(_dayKey(d))).length;

    final topTag = _topTag(entriesInRange);
    final insight = generateInsight(entriesInRange);

    void openDay(DateTime d) {
      final entry = byDay[_dayKey(d)];
      if (entry == null) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => DayDetailScreen(entryId: entry.id)));
    }

    return Container(
      color: AppColors.appBg,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lịch sử', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: List.generate(_rangeTabs.length, (i) {
                    final active = i == _tab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: active ? Colors.white : null, borderRadius: BorderRadius.circular(11)),
                          child: Text(_rangeTabs[i], style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: active ? FontWeight.w500 : FontWeight.w400, fontSize: 13, color: active ? AppColors.ink : AppColors.ink.withValues(alpha: 0.5))),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Flexible(child: Text(_rangeHeaderLabel(isWeek, rangeStart, rangeEnd), style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink))),
                      Text('$recordedDays / $rangeDays ngày', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.45))),
                    ]),
                    const SizedBox(height: 16),
                    if (isWeek)
                      _WeekGrid(start: rangeStart, byDay: byDay, onTapDay: openDay)
                    else
                      _MonthGrid(start: rangeStart, days: rangeDays, byDay: byDay, onTapDay: openDay),
                    const SizedBox(height: 18),
                    Wrap(spacing: 14, runSpacing: 8, children: [
                      for (final m in moodOrder) _Legend(color: moodColors[m]!, label: moodLabels[m]!),
                      const _Legend(color: _emptyDayColor, label: 'Chưa ghi'),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(insight.label, style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                    const SizedBox(height: 10),
                    Text(insight.text, style: const TextStyle(fontFamily: 'Lora', fontSize: 18, height: 27 / 18, color: AppColors.ink)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: _StatCard(
                    label: 'Chủ đề nổi bật',
                    value: topTag?.label ?? '—',
                    meta: topTag != null ? '${topTag.count} lần trong $rangeDays ngày' : 'Chưa có dữ liệu',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Thiền', value: '0 phút', meta: isWeek ? 'tuần này' : 'tháng này')),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekGrid extends StatelessWidget {
  final DateTime start;
  final Map<String, JournalEntry> byDay;
  final void Function(DateTime) onTapDay;
  const _WeekGrid({required this.start, required this.byDay, required this.onTapDay});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final day = start.add(Duration(days: i));
        final entry = byDay[_dayKey(day)];
        final color = entry != null ? moodColors[entry.mood]! : _emptyDayColor;
        final isToday = _dayKey(day) == _dayKey(DateTime.now());
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 6 ? 0 : 8),
            child: Column(
              children: [
                Text(_weekdayShort[i], style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.ink.withValues(alpha: 0.4))),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => onTapDay(day),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday ? Border.all(color: AppColors.ink.withValues(alpha: 0.55), width: 1.5) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text('${day.day}', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 13, fontWeight: FontWeight.w500, color: entry != null ? Colors.white.withValues(alpha: 0.9) : AppColors.ink.withValues(alpha: 0.35))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime start;
  final int days;
  final Map<String, JournalEntry> byDay;
  final void Function(DateTime) onTapDay;
  const _MonthGrid({required this.start, required this.days, required this.byDay, required this.onTapDay});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 7,
      mainAxisSpacing: 7,
      children: List.generate(days, (i) {
        final day = start.add(Duration(days: i));
        final entry = byDay[_dayKey(day)];
        final color = entry != null ? moodColors[entry.mood]! : _emptyDayColor;
        return GestureDetector(
          onTap: () => onTapDay(day),
          child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
        );
      }),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 11.5, color: AppColors.ink.withValues(alpha: 0.5))),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String meta;
  const _StatCard({required this.label, required this.value, required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: AppColors.ink.withValues(alpha: 0.5))),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontFamily: 'Lora', fontSize: 21, color: AppColors.ink)),
          const SizedBox(height: 4),
          Text(meta, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: AppColors.ink.withValues(alpha: 0.45))),
        ],
      ),
    );
  }
}
