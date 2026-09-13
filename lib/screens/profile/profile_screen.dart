import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_lock.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/basics.dart';
import '../../widgets/user_avatar.dart';
import '../premium/payment_plan_labels.dart';
import '../premium/paywall_screen.dart';
import '../premium/plan_screen.dart';
import '../onboarding/login_screen.dart';
import 'avatar_picker_screen.dart';
import 'privacy_screen.dart';

String _providerName(String? p) => switch (p) {
  'google' => 'Google',
  'apple' => 'Apple',
  'facebook' => 'Facebook',
  _ => 'SSO',
};

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final plan = state.plan;

    return Container(
      color: AppColors.appBg,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin cá nhân',
                style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AvatarPickerScreen()),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          UserAvatar(avatarId: state.authAvatar, size: 56),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
                              ),
                              child: Icon(Icons.edit_rounded, size: 11, color: AppColors.ink.withValues(alpha: 0.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.isLoggedIn ? state.userName : 'Khách',
                            style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 17, color: AppColors.ink),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            state.authEmail ??
                                (state.isLoggedIn
                                    ? 'Đã đăng nhập qua ${_providerName(state.authProvider)}'
                                    : 'Chưa đăng nhập'),
                            style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: Color(0x801B2420)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => plan == PlanTier.free ? const PaywallScreen() : const PlanScreen(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(colors: [AppColors.premiumDarkA, AppColors.premiumDarkB]),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GÓI CỦA BẠN',
                              style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              planLabel(plan),
                              style: const TextStyle(fontFamily: 'Lora', fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                        ),
                        child: Text(
                          plan == PlanTier.free ? 'Nâng cấp' : 'Quản lý',
                          style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 12.5, color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'NHẮC NHỞ',
                style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45)),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.read<AppState>().setMoodReminder(!state.moodReminderEnabled),
                      child: SwitchRow(
                        title: 'Nhắc ghi cảm xúc',
                        sub: 'Giờ giấc Mây tự chỉnh theo bạn',
                        on: state.moodReminderEnabled,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.read<AppState>().setMeditationReminder(!state.meditationReminderEnabled),
                      child: SwitchRow(
                        title: 'Nhắc thiền',
                        sub: 'Học theo giờ bạn hay thiền',
                        on: state.meditationReminderEnabled,
                        isLast: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'CÀI ĐẶT',
                style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45)),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    const _FaceIdRow(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                      ),
                      child: const AppListRow(title: 'Quyền riêng tư', isLast: true),
                    ),
                  ],
                ),
              ),
              if (state.isLoggedIn) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () async {
                    await context.read<AppState>().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: const AppListRow(title: 'Đăng xuất', isLast: true),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Text(
                'Nhật ký cảm xúc lưu trên máy và trong tài khoản của bạn.\n'
                'An 1.0 — Thiền và Chữa lành. Tự hào là ứng dụng Việt.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.w300,
                  fontSize: 12.5,
                  height: 21 / 12.5,
                  color: AppColors.ink.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Khoá bằng Face ID" — a real toggle. Turning it on runs a biometric check
/// first (and reports if the device can't do one); the setting is
/// device-local, never synced.
class _FaceIdRow extends StatelessWidget {
  const _FaceIdRow();

  Future<void> _toggle(BuildContext context) async {
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    if (state.appLockEnabled) {
      await state.setAppLock(false);
      return;
    }
    if (!await AppLock.instance.isAvailable) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Thiết bị chưa cài Face ID, Touch ID hoặc mật mã.'),
      ));
      return;
    }
    if (await AppLock.instance.authenticate('Bật khoá cho An')) {
      await state.setAppLock(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final on = context.watch<AppState>().appLockEnabled;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggle(context),
      child: SwitchRow(title: 'Khoá bằng Face ID', sub: 'Mở app phải xác thực', on: on),
    );
  }
}
