import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/may.dart';
import '../meditation/player_screen.dart';

class DayDetailScreen extends StatelessWidget {
  final String entryId;
  const DayDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<AppState>().entries;
    final matches = entries.where((e) => e.id == entryId);
    if (matches.isEmpty) return const SizedBox.shrink();
    final entry = matches.first;

    final tagLabels = entry.tags
        .map(
          (k) => kTags
              .firstWhere((t) => t.key == k, orElse: () => TagDef(k, k))
              .label,
        )
        .toList();

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
                  Text(
                    'Tháng ${entry.entryDate.month}',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontSize: 14,
                      color: AppColors.ink.withValues(alpha: 0.5),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Sửa',
                        style: TextStyle(
                          fontFamily: 'BeVietnamPro',
                          fontSize: 14,
                          color: AppColors.ink.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Xoá',
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontSize: 14,
                            color: AppColors.ink.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                entry.dateLabel,
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                  color: AppColors.ink.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                moodLabels[entry.mood]!,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 27,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(
                height: 138,
                child: Center(child: May(mood: entry.mood, size: 130)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.ink.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MỨC ĐỘ',
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontSize: 10.5,
                            letterSpacing: 1,
                            color: AppColors.ink.withValues(alpha: 0.45),
                          ),
                        ),
                        Text(
                          intensityLabel(entry.intensity),
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                            color: AppColors.ink.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          return Container(
                            height: 6,
                            color: AppColors.ink.withValues(alpha: 0.09),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width:
                                    c.maxWidth *
                                    entry.intensity /
                                    kIntensityMax,
                                color: moodSolid(entry.mood),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ĐIỀU ẢNH HƯỞNG',
                      style: TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontSize: 10.5,
                        letterSpacing: 1,
                        color: AppColors.ink.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tagLabels
                          .map(
                            (label) => Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.sageTint,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                widthFactor: 1,
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontFamily: 'BeVietnamPro',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: AppColors.sageTintText,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'BẠN VIẾT',
                      style: TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontSize: 10.5,
                        letterSpacing: 1,
                        color: AppColors.ink.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.note.isEmpty ? '—' : entry.note,
                      style: TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontWeight: FontWeight.w300,
                        fontSize: 14.5,
                        height: 26 / 14.5,
                        color: AppColors.ink.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PlayerScreen(
                      kind: PlayerKind.guided,
                      title: 'Buông một ngày dài',
                      guide: 'Justin Nguyễn',
                      minutes: 12,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.ink.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4EDF3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SAU ĐÓ BẠN ĐÃ NGHE',
                              style: TextStyle(
                                fontFamily: 'BeVietnamPro',
                                fontSize: 10.5,
                                letterSpacing: 1,
                                color: AppColors.ink.withValues(alpha: 0.45),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Buông một ngày dài · 12 phút',
                              style: TextStyle(
                                fontFamily: 'BeVietnamPro',
                                fontWeight: FontWeight.w500,
                                fontSize: 14.5,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
