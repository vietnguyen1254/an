import 'package:flutter/material.dart';
import '../models/mood.dart';

/// "Quiet luxury" palette from the Claude Design export (An copy.dc.html).
/// Sky-blue backgrounds so Mây stands over them; jade / rose / lavender
/// accents. Dark backgrounds are reserved for meditation sessions and
/// Premium screens.
class AppColors {
  AppColors._();

  static const ink = Color(0xFF1B2420);
  static Color inkSoft = ink.withValues(alpha: 0.7);
  static Color inkMuted = ink.withValues(alpha: 0.55);
  static Color inkFaint = ink.withValues(alpha: 0.45);
  static Color inkHairline = ink.withValues(alpha: 0.08);

  static const sage = Color(0xFF6F9E8A);
  static const sageDeep = Color(0xFF4E7A68);
  static const sageTint = Color(0xFFE3EDE7);
  static const sageTintText = Color(0xFF3D6555);

  static const lavender = Color(0xFFA79BC4);
  static const lavenderTint = Color(0xFFEDE9F4);
  static const lavenderTintText = Color(0xFF4F4468);

  static const rose = Color(0xFFF6BDD4);
  static const blueGray = Color(0xFF8496B8);
  static const tan = Color(0xFFC4A38B);

  static const premiumMint = Color(0xFFCFE2DB);
  static const premiumDarkA = Color(0xFF20423C);
  static const premiumDarkB = Color(0xFF16201E);
  static const premiumDarkC = Color(0xFF101817);

  static const danger = Color(0xFF8C4A45);

  static const appBg = Color(0xFFEAF0F4);
  static const card = Color(0xFFFFFFFF);

  static const skyTop = Color(0xFFD7E9F4);
  static const skyMid = Color(0xFFB7D4E6);
  static const skyBottom = Color(0xFF98BFD6);

  static const loginTop = Color(0xFFDCECF5);
  static const loginMid = Color(0xFFC3DCEA);
  static const loginBottom = Color(0xFFA6CAD9);

  static const sessionDarkA = Color(0xFF22423A);
  static const sessionDarkB = Color(0xFF16201E);
  static const sessionDarkC = Color(0xFF0E1615);
}

const Map<Mood, Color> moodColors = {
  Mood.binhYen: AppColors.sage,
  Mood.vui: AppColors.rose,
  Mood.binhThuong: Color(0x401B2420),
  Mood.loLang: AppColors.lavender,
  Mood.buon: AppColors.blueGray,
  Mood.kietSuc: AppColors.tan,
};

const Map<Mood, String> moodLabels = {
  Mood.binhYen: 'Bình yên',
  Mood.vui: 'Vui',
  Mood.binhThuong: 'Bình thường',
  Mood.loLang: 'Lo lắng',
  Mood.buon: 'Buồn',
  Mood.kietSuc: 'Kiệt sức',
};
