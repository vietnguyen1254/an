import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../main_tabs.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _continueAs(BuildContext context) {
    context.read<AppState>().logIn();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainTabs()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.loginTop, AppColors.loginMid, AppColors.loginBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 24),
            child: Column(
              children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.9))),
                const SizedBox(height: 28),
                const Text(
                  'Lưu lại hành trình\ncủa bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Lora', fontSize: 27, height: 35 / 27, color: AppColors.ink),
                ),
                const SizedBox(height: 12),
                Text(
                  'Đăng nhập để cảm xúc và chuỗi ngày của bạn không bị mất khi đổi máy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14.5, height: 24 / 14.5, color: AppColors.ink.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 36),
                _AuthButton(label: 'Tiếp tục với Apple', dotColor: const Color(0xFFF6F8F6), dark: true, onTap: () => _continueAs(context)),
                const SizedBox(height: 11),
                _AuthButton(label: 'Tiếp tục với Google', dotColor: const Color(0xFFC4A38B), onTap: () => _continueAs(context)),
                const SizedBox(height: 11),
                _AuthButton(label: 'Tiếp tục với Facebook', dotColor: const Color(0xFF5A7FB8), onTap: () => _continueAs(context)),
                const Spacer(),
                Text(
                  'Tiếp tục nghĩa là bạn đồng ý với Điều khoản\nvà Chính sách riêng tư của An - Thiền và Chữa lành.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 11.5, height: 18 / 11.5, color: AppColors.ink.withValues(alpha: 0.42)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final Color dotColor;
  final bool dark;
  final VoidCallback onTap;

  const _AuthButton({required this.label, required this.dotColor, this.dark = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dark ? AppColors.ink : Colors.white,
      borderRadius: BorderRadius.circular(27),
      child: InkWell(
        borderRadius: BorderRadius.circular(27),
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
            border: dark ? null : Border.all(color: AppColors.ink.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
              const SizedBox(width: 11),
              Text(label, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15.5, color: dark ? const Color(0xFFF6F8F6) : AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}
