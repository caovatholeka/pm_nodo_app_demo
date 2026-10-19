import 'package:flutter/material.dart';
import '../app_tokens_v2.dart';

/// Nền dark premium: gradient + vài quầng sáng trôi rất chậm.
///
/// HIỆU NĂNG: trước đây dùng `ImageFiltered(ImageFilter.blur(46))` cho từng quầng
/// và animate chúng — nghĩa là GPU phải blur lại mỗi frame ở 60fps, làm máy nóng.
/// Nay quầng sáng vẽ bằng [RadialGradient] (gần như miễn phí, không cần blur filter),
/// và toàn bộ lớp nền được bọc [RepaintBoundary] để không kéo theo cây widget phía trên
/// vẽ lại. Tự đứng yên khi bật giảm chuyển động.
class AmbientBackgroundV2 extends StatefulWidget {
  final Widget child;
  const AmbientBackgroundV2({super.key, required this.child});
  @override
  State<AmbientBackgroundV2> createState() => _AmbientBackgroundV2State();
}

class _AmbientBackgroundV2State extends State<AmbientBackgroundV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  );

  bool _running = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Giá trị đã làm mượt (ease-in-out) để chuyển động "thở" nhẹ nhàng.
  double get _cv => Curves.easeInOutSine.transform(_c.value);

  /// Quầng sáng: RadialGradient mờ dần ra biên — thay cho blur filter.
  Widget _glow(double size, Color color, double opacity) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.45),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _drift({
    required Widget child,
    required Offset amount,
    required double scaleAmount,
    required bool reduce,
  }) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, c) {
        final t = reduce ? 0.0 : _cv;
        return Transform.translate(
          offset: Offset(amount.dx * t, amount.dy * t),
          child: Transform.scale(scale: 1 + scaleAmount * t, child: c),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    // Chỉ chạy vòng lặp khi thực sự cần (tránh đốt pin khi giảm chuyển động).
    if (!reduce && !_running) {
      _running = true;
      _c.repeat(reverse: true);
    } else if (reduce && _running) {
      _running = false;
      _c.stop();
    }

    return Container(
      decoration: BoxDecoration(gradient: AppTokensV2.screenGradient),
      child: Stack(children: [
        // Lớp quầng sáng tách riêng: animate ở đây không làm nội dung vẽ lại.
        RepaintBoundary(
          child: Stack(children: [
            Positioned(
              top: -90,
              left: -110,
              child: _drift(
                amount: const Offset(38, 46),
                scaleAmount: 0.10,
                reduce: reduce,
                child: _glow(360, AppTokensV2.accent, 0.30 * AppTokensV2.ambientOpacity),
              ),
            ),
            Positioned(
              top: 90,
              right: -140,
              child: _drift(
                amount: const Offset(-44, 38),
                scaleAmount: 0.12,
                reduce: reduce,
                child: _glow(340, AppTokensV2.accent2, 0.26 * AppTokensV2.ambientOpacity),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: _drift(
                amount: const Offset(30, -40),
                scaleAmount: 0.10,
                reduce: reduce,
                child: _glow(320, AppTokensV2.accent, 0.20 * AppTokensV2.ambientOpacity),
              ),
            ),
          ]),
        ),
        widget.child,
      ]),
    );
  }
}
