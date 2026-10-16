import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/theme_controller_v2.dart';

/// Bảng màu của một chế độ (tối / sáng) cho giao diện v2.
class PaletteV2 {
  final Brightness brightness;
  final Color bgDeep;
  final Color bgTop;
  final Color surface;
  final Color surfaceStrong;
  final Color border;
  final Color navBar;
  final Color fg;
  final Color fgMuted;
  final Color fgSoft;
  final Color accent;
  final Color accent2;
  final Color glow;
  final Color success;
  final Color warn;
  final Color danger;
  final double ambientOpacity;

  const PaletteV2({
    required this.brightness,
    required this.bgDeep,
    required this.bgTop,
    required this.surface,
    required this.surfaceStrong,
    required this.border,
    required this.navBar,
    required this.fg,
    required this.fgMuted,
    required this.fgSoft,
    required this.accent,
    required this.accent2,
    required this.glow,
    required this.success,
    required this.warn,
    required this.danger,
    required this.ambientOpacity,
  });

  // Nền tối (tránh #000 thuần để đỡ lem OLED)
  static const dark = PaletteV2(
    brightness: Brightness.dark,
    bgDeep: Color(0xFF020203),
    bgTop: Color(0xFF0D0D14),
    surface: Color(0x0DFFFFFF), // rgba(255,255,255,.05)
    surfaceStrong: Color(0x17FFFFFF), // ~9%
    border: Color(0x17FFFFFF), // rgba(255,255,255,.09)
    navBar: Color(0x8C14141A),
    fg: Color(0xFFEDEDEF),
    fgMuted: Color(0xFF8A8F98),
    fgSoft: Color(0xFFCDD3E0),
    accent: Color(0xFF0A84FF),
    accent2: Color(0xFF5E6AD2),
    glow: Color(0x590A84FF), // rgba(10,132,255,.35)
    success: Color(0xFF30D158),
    warn: Color(0xFFFFD60A),
    danger: Color(0xFFFF453A),
    ambientOpacity: 1,
  );

  static const light = PaletteV2(
    brightness: Brightness.light,
    bgDeep: Color(0xFFF2F3F7),
    bgTop: Color(0xFFFFFFFF),
    surface: Color(0x99FFFFFF), // ~60%
    surfaceStrong: Color(0xCCFFFFFF), // ~80%
    border: Color(0x14000000), // rgba(0,0,0,.08)
    navBar: Color(0xD9FFFFFF),
    fg: Color(0xFF111318),
    fgMuted: Color(0xFF6B7280),
    fgSoft: Color(0xFF3C4250),
    accent: Color(0xFF007AFF),
    accent2: Color(0xFF5E6AD2),
    glow: Color(0x33007AFF),
    success: Color(0xFF248A3D), // xanh đậm hơn để đọc rõ trên nền trắng
    warn: Color(0xFFC77700),
    danger: Color(0xFFFF3B30),
    ambientOpacity: 0.45,
  );
}

/// Design tokens cho giao diện v2. Widget v2 CHỈ lấy màu/kích thước từ đây.
///
/// Màu là getter đọc theo chế độ hiện tại ([ThemeControllerV2]); khi đổi chế độ,
/// controller sẽ ép toàn bộ cây widget build lại nên không cần truyền context.
/// Vì vậy KHÔNG dùng màu token trong biểu thức `const`.
class AppTokensV2 {
  AppTokensV2._();

  static PaletteV2 get _p => ThemeControllerV2.instance.palette;

  static Brightness get brightness => _p.brightness;
  static bool get isDark => _p.brightness == Brightness.dark;

  // Nền
  static Color get bgDeep => _p.bgDeep;
  static Color get bgTop => _p.bgTop;
  static Color get surface => _p.surface;

  /// Nền thẻ khi KHÔNG dùng BackdropFilter (đục hơn chút để vẫn đọc rõ).
  static Color get surfaceStrong => _p.surfaceStrong;
  static Color get border => _p.border;
  static Color get navBar => _p.navBar;

  // Chữ
  static Color get fg => _p.fg;
  static Color get fgMuted => _p.fgMuted;
  static Color get fgSoft => _p.fgSoft;

  // Accent
  static Color get accent => _p.accent;
  static Color get accent2 => _p.accent2;
  static Color get glow => _p.glow;
  static Color get success => _p.success;
  static Color get warn => _p.warn;
  static Color get danger => _p.danger;

  /// Hệ số độ đậm quầng sáng nền (nền sáng cần nhạt hơn).
  static double get ambientOpacity => _p.ambientOpacity;

  static const double radius = 20;
  static const double radiusSm = 14;
  static const double gap = 16;

  static const Duration dFast = Duration(milliseconds: 180);
  static const Duration dBase = Duration(milliseconds: 420);
  static const Duration dSlow = Duration(milliseconds: 700);

  // Apple-like ease-out (Expo.out ~ cubic-bezier(.16,1,.3,1))
  static const Curve easeExpo = Cubic(0.16, 1, 0.3, 1);

  static LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, accent2],
      );

  static LinearGradient get screenGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgTop, bgDeep],
        stops: const [0.0, 0.55],
      );

  static TextStyle get title => TextStyle(
      color: fg, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3);
  static TextStyle get section =>
      TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w800);
  static TextStyle get body =>
      TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600);
  static TextStyle get caption =>
      TextStyle(color: fgMuted, fontSize: 11.5, fontWeight: FontWeight.w500);

  /// Chữ phụ trên nền kính — đậm/sáng hơn [caption] để dễ đọc.
  static TextStyle get captionStrong =>
      TextStyle(color: fgSoft, fontSize: 11.5, fontWeight: FontWeight.w600);
  static TextStyle get number => TextStyle(
      color: fg,
      fontSize: 23,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      fontFeatures: const [FontFeature.tabularFigures()]);
}
