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
        Positioned(
          bottom: 40, left: 10,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, child) {
              final t = reduce ? 0.0 : _c.value;
              return Transform.translate(offset: Offset(18 * t, -26 * t), child: child);
            },
            child: _blob(200, AppTokensV2.accent, 0, 0),
          ),
        ),
        widget.child,
      ]),
    );
  }
}
