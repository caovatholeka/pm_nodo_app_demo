import 'package:flutter/material.dart';

/// Design tokens cho giao diện v2 (dark premium). Widget v2 CHỈ lấy màu/kích thước từ đây.
class AppTokensV2 {
  AppTokensV2._();

  // Nền (tránh #000 thuần để đỡ lem OLED)
  static const Color bgDeep = Color(0xFF020203);
  static const Color bgTop = Color(0xFF0D0D14);
  static const Color surface = Color(0x0DFFFFFF); // rgba(255,255,255,.05)
  static const Color border = Color(0x17FFFFFF);  // rgba(255,255,255,.09)

  // Chữ
  static const Color fg = Color(0xFFEDEDEF);
  static const Color fgMuted = Color(0xFF8A8F98);
  static const Color fgSoft = Color(0xFFCDD3E0);

  // Accent
  static const Color accent = Color(0xFF0A84FF);
  static const Color accent2 = Color(0xFF5E6AD2);
  static const Color glow = Color(0x590A84FF); // rgba(10,132,255,.35)
  static const Color success = Color(0xFF30D158);
  static const Color warn = Color(0xFFFFD60A);

  static const double radius = 20;
  static const double radiusSm = 14;
  static const double gap = 16;

  static const Duration dFast = Duration(milliseconds: 180);
  static const Duration dBase = Duration(milliseconds: 420);
  static const Duration dSlow = Duration(milliseconds: 700);

  // Apple-like ease-out (Expo.out ~ cubic-bezier(.16,1,.3,1))
  static const Curve easeExpo = Cubic(0.16, 1, 0.3, 1);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );

  static const LinearGradient screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgDeep],
    stops: [0.0, 0.55],
  );

  static const TextStyle title =
      TextStyle(color: fg, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3);
  static const TextStyle section =
      TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w800);
  static const TextStyle body =
      TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600);
  static const TextStyle caption =
      TextStyle(color: fgMuted, fontSize: 11.5, fontWeight: FontWeight.w500);
  static const TextStyle number = TextStyle(
      color: fg, fontSize: 23, fontWeight: FontWeight.w800,
      letterSpacing: -0.5, fontFeatures: [FontFeature.tabularFigures()]);
}
