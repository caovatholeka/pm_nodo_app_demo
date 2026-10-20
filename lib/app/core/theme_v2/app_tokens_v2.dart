import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/theme_controller_v2.dart';

/// Bảng màu cho giao diện v2.
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

  static const dark = PaletteV2(
    brightness: Brightness.dark,
    bgDeep: Color(0xFF020203),
    bgTop: Color(0xFF0D0D14),
    surface: Color(0x0DFFFFFF),
    surfaceStrong: Color(0x17FFFFFF),
    border: Color(0x17FFFFFF),
    navBar: Color(0x8C14141A),
    fg: Color(0xFFEDEDEF),
    fgMuted: Color(0xFF8A8F98),
    fgSoft: Color(0xFFCDD3E0),
    accent: Color(0xFF0A84FF),
    accent2: Color(0xFF5E6AD2),
    glow: Color(0x590A84FF),
    success: Color(0xFF30D158),
    warn: Color(0xFFFFD60A),
    danger: Color(0xFFFF453A),
    ambientOpacity: 1,
  );

  static const light = PaletteV2(
    brightness: Brightness.light,
    bgDeep: Color(0xFFF2F3F7),
    bgTop: Color(0xFFFFFFFF),
    surface: Color(0x99FFFFFF),
    surfaceStrong: Color(0xCCFFFFFF),
    border: Color(0x14000000),
    navBar: Color(0xD9FFFFFF),
    fg: Color(0xFF111318),
    fgMuted: Color(0xFF6B7280),
    fgSoft: Color(0xFF3C4250),
    accent: Color(0xFF007AFF),
    accent2: Color(0xFF5E6AD2),
    glow: Color(0x33007AFF),
    success: Color(0xFF248A3D),
    warn: Color(0xFFC77700),
    danger: Color(0xFFFF3B30),
    ambientOpacity: 0.45,
  );
}

/// Màu động tương thích `const`: có thể dùng trong mọi biểu thức `const`
/// (như const TextStyle, const BoxDecoration) nhưng giá trị runtime sẽ phản
/// ánh theo chế độ Sáng/Tối của [ThemeControllerV2].
class DynamicTokenColor extends Color {
  final int Function() _getter;
  const DynamicTokenColor(this._getter) : super(0xFF000000);

  @override
  int get value => _getter();
}

int _getBgDeep() => ThemeControllerV2.instance.palette.bgDeep.value;
int _getBgTop() => ThemeControllerV2.instance.palette.bgTop.value;
int _getSurface() => ThemeControllerV2.instance.palette.surface.value;
int _getSurfaceStrong() => ThemeControllerV2.instance.palette.surfaceStrong.value;
int _getBorder() => ThemeControllerV2.instance.palette.border.value;
int _getNavBar() => ThemeControllerV2.instance.palette.navBar.value;
int _getFg() => ThemeControllerV2.instance.palette.fg.value;
int _getFgMuted() => ThemeControllerV2.instance.palette.fgMuted.value;
int _getFgSoft() => ThemeControllerV2.instance.palette.fgSoft.value;
int _getAccent() => ThemeControllerV2.instance.palette.accent.value;
int _getAccent2() => ThemeControllerV2.instance.palette.accent2.value;
int _getGlow() => ThemeControllerV2.instance.palette.glow.value;
int _getSuccess() => ThemeControllerV2.instance.palette.success.value;
int _getWarn() => ThemeControllerV2.instance.palette.warn.value;
int _getDanger() => ThemeControllerV2.instance.palette.danger.value;

/// Design tokens cho giao diện v2. Widget v2 CHỈ lấy màu/kích thước từ đây.
class AppTokensV2 {
  AppTokensV2._();

  static PaletteV2 get _p => ThemeControllerV2.instance.palette;

  static Brightness get brightness => _p.brightness;
  static bool get isDark => _p.brightness == Brightness.dark;

  // Nền
  static const Color bgDeep = DynamicTokenColor(_getBgDeep);
  static const Color bgTop = DynamicTokenColor(_getBgTop);
  static const Color surface = DynamicTokenColor(_getSurface);
  static const Color surfaceStrong = DynamicTokenColor(_getSurfaceStrong);
  static const Color border = DynamicTokenColor(_getBorder);
  static const Color navBar = DynamicTokenColor(_getNavBar);

  // Chữ
  static const Color fg = DynamicTokenColor(_getFg);
  static const Color fgMuted = DynamicTokenColor(_getFgMuted);
  static const Color fgSoft = DynamicTokenColor(_getFgSoft);

  // Accent
  static const Color accent = DynamicTokenColor(_getAccent);
  static const Color accent2 = DynamicTokenColor(_getAccent2);
  static const Color glow = DynamicTokenColor(_getGlow);
  static const Color success = DynamicTokenColor(_getSuccess);
  static const Color warn = DynamicTokenColor(_getWarn);
  static const Color danger = DynamicTokenColor(_getDanger);

  /// Hệ số độ đậm quầng sáng nền.
  static double get ambientOpacity => _p.ambientOpacity;

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

  static const TextStyle title = TextStyle(
      color: fg, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3);
  static const TextStyle section =
      TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w800);
  static const TextStyle body =
      TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600);
  static const TextStyle caption =
      TextStyle(color: fgMuted, fontSize: 11.5, fontWeight: FontWeight.w500);

  /// Chữ phụ trên nền kính/tối — sáng hơn [caption] để dễ đọc.
  static const TextStyle captionStrong =
      TextStyle(color: fgSoft, fontSize: 11.5, fontWeight: FontWeight.w600);
  static const TextStyle number = TextStyle(
      color: fg,
      fontSize: 23,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      fontFeatures: [FontFeature.tabularFigures()]);
}
