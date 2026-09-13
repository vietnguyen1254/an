import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../utils/vn_date.dart';
import '../../widgets/app_button.dart';
import '../../widgets/may.dart';
import '../main_tabs.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final plan = appState.plan;
    final isYearly = plan == PlanTier.yearly;
    final renewsAt = appState.planRenewsAt;

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
                Transform.translate(
                  offset: const Offset(-15, 0),
                  child: const May(mood: Mood.vui, size: 150),
                ),
                const SizedBox(height: 30),
                Text('AN PREMIUM', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1.2, color: const Color(0xFF2F5B72))),
                const SizedBox(height: 12),
                const Text('Bạn đã mở khoá\ntoàn bộ An.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Lora', fontSize: 28, height: 37 / 28, color: AppColors.ink)),
                const SizedBox(height: 14),
                Text(
                  'Gói ${isYearly ? 'theo năm · 1.699.000đ' : 'theo tháng · 199.000đ'}.'
                  '${renewsAt != null ? ' Tự động gia hạn ${formatShortDate(renewsAt)}.' : ''}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14.5, height: 25 / 14.5, color: AppColors.ink.withValues(alpha: 0.62)),
                ),
                const Spacer(),
                AppButton(
                  label: 'Quay lại màn hình chính',
                  onPressed: goHome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
