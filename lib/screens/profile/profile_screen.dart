import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/basics.dart';
import '../premium/payment_plan_labels.dart';
import '../premium/paywall_screen.dart';
import '../premium/plan_screen.dart';
import 'privacy_screen.dart';
import 'reminders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<AppState>().plan;

    return Container(
      color: AppColors.appBg,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bạn', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                child: Row(children: [
                  Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.sageTint)),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nguyễn Thuỳ Linh', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 17, color: AppColors.ink)),
                        SizedBox(height: 3),
                        Text('Tham gia tháng 3, 2026', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: Color(0x801B2420))),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => plan == PlanTier.free ? const PaywallScreen() : const PlanScreen())),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(colors: [AppColors.premiumDarkA, AppColors.premiumDarkB]),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GÓI CỦA BẠN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.5))),
                          const SizedBox(height: 6),
                          Text(planLabel(plan), style: const TextStyle(fontFamily: 'Lora', fontSize: 18, color: Colors.white)),
                          if (plan != PlanTier.free) ...[
                            const SizedBox(height: 4),
                            Text('Gia hạn ${plan == PlanTier.yearly ? '12/03/2027' : '03/10/2026'}', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: Colors.white.withValues(alpha: 0.5))),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.24))),
                      child: Text(plan == PlanTier.free ? 'Nâng cấp' : 'Quản lý', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 12.5, color: Colors.white.withValues(alpha: 0.8))),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 26),
              Text('NHẮC NHỞ', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RemindersScreen())),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                  clipBehavior: Clip.hardEdge,
                  child: const Column(children: [
                    SwitchRow(title: 'Ghi cảm xúc buổi tối', time: '21:00'),
                    SwitchRow(title: 'Thở giữa giờ làm', time: '15:00', isLast: true),
                  ]),
                ),
              ),
              const SizedBox(height: 26),
              Text('CÀI ĐẶT', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                clipBehavior: Clip.hardEdge,
                child: Column(children: [
                  const AppListRow(title: 'Ngôn ngữ', detail: 'Tiếng Việt'),
                  const SwitchRow(title: 'Khoá bằng Face ID', on: true),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
                    child: const AppListRow(title: 'Sao lưu & xuất dữ liệu'),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
                    child: const AppListRow(title: 'Quyền riêng tư', isLast: true),
                  ),
                ]),
              ),
              const SizedBox(height: 22),
              Text(
                'Dữ liệu cảm xúc chỉ lưu trên máy bạn.\nAn 1.0 · làm tại Việt Nam',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, height: 21 / 12.5, color: AppColors.ink.withValues(alpha: 0.45)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
