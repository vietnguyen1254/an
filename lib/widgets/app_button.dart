import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum AppButtonVariant { dark, sage, light, mint, danger, outlineDark, outlineLight }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.dark,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, text, border) = switch (variant) {
      AppButtonVariant.dark => (AppColors.ink, Colors.white, null),
      AppButtonVariant.sage => (AppColors.sage, Colors.white, null),
      AppButtonVariant.light => (Colors.white, AppColors.ink, null),
      AppButtonVariant.mint => (AppColors.premiumMint, const Color(0xFF16201E), null),
      AppButtonVariant.danger => (AppColors.danger, Colors.white, null),
      AppButtonVariant.outlineDark => (Colors.transparent, AppColors.inkMuted, AppColors.ink.withValues(alpha: 0.14)),
      AppButtonVariant.outlineLight => (Colors.transparent, Colors.white.withValues(alpha: 0.9), Colors.white.withValues(alpha: 0.24)),
    };
    return Opacity(
      opacity: onPressed == null ? 0.4 : 1,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(height / 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(height / 2),
            onTap: onPressed,
            child: Container(
              decoration: border != null
                  ? BoxDecoration(borderRadius: BorderRadius.circular(height / 2), border: Border.all(color: border))
                  : null,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 16, color: text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
