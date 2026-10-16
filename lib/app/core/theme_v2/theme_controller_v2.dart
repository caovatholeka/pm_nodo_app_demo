import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lựa chọn giao diện của người dùng cho UI v2. Chỉ áp dụng cho v2, v1 giữ nguyên.
enum ThemeModeV2 { system, dark, light }

/// Giữ chế độ sáng/tối của v2, lưu vào SharedPreferences và ép rebuild khi đổi.
class ThemeControllerV2 with WidgetsBindingObserver {
  ThemeControllerV2._();
  static final ThemeControllerV2 instance = ThemeControllerV2._();

  static const _prefKey = 'v2_theme_mode';

  /// Mặc định tối — đúng như thiết kế v2 ban đầu.
  final ValueNotifier<ThemeModeV2> mode = ValueNotifier(ThemeModeV2.dark);

  bool _observing = false;

  PaletteV2 get palette {
    switch (mode.value) {
      case ThemeModeV2.dark:
        return PaletteV2.dark;
      case ThemeModeV2.light:
        return PaletteV2.light;
      case ThemeModeV2.system:
        final b = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return b == Brightness.light ? PaletteV2.light : PaletteV2.dark;
    }
  }

  /// Gọi một lần lúc khởi động (trước runApp) để không bị nháy màu.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    mode.value = ThemeModeV2.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeModeV2.dark,
    );
    if (!_observing) {
      _observing = true;
      WidgetsBinding.instance.addObserver(this);
    }
  }

  Future<void> setMode(ThemeModeV2 value) async {
    if (mode.value == value) return;
    mode.value = value;
    _rebuildAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, value.name);
  }

  @override
  void didChangePlatformBrightness() {
    if (mode.value == ThemeModeV2.system) _rebuildAll();
  }

  /// Token là getter tĩnh (không phụ thuộc InheritedWidget) nên phải đánh dấu
  /// mọi element cần build lại — kể cả widget `const` — để áp màu mới.
  void _rebuildAll() {
    void visit(Element el) {
      el.markNeedsBuild();
      el.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
  }
}
