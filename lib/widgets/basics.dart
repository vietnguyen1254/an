import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ToggleDot extends StatelessWidget {
  final bool on;
  const ToggleDot({super.key, required this.on});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 28,
      alignment: on ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: on ? AppColors.sage : AppColors.ink.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
    );
  }
}

class SwitchRow extends StatelessWidget {
  final String title;
  final String? sub;
  final String? time;
  final bool on;
  final bool isLast;

  const SwitchRow({super.key, required this.title, this.sub, this.time, this.on = true, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: isLast
          ? null
          : BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.ink.withValues(alpha: 0.05)))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'BeVietnamPro', fontSize: 15, color: AppColors.ink)),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(sub!, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: AppColors.inkMuted)),
                ],
              ],
            ),
          ),
          if (time != null) ...[
            Text(time!, style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.inkFaint)),
            const SizedBox(width: 8),
          ],
          ToggleDot(on: on),
        ],
      ),
    );
  }
}

class AppListRow extends StatelessWidget {
  final String title;
  final String? detail;
  final bool isLast;
  final bool danger;

  const AppListRow({super.key, required this.title, this.detail, this.isLast = false, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: isLast
          ? null
          : BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.ink.withValues(alpha: 0.05)))),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'BeVietnamPro',
                fontSize: 15,
                fontWeight: danger ? FontWeight.w500 : FontWeight.w400,
                color: danger ? AppColors.danger : AppColors.ink,
              ),
            ),
          ),
          if (detail != null) Text(detail!, style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.inkFaint)),
        ],
      ),
    );
  }
}
