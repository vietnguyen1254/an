import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';

class StreaksScreen extends StatelessWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final streakDays = context.watch<AppState>().streakDays;
    final pips = List.generate(7, (i) => i < streakDays.clamp(0, 6));

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Trời của bạn', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                  gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEAF2EE), Color(0xFFD3E4DC)]),
                ),
                child: Column(children: [
                  Text('$streakDays', style: const TextStyle(fontFamily: 'Lora', fontSize: 46, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  Text('ngày liên tục ghé qua', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.55))),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(7, (i) {
                      final on = pips[i];
                      return Padding(
                        padding: EdgeInsets.only(right: i < 6 ? 7 : 0),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color: on ? AppColors.sage : Colors.white.withValues(alpha: 0.7),
                            border: on ? null : Border.all(color: AppColors.ink.withValues(alpha: 0.2)),
                          ),
                        ),
                      );
                    }),
                  ),
                ]),
              ),
              const SizedBox(height: 26),
              Text('VẬT TRANG TRÍ', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _DecoCard(title: 'Nắng sớm', status: 'Đã mở', unlocked: true, color: const Color(0xFFFBE7EF)),
                  _DecoCard(title: 'Gió nhẹ', status: 'Đã mở', unlocked: true, color: AppColors.sageTint),
                  _DecoCard(title: 'Đèn lồng', status: 'còn 3 ngày', unlocked: false, color: const Color(0xFFEEF0ED)),
                  _DecoCard(title: 'Sao đêm', status: '30 ngày', unlocked: false, color: const Color(0xFFEEF0ED)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.sage.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('Chuỗi ngày không mất nếu bạn nghỉ một hôm. Mây vẫn ở đó.', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 22 / 13.5, color: AppColors.ink.withValues(alpha: 0.7))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecoCard extends StatelessWidget {
  final String title;
  final String status;
  final bool unlocked;
  final Color color;
  const _DecoCard({required this.title, required this.status, required this.unlocked, required this.color});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.ink)),
            const SizedBox(height: 2),
            Text(status, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12, color: unlocked ? AppColors.sage : AppColors.ink.withValues(alpha: 0.45))),
          ],
        ),
      ),
    );
  }
}
