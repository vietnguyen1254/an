import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/may.dart';
import '../main_tabs.dart';
import '../meditation/player_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final streakDays = context.watch<AppState>().streakDays;

    void backToSky() {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainTabs()), (route) => false);
    }

    void openFollowUp() {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const PlayerScreen(kind: PlayerKind.guided, title: 'Buông một ngày dài', guide: 'Justin Nguyễn', minutes: 12),
      ));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.loginTop, AppColors.loginMid, AppColors.loginBottom]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 60, 30, 16),
            child: Column(
              children: [
                const May(mood: Mood.vui, size: 130),
                const SizedBox(height: 24),
                const Text('Cảm ơn bạn đã kể.', style: TextStyle(fontFamily: 'Lora', fontSize: 27, height: 37 / 27, color: AppColors.ink), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  '$streakDays ngày liên tục rồi. Trời của bạn vừa có thêm một tia nắng sớm — bạn ghé xem nhé.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 15, height: 26 / 15, color: AppColors.ink.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 26),
                GestureDetector(
                  onTap: openFollowUp,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: 0.9))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GỢI Ý CHO BẠN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                        const SizedBox(height: 12),
                        Row(children: [
                          Container(width: 54, height: 54, decoration: BoxDecoration(color: AppColors.sageTint, borderRadius: BorderRadius.circular(16))),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Buông một ngày dài', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                              SizedBox(height: 3),
                              Text('Thiền dẫn · Justin Nguyễn · 12 phút', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: Color(0x8C1B2420))),
                            ]),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                AppButton(label: 'Nghe ngay', onPressed: openFollowUp),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: backToSky,
                  child: Text('Về trời', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
