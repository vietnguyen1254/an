import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/may.dart';
import 'saved_screen.dart';

class MoodCheckInScreen extends StatelessWidget {
  const MoodCheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final now = TimeOfDay.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text('Đóng', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
                  ),
                  Text(time, style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 13, color: AppColors.ink.withValues(alpha: 0.4))),
                ],
              ),
              SizedBox(height: 132, child: Center(child: May(mood: state.draftMood, size: 130))),
              const SizedBox(height: 6),
              const Text('Bạn đang cảm thấy thế nào?', style: TextStyle(fontFamily: 'Lora', fontSize: 26, height: 34 / 26, color: AppColors.ink)),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.15,
                children: moodOrder.map((m) {
                  final on = m == state.draftMood;
                  return GestureDetector(
                    onTap: () => context.read<AppState>().setDraftMood(m),
                    child: Container(
                      decoration: BoxDecoration(
                        color: on ? AppColors.ink : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: on ? AppColors.ink : AppColors.ink.withValues(alpha: 0.06)),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: moodColors[m])),
                          const SizedBox(height: 10),
                          Text(
                            moodLabels[m]!,
                            style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: on ? FontWeight.w500 : FontWeight.w400, fontSize: 13, color: on ? Colors.white : AppColors.ink),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mức độ', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.ink)),
                  Text(kIntensityLabels[state.draftIntensity - 1], style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, color: AppColors.ink.withValues(alpha: 0.5))),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: LayoutBuilder(builder: (context, constraints) {
                  final pct = state.draftIntensity / 5;
                  return Stack(alignment: Alignment.centerLeft, children: [
                    Container(height: 6, decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(3))),
                    Container(height: 6, width: constraints.maxWidth * pct, decoration: BoxDecoration(color: AppColors.sage, borderRadius: BorderRadius.circular(3))),
                    Positioned(
                      left: (constraints.maxWidth * pct - 11).clamp(0, constraints.maxWidth - 22),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)), boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.18), blurRadius: 8, offset: const Offset(0, 2))]),
                      ),
                    ),
                  ]);
                }),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _IntensityBtn(label: 'Nhẹ hơn', onTap: () => context.read<AppState>().setDraftIntensity(state.draftIntensity - 1))),
                const SizedBox(width: 8),
                Expanded(child: _IntensityBtn(label: 'Mạnh hơn', onTap: () => context.read<AppState>().setDraftIntensity(state.draftIntensity + 1))),
              ]),
              const SizedBox(height: 26),
              const Text('Điều gì ảnh hưởng đến bạn?', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.ink)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kTags.map((t) {
                  final on = state.draftTags.contains(t.key);
                  return GestureDetector(
                    onTap: () => context.read<AppState>().toggleDraftTag(t.key),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: on ? AppColors.sageTint : Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: on ? AppColors.sage.withValues(alpha: 0.4) : AppColors.ink.withValues(alpha: 0.08)),
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: Text(t.label, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: on ? FontWeight.w500 : FontWeight.w400, fontSize: 13.5, color: on ? AppColors.sageTintText : AppColors.ink.withValues(alpha: 0.65))),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              Container(
                constraints: const BoxConstraints(minHeight: 76),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                child: TextField(
                  onChanged: (v) => context.read<AppState>().setDraftNote(v),
                  maxLines: null,
                  style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14, height: 22 / 14, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Viết vài dòng cho Mây…',
                    hintStyle: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14, color: AppColors.ink.withValues(alpha: 0.35)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Lưu cảm xúc',
                onPressed: () {
                  context.read<AppState>().saveDraftEntry();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SavedScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntensityBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _IntensityBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.ink.withValues(alpha: 0.1))),
        child: Text(label, style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 13, color: AppColors.ink.withValues(alpha: 0.6))),
      ),
    );
  }
}
