# Dark Premium UI — Phase 1 (Home v2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bật một giao diện "dark premium" mới cho riêng tài khoản test (`anhpt@nodo.vn`) — bắt đầu bằng màn Home v2 + shell điều hướng v2 — mà không đụng tới UI production hiện tại.

**Architecture:** Xây một lớp UI v2 tách biệt (`core/theme_v2/` + `features/ui_v2/`). Tại `BottomNavigation.build`, nếu tài khoản là beta thì trả về shell v2; ngược lại giữ nguyên UI cũ. Home v2 **tái dùng `HomeCubit`/`HomeState`** hiện có, chỉ thay cách trình bày.

**Tech Stack:** Flutter, flutter_bloc (Cubit), GetIt DI, animation built-in (`AnimationController`, `TweenAnimationBuilder`, `AnimatedBuilder`, `BackdropFilter`), `HapticFeedback`. KHÔNG thêm package mới.

## Global Constraints

- Không sửa/đập bỏ bất kỳ màn cũ nào; chỉ thêm file mới, trừ 1 điểm rẽ nhánh 3 dòng trong `lib/app/features/navigation/bottom_navigation.dart`.
- Gate đọc email từ `GlobalData.instance.userProfile?.email`; danh sách beta hardcode `{'anhpt@nodo.vn'}` (so khớp lowercase/trim).
- Chỉ dark mode. Tránh nền `#000000` thuần (dùng `#020203`/`#0d0d14`).
- Tôn trọng reduce-motion: `MediaQuery.of(context).disableAnimations` → tắt vòng lặp blob & rút entrance về tức thời.
- Tất cả token màu/không-gian/bo góc lấy từ `AppTokensV2` (không hardcode hex trong widget v2).
- Không commit lên nhánh chung khi chưa được yêu cầu; commit local theo từng task.

---

### Task 1: Gate beta theo tài khoản (AppFlags)

**Files:**
- Create: `lib/app/core/commons/app_flags.dart`
- Test: `test/app_flags_test.dart`

**Interfaces:**
- Produces: `AppFlags.isBetaUiEmail(String? email) -> bool`, `AppFlags.betaUiEmails -> Set<String>`, `AppFlags.isBetaUiActive() -> bool` (đọc `GlobalData.instance.userProfile?.email`).

- [ ] **Step 1: Viết test thất bại** — `test/app_flags_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/core/commons/app_flags.dart';

void main() {
  group('AppFlags.isBetaUiEmail', () {
    test('trả true cho email beta (không phân biệt hoa/thường, có khoảng trắng)', () {
      expect(AppFlags.isBetaUiEmail('anhpt@nodo.vn'), isTrue);
      expect(AppFlags.isBetaUiEmail('  ANHPT@Nodo.VN '), isTrue);
    });
    test('trả false cho email khác hoặc null', () {
      expect(AppFlags.isBetaUiEmail('someone@nodo.vn'), isFalse);
      expect(AppFlags.isBetaUiEmail(null), isFalse);
      expect(AppFlags.isBetaUiEmail(''), isFalse);
    });
  });
}
```

- [ ] **Step 2: Chạy test để chắc nó fail**

Run: `flutter test test/app_flags_test.dart`
Expected: FAIL — `Target of URI doesn't exist: app_flags.dart` / không tìm thấy `AppFlags`.

- [ ] **Step 3: Viết implementation tối thiểu** — `lib/app/core/commons/app_flags.dart`

```dart
import 'global_data.dart';

/// Cờ bật tính năng theo tài khoản. TẠM cho giai đoạn thử nghiệm UI mới.
class AppFlags {
  AppFlags._();

  /// Danh sách email được thấy giao diện mới (dark premium).
  static const Set<String> betaUiEmails = {
    'anhpt@nodo.vn',
  };

  static bool isBetaUiEmail(String? email) {
    if (email == null) return false;
    return betaUiEmails.contains(email.trim().toLowerCase());
  }

  /// Tài khoản đang đăng nhập có bật UI mới không.
  static bool isBetaUiActive() =>
      isBetaUiEmail(GlobalData.instance.userProfile?.email);
}
```

- [ ] **Step 4: Chạy test để chắc pass**

Run: `flutter test test/app_flags_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/commons/app_flags.dart test/app_flags_test.dart
git commit -m "feat(v2): AppFlags gate UI beta theo email"
```

---

### Task 2: Design tokens v2

**Files:**
- Create: `lib/app/core/theme_v2/app_tokens_v2.dart`

**Interfaces:**
- Produces: class `AppTokensV2` với các hằng: màu `bgDeep, bgTop, surface, border, fg, fgMuted, accent, accent2, glow, success, warn`; số `radius=20, radiusSm=14, gap=16`; `Duration dFast, dBase, dSlow`; `Curve easeExpo`; `Gradient accentGradient`; helper `TextStyle title/body/caption/number`.

- [ ] **Step 1: Tạo file tokens** — `lib/app/core/theme_v2/app_tokens_v2.dart`

```dart
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
```

- [ ] **Step 2: Verify biên dịch**

Run: `flutter analyze lib/app/core/theme_v2/app_tokens_v2.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/core/theme_v2/app_tokens_v2.dart
git commit -m "feat(v2): design tokens dark premium"
```

---

### Task 3: Component v2 — GlassCard + PrimaryButton (spring + haptic)

**Files:**
- Create: `lib/app/core/theme_v2/widgets/glass_card_v2.dart`
- Create: `lib/app/core/theme_v2/widgets/primary_button_v2.dart`

**Interfaces:**
- Consumes: `AppTokensV2` (Task 2).
- Produces: `GlassCardV2({required Widget child, EdgeInsets? padding, double? radius, Gradient? gradient})`; `PrimaryButtonV2({required String label, required VoidCallback onTap})`.

- [ ] **Step 1: GlassCardV2** — `lib/app/core/theme_v2/widgets/glass_card_v2.dart`

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_tokens_v2.dart';

/// Thẻ kính mờ (frosted glass) với viền hairline. Nếu có [gradient] thì dùng làm nền đặc.
class GlassCardV2 extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;

  const GlassCardV2({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = AppTokensV2.radius,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppTokensV2.surface : null,
        borderRadius: r,
        border: Border.all(color: AppTokensV2.border, width: 1),
        boxShadow: gradient != null
            ? [BoxShadow(color: AppTokensV2.glow, blurRadius: 26, offset: const Offset(0, 12))]
            : null,
      ),
      child: child,
    );
    if (gradient != null) {
      return ClipRRect(borderRadius: r, child: content);
    }
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: content,
      ),
    );
  }
}
```

- [ ] **Step 2: PrimaryButtonV2** — `lib/app/core/theme_v2/widgets/primary_button_v2.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_tokens_v2.dart';

/// Nút chính: nền gradient accent, lún nhẹ (spring 0.965) + haptic khi bấm.
class PrimaryButtonV2 extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const PrimaryButtonV2({super.key, required this.label, required this.onTap});

  @override
  State<PrimaryButtonV2> createState() => _PrimaryButtonV2State();
}

class _PrimaryButtonV2State extends State<PrimaryButtonV2> {
  bool _down = false;
  void _set(bool v) => setState(() => _down = v);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { _set(true); HapticFeedback.lightImpact(); },
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.965 : 1.0,
        duration: AppTokensV2.dFast,
        curve: AppTokensV2.easeExpo,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: AppTokensV2.accentGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: AppTokensV2.glow, blurRadius: 26, offset: const Offset(0, 10))],
          ),
          child: Text(widget.label, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Verify biên dịch**

Run: `flutter analyze lib/app/core/theme_v2/widgets`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/theme_v2/widgets/glass_card_v2.dart lib/app/core/theme_v2/widgets/primary_button_v2.dart
git commit -m "feat(v2): GlassCard + PrimaryButton (spring+haptic)"
```

---

### Task 4: Component v2 — AmbientBackground + StaggerReveal

**Files:**
- Create: `lib/app/core/theme_v2/widgets/ambient_background_v2.dart`
- Create: `lib/app/core/theme_v2/widgets/stagger_reveal_v2.dart`

**Interfaces:**
- Consumes: `AppTokensV2`.
- Produces: `AmbientBackgroundV2({required Widget child})` (nền gradient + blob trôi); `StaggerRevealV2({required int index, required Widget child})` (trượt lên + mờ, delay theo index).

- [ ] **Step 1: AmbientBackgroundV2** — `lib/app/core/theme_v2/widgets/ambient_background_v2.dart`

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_tokens_v2.dart';

/// Nền dark premium: gradient + 2 blob ánh sáng trôi chậm. Tự tắt khi reduce-motion.
class AmbientBackgroundV2 extends StatefulWidget {
  final Widget child;
  const AmbientBackgroundV2({super.key, required this.child});
  @override
  State<AmbientBackgroundV2> createState() => _AmbientBackgroundV2State();
}

class _AmbientBackgroundV2State extends State<AmbientBackgroundV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat(reverse: true);

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  Widget _blob(double size, Color color, double dx, double dy) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 46, sigmaY: 46),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.45), shape: BoxShape.circle),
        transform: Matrix4.translationValues(dx, dy, 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return Container(
      decoration: const BoxDecoration(gradient: AppTokensV2.screenGradient),
      child: Stack(children: [
        Positioned(
          top: -40, left: -50,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, child) {
              final t = reduce ? 0.0 : _c.value;
              return Transform.translate(offset: Offset(24 * t, 30 * t), child: child);
            },
            child: _blob(220, AppTokensV2.accent, 0, 0),
          ),
        ),
        Positioned(
          top: 120, right: -70,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, child) {
              final t = reduce ? 0.0 : _c.value;
              return Transform.translate(offset: Offset(-28 * t, 24 * t), child: child);
            },
            child: _blob(200, AppTokensV2.accent2, 0, 0),
          ),
        ),
        widget.child,
      ]),
    );
  }
}
```

- [ ] **Step 2: StaggerRevealV2** — `lib/app/core/theme_v2/widgets/stagger_reveal_v2.dart`

```dart
import 'package:flutter/material.dart';
import '../app_tokens_v2.dart';

/// Hiệu ứng vào màn: trượt lên (22->0) + mờ dần, delay theo [index]. Tôn trọng reduce-motion.
class StaggerRevealV2 extends StatefulWidget {
  final int index;
  final Widget child;
  const StaggerRevealV2({super.key, required this.index, required this.child});
  @override
  State<StaggerRevealV2> createState() => _StaggerRevealV2State();
}

class _StaggerRevealV2State extends State<StaggerRevealV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: AppTokensV2.dSlow);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50 + widget.index * 85), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    final anim = CurvedAnimation(parent: _c, curve: AppTokensV2.easeExpo);
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(offset: Offset(0, 22 * (1 - anim.value)), child: child),
      ),
      child: widget.child,
    );
  }
}
```

- [ ] **Step 3: Verify biên dịch**

Run: `flutter analyze lib/app/core/theme_v2/widgets`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/theme_v2/widgets/ambient_background_v2.dart lib/app/core/theme_v2/widgets/stagger_reveal_v2.dart
git commit -m "feat(v2): AmbientBackground + StaggerReveal (reduce-motion aware)"
```

---

### Task 5: Home v2 page (tái dùng HomeCubit)

**Files:**
- Create: `lib/app/features/ui_v2/home/home_page_v2.dart`
- Reference (đọc, không sửa): `lib/app/features/ui/home/home_cubit.dart`, `home_state.dart`, `lib/app/core/commons/global_data.dart`

**Interfaces:**
- Consumes: `AppTokensV2`, `GlassCardV2`, `PrimaryButtonV2`, `AmbientBackgroundV2`, `StaggerRevealV2`; `HomeCubit`/`HomeState` (đọc `checkInToday`, `checkOutToday`, `listNewTasks`); `GlobalData.instance.userProfile` (name).
- Produces: `HomePageV2` (StatelessWidget) — dùng trong shell v2 (Task 6).

- [ ] **Step 1: Tạo Home v2** — `lib/app/features/ui_v2/home/home_page_v2.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/ui/home/home_cubit.dart';

class HomePageV2 extends StatefulWidget {
  const HomePageV2({super.key});
  @override
  State<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2> {
  final HomeCubit _cubit = GetIt.I.get<HomeCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getListAttendanceToday();
  }

  String get _name => GlobalData.instance.userProfile?.name ?? '';
  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTokensV2.bgDeep,
        body: AmbientBackgroundV2(
          child: SafeArea(
            bottom: false,
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                  children: [
                    StaggerRevealV2(index: 0, child: _header()),
                    const SizedBox(height: 16),
                    StaggerRevealV2(index: 1, child: _hero(state)),
                    const SizedBox(height: 22),
                    StaggerRevealV2(index: 2, child: _utilities()),
                    const SizedBox(height: 22),
                    StaggerRevealV2(index: 3, child: _tasks(state)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          gradient: AppTokensV2.accentGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppTokensV2.glow, blurRadius: 18, offset: const Offset(0, 6))],
        ),
        alignment: Alignment.center,
        child: Text(_initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Xin chào, $_name', style: AppTokensV2.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 1),
        const Text('Cố gắng hết mình hôm nay nhé!', style: AppTokensV2.caption),
      ])),
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: AppTokensV2.border),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.notifications_none_rounded, color: AppTokensV2.fg, size: 20),
      ),
    ]);
  }

  Widget _hero(HomeState state) {
    final checkIn = (state.checkInToday?.isNotEmpty ?? false) ? state.checkInToday! : '--:--';
    final checkOut = (state.checkOutToday?.isNotEmpty ?? false) ? state.checkOutToday! : '--:--';
    final checkedIn = checkIn != '--:--';
    return GlassCardV2(
      gradient: AppTokensV2.accentGradient,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Hôm nay', style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _timeCol('Chấm Công Vào', checkIn, checkedIn ? 'Đã chấm' : 'Chưa chấm', checkedIn)),
          Container(width: 1, height: 40, color: Colors.white24),
          const SizedBox(width: 12),
          Expanded(child: _timeCol('Chấm Công Ra', checkOut, checkOut != '--:--' ? 'Đã chấm' : 'Chưa chấm', checkOut != '--:--')),
        ]),
        const SizedBox(height: 15),
        PrimaryButtonV2(
          label: checkedIn ? 'Chấm công ra' : 'Chấm công vào',
          onTap: () => GlobalData.instance.bottomNavIndex.value = 2, // tab Chấm công
        ),
      ]),
    );
  }

  Widget _timeCol(String label, String time, String status, bool ok) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
      Text(time, style: AppTokensV2.number.copyWith(color: Colors.white)),
      Row(children: [
        Icon(ok ? Icons.check_circle : Icons.schedule, size: 12,
            color: ok ? AppTokensV2.success : Colors.white54),
        const SizedBox(width: 4),
        Text(status, style: TextStyle(color: ok ? AppTokensV2.success : Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
      ]),
    ]);
  }

  Widget _utilities() {
    final items = <(IconData, String, int)>[
      (Icons.people_alt_outlined, 'Nhân viên', 1),
      (Icons.description_outlined, 'Dữ liệu công', 3),
      (Icons.event_available_outlined, 'Nghỉ phép', 3),
      (Icons.fingerprint, 'Chấm công', 2),
      (Icons.checklist_rounded, 'Việc cần làm', 0),
      (Icons.assignment_outlined, 'Đơn từ', 3),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Tiện ích', style: AppTokensV2.section),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 3, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14, crossAxisSpacing: 10, childAspectRatio: 0.92,
        children: [for (final it in items) _utilTile(it.$1, it.$2, it.$3)],
      ),
    ]);
  }

  Widget _utilTile(IconData icon, String label, int navIndex) {
    return GestureDetector(
      onTap: () => GlobalData.instance.bottomNavIndex.value = navIndex,
      child: Column(children: [
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            color: AppTokensV2.surface,
            border: Border.all(color: AppTokensV2.border),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(icon, color: AppTokensV2.accent, size: 24),
        ),
        const SizedBox(height: 7),
        Text(label, style: AppTokensV2.caption.copyWith(color: const Color(0xFFCDD3E0)),
            textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _tasks(HomeState state) {
    final tasks = state.listNewTasks ?? const [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
        Text('Việc cần làm', style: AppTokensV2.section),
        Text('Xem tất cả', style: TextStyle(color: AppTokensV2.accent, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 12),
      if (tasks.isEmpty)
        GlassCardV2(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text('Không có việc cần làm', style: AppTokensV2.caption)),
        )
      else
        for (final t in tasks.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: GlassCardV2(
              padding: const EdgeInsets.all(13),
              child: Row(children: [
                Container(width: 9, height: 9,
                    decoration: const BoxDecoration(color: AppTokensV2.accent, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(child: Text(t.name ?? '—', style: AppTokensV2.body, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ),
          ),
    ]);
  }
}
```

- [ ] **Step 2: Xác nhận tên field/getter khớp code thật**

Run: `grep -nE "checkInToday|checkOutToday|listNewTasks|getListAttendanceToday" lib/app/features/ui/home/home_state.dart lib/app/features/ui/home/home_cubit.dart`
Expected: các tên này tồn tại. Nếu `TaskEntity` không có `.name`, xem field đúng bằng `grep -nE "String\?|final" lib/app/data/models/entities/task_entity.dart` và sửa `t.name` cho khớp.

- [ ] **Step 3: Verify biên dịch**

Run: `flutter analyze lib/app/features/ui_v2/home/home_page_v2.dart`
Expected: `No issues found!` (chỉ chấp nhận cảnh báo info không liên quan).

- [ ] **Step 4: Commit**

```bash
git add lib/app/features/ui_v2/home/home_page_v2.dart
git commit -m "feat(v2): Home page v2 (tái dùng HomeCubit, nội dung giữ nguyên)"
```

---

### Task 6: Shell điều hướng v2 + rẽ nhánh theo gate

**Files:**
- Create: `lib/app/features/ui_v2/navigation/bottom_navigation_v2.dart`
- Modify: `lib/app/features/navigation/bottom_navigation.dart` (thêm rẽ nhánh ở đầu `build`)

**Interfaces:**
- Consumes: `AppFlags` (Task 1), `HomePageV2` (Task 5), `AppTokensV2`; tái dùng `StaffPage, CheckInPage, OnLeavePage, AccountPage`; `GlobalData.instance.bottomNavIndex`.
- Produces: `BottomNavigationV2` (shell 5 tab, glass bottom bar).

- [ ] **Step 1: Shell v2** — `lib/app/features/ui_v2/navigation/bottom_navigation_v2.dart`

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/features/ui/account/account_page.dart';
import 'package:pm_app/app/features/ui/checkin/check_in_page.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_page.dart';
import 'package:pm_app/app/features/ui_v2/home/home_page_v2.dart';

class BottomNavigationV2 extends StatelessWidget {
  const BottomNavigationV2({super.key});

  static const _pages = <Widget>[
    HomePageV2(), StaffPage(), CheckInPage(), OnLeavePage(), AccountPage(),
  ];
  static const _icons = <IconData>[
    Icons.home_rounded, Icons.people_alt_rounded, Icons.fingerprint,
    Icons.event_available_rounded, Icons.person_rounded,
  ];
  static const _labels = <String>['Trang chủ', 'Nhân viên', 'Chấm công', 'Nghỉ phép', 'Cá nhân'];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: GlobalData.instance.bottomNavIndex,
      builder: (_, index, __) {
        final safeIndex = (index >= 0 && index < _pages.length) ? index : 0;
        return Scaffold(
          backgroundColor: AppTokensV2.bgDeep,
          extendBody: true,
          body: _pages[safeIndex],
          bottomNavigationBar: _GlassBar(current: safeIndex, icons: _icons, labels: _labels),
        );
      },
    );
  }
}

class _GlassBar extends StatelessWidget {
  final int current;
  final List<IconData> icons;
  final List<String> labels;
  const _GlassBar({required this.current, required this.icons, required this.labels});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom > 0 ? bottom : 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0x8C14141A),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTokensV2.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < icons.length; i++)
                  _BarItem(
                    icon: icons[i], label: labels[i], active: i == current,
                    onTap: () => GlobalData.instance.bottomNavIndex.value = i,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _BarItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTokensV2.accent : AppTokensV2.fgMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
```

- [ ] **Step 2: Rẽ nhánh trong nav cũ** — sửa `lib/app/features/navigation/bottom_navigation.dart`

Thêm import ở đầu file (cạnh các import hiện có):

```dart
import '../../core/commons/app_flags.dart';
import '../ui_v2/navigation/bottom_navigation_v2.dart';
```

Thêm 3 dòng đầu tiên trong `Widget build(BuildContext context) {` (ngay trước `final padding = ...`):

```dart
    if (AppFlags.isBetaUiActive()) {
      return const BottomNavigationV2();
    }
```

- [ ] **Step 3: Verify biên dịch toàn dự án**

Run: `flutter analyze lib/app/features/ui_v2 lib/app/features/navigation/bottom_navigation.dart`
Expected: `No issues found!`

- [ ] **Step 4: Chạy thử trên simulator (tài khoản beta)**

Đăng nhập bằng `thangtn@nodo.vn`/`anhpt@nodo.vn` (tài khoản có trong `betaUiEmails`) → thấy shell dark v2. Đăng nhập tài khoản khác → UI cũ nguyên vẹn.
Run: `flutter run` (hoặc build TestFlight như quy trình đã có).

- [ ] **Step 5: Commit**

```bash
git add lib/app/features/ui_v2/navigation/bottom_navigation_v2.dart lib/app/features/navigation/bottom_navigation.dart
git commit -m "feat(v2): shell điều hướng v2 + rẽ nhánh theo AppFlags"
```

---

## Self-Review

- **Spec coverage:** Gate (Task 1) ✓ · theme_v2 tokens (Task 2) ✓ · core components GlassCard/PrimaryButton/Ambient/Stagger (Task 3–4) ✓ · Home v2 nội dung giữ nguyên (Task 5) ✓ · nav 5 tab đúng thực tế + rẽ nhánh an toàn (Task 6) ✓ · animation + reduce-motion ✓ · chỉ dark ✓ · không sửa màn cũ (chỉ 3 dòng rẽ nhánh) ✓.
- **Placeholder scan:** không có TODO/“xử lý sau”; mọi step có code thật.
- **Type consistency:** `AppFlags.isBetaUiActive`, `AppTokensV2.*`, `GlassCardV2`, `PrimaryButtonV2`, `AmbientBackgroundV2`, `StaggerRevealV2`, `HomePageV2`, `BottomNavigationV2` dùng nhất quán giữa các task.
- **Điểm cần xác minh khi code (đã ghi trong Task 5 Step 2):** tên field `TaskEntity` (dùng cho `t.name`) và các getter `checkInToday/checkOutToday/listNewTasks` — kiểm bằng grep trước khi implement, sửa cho khớp nếu khác.

## Rủi ro / lưu ý

- `HomeCubit` được lấy qua `GetIt.I.get<HomeCubit>()` — xác nhận nó đã register (dùng chung với HomePage cũ). Nếu là factory tạo instance mới, cân nhắc lấy cùng instance để tránh gọi API 2 lần.
- Các tab Nhân viên/Nghỉ phép/Cá nhân/Chấm công vẫn là màn cũ (sáng) trong Phase 1 — sẽ chỏi tông với shell tối; Phase 2–3 sẽ làm v2 cho chúng. Chấp nhận tạm trong giai đoạn thử nghiệm.
