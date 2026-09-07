import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/may.dart';
import '../main_tabs.dart';
import '../meditation/player_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<AppState>().plan;
    final isYearly = plan == PlanTier.yearly;

    void goHome() {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainTabs()), (route) => false);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.loginTop, AppColors.loginMid, AppColors.loginBottom])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 60, 30, 16),
            child: Column(
              children: [
                const May(mood: Mood.vui, size: 130),
                const SizedBox(height: 30),
                Text('AN PREMIUM', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1.2, color: const Color(0xFF2F5B72))),
                const SizedBox(height: 12),
                const Text('Bạn đã mở khoá\ntoàn bộ An.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Lora', fontSize: 28, height: 37 / 28, color: AppColors.ink)),
                const SizedBox(height: 14),
                Text(
                  'Gói ${isYearly ? 'theo năm · 1.699.000đ' : 'theo tháng · 199.000đ'}. Bảy ngày đầu miễn phí, gia hạn ${isYearly ? '12/03/2027' : '03/10/2026'}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14.5, height: 25 / 14.5, color: AppColors.ink.withValues(alpha: 0.62)),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.82), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: 0.9))),
                  child: Row(children: [
                    Container(width: 54, height: 54, decoration: BoxDecoration(color: AppColors.sageTint, borderRadius: BorderRadius.circular(16))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BẮT ĐẦU TỪ ĐÂY', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                          const SizedBox(height: 5),
                          const Text('Trở về hơi thở', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                          const SizedBox(height: 3),
                          Text('Thiền dẫn · Justin Nguyễn · 12 phút', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                  ]),
                ),
                const Spacer(),
                AppButton(
                  label: 'Nghe bài đầu tiên',
                  onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => const PlayerScreen(kind: PlayerKind.guided, title: 'Trở về hơi thở', guide: 'Justin Nguyễn', minutes: 12),
                  )),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: goHome,
                  child: Text('Về trời của tôi', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
