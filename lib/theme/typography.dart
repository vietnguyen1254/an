import 'package:flutter/material.dart';
import 'colors.dart';

/// Lora (serif) for emotional / editorial headings, Be Vietnam Pro (sans,
/// full Vietnamese diacritic support) for everything else.
class AppText {
  AppText._();

  static const _serif = 'Lora';
  static const _sans = 'BeVietnamPro';

  static const display = TextStyle(
    fontFamily: _serif, fontSize: 30, height: 40 / 30, color: AppColors.ink,
  );
  static const h1 = TextStyle(
    fontFamily: _serif, fontSize: 27, height: 35 / 27, color: AppColors.ink,
  );
  static const h2 = TextStyle(
    fontFamily: _serif, fontSize: 22, height: 29 / 22, color: AppColors.ink,
  );
  static const h3 = TextStyle(
    fontFamily: _serif, fontSize: 19, height: 27 / 19, color: AppColors.ink,
  );
  static TextStyle eyebrow = TextStyle(
    fontFamily: _sans, fontSize: 11, letterSpacing: 1.1, color: AppColors.inkFaint,
  );
  static TextStyle body = TextStyle(
    fontFamily: _sans, fontWeight: FontWeight.w300, fontSize: 15, height: 26 / 15, color: AppColors.inkSoft,
  );
  static TextStyle bodySm = TextStyle(
    fontFamily: _sans, fontWeight: FontWeight.w300, fontSize: 13, height: 21 / 13, color: AppColors.inkMuted,
  );
  static const label = TextStyle(
    fontFamily: _sans, fontSize: 15, color: AppColors.ink,
  );
  static TextStyle labelSm = TextStyle(
    fontFamily: _sans, fontSize: 13, color: AppColors.inkMuted,
  );
  static const button = TextStyle(
    fontFamily: _sans, fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white,
  );
}
