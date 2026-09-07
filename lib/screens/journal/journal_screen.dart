import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import 'day_detail_screen.dart';

const _dayColors = [AppColors.sage, AppColors.rose, AppColors.lavender, Color(0x241B2420), AppColors.sage, AppColors.sage, AppColors.blueGray];
const _rangeTabs = ['Tháng', 'Tuần', 'Năm'];

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<AppState>().entries;

    return Container(
      color: AppColors.appBg,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cảm xúc', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
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
                      const Flexible(child: Text('Tháng 9, 2026', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink))),
                      Text('24 / 30 ngày', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.45))),
                    ]),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 7,
                      mainAxisSpacing: 7,
                      children: List.generate(30, (i) {
                        final filled = i <= 23;
                        return GestureDetector(
                          onTap: () {
                            if (entries.isNotEmpty) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => DayDetailScreen(entryId: entries.first.id)));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(color: filled ? _dayColors[i % 7] : AppColors.ink.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Wrap(spacing: 14, runSpacing: 8, children: const [
                      _Legend(color: AppColors.sage, label: 'Bình yên'),
                      _Legend(color: AppColors.rose, label: 'Vui'),
                      _Legend(color: AppColors.lavender, label: 'Lo lắng'),
                      _Legend(color: Color(0x241B2420), label: 'Chưa ghi'),
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
                    Text('MÂY NHẬN THẤY', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                    const SizedBox(height: 10),
                    const Text('Bạn bình yên nhất vào Chủ nhật, và hay lo lắng vào chiều thứ Hai.', style: TextStyle(fontFamily: 'Lora', fontSize: 18, height: 27 / 18, color: AppColors.ink)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _StatCard(label: 'Chủ đề nổi bật', value: 'Công việc', meta: '8 lần trong 30 ngày')),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Thiền', value: '3 giờ 40', meta: 'tháng này')),
              ]),
            ],
          ),
        ),
      ),
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
