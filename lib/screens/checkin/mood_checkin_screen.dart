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

    return Scaffold(
      backgroundColor: moodWash(state.draftMood),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        color: moodWash(state.draftMood),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Đóng',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontSize: 14,
                      color: AppColors.ink.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                SizedBox(
                  height: 160,
                  child: Center(child: May(mood: state.draftMood, size: 156)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bạn đang cảm thấy thế nào?',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 26,
                    height: 34 / 26,
                    color: AppColors.ink,
                  ),
                ),
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
                          border: Border.all(
                            color: on
                                ? AppColors.ink
                                : AppColors.ink.withValues(alpha: 0.06),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: moodColors[m],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              moodLabels[m]!,
                              style: TextStyle(
                                fontFamily: 'BeVietnamPro',
                                fontWeight: on
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                fontSize: 13,
                                color: on ? Colors.white : AppColors.ink,
                              ),
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
                    const Text(
                      'Mức độ',
                      style: TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${intensityLabel(state.draftIntensity)} · ${state.draftIntensity}/$kIntensityMax',
                      style: TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontWeight: FontWeight.w300,
                        fontSize: 13,
                        color: AppColors.ink.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final barColor = moodSolid(state.draftMood);
                    final pct =
                        (state.draftIntensity - 1) / (kIntensityMax - 1);
                    void setFromDx(double dx) {
                      final v = ((dx / w) * (kIntensityMax - 1)).round() + 1;
                      context.read<AppState>().setDraftIntensity(v);
                    }

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => setFromDx(d.localPosition.dx),
                      onHorizontalDragStart: (d) =>
                          setFromDx(d.localPosition.dx),
                      onHorizontalDragUpdate: (d) =>
                          setFromDx(d.localPosition.dx),
                      child: SizedBox(
                        height: 34,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.ink.withValues(alpha: 0.09),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            Container(
                              height: 6,
                              width: (w * pct).clamp(0.0, w),
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            Positioned(
                              left: (w * pct - 12).clamp(0.0, w - 24),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: barColor.withValues(alpha: 0.55),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.ink.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 26),
                const Text(
                  'Điều gì ảnh hưởng đến bạn?',
                  style: TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                _TagRows(
                  tags: kTags,
                  selected: state.draftTags,
                  onToggle: (k) => context.read<AppState>().toggleDraftTag(k),
                ),
                const SizedBox(height: 22),
                Container(
                  constraints: const BoxConstraints(minHeight: 76),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.ink.withValues(alpha: 0.06),
                    ),
                  ),
                  child: TextField(
                    onChanged: (v) => context.read<AppState>().setDraftNote(v),
                    maxLines: null,
                    style: const TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      height: 22 / 14,
                      color: AppColors.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Viết vài dòng cho Mây…',
                      hintStyle: TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: AppColors.ink.withValues(alpha: 0.35),
                      ),
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
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SavedScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Influence tags, laid out on exactly two lines (top row gets the first
/// half, bottom row the rest).
class _TagRows extends StatelessWidget {
  final List<TagDef> tags;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const _TagRows({
    required this.tags,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Exactly two lines: first 4 tags on top, the last 3 below. Chips flex
    // to fill each line evenly.
    final split = (tags.length / 2).ceil();
    final rows = [tags.sublist(0, split), tags.sublist(split)];
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var j = 0; j < rows[i].length; j++) ...[
                if (j > 0) const SizedBox(width: 8),
                Expanded(child: _chip(rows[i][j])),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _chip(TagDef t) {
    final on = selected.contains(t.key);
    return GestureDetector(
      onTap: () => onToggle(t.key),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: on ? AppColors.sageTint : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: on
                ? AppColors.sage.withValues(alpha: 0.4)
                : AppColors.ink.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Text(
            t.label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontWeight: on ? FontWeight.w500 : FontWeight.w400,
              fontSize: 12,
              color: on
                  ? AppColors.sageTintText
                  : AppColors.ink.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }
}
