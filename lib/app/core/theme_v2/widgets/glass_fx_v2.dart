import 'package:flutter/material.dart';
import '../app_tokens_v2.dart';

/// Dải sáng quét ngang liên tục (đặt trong ClipRRect của thẻ). Tự tắt khi reduce-motion.
class ShimmerSweepV2 extends StatefulWidget {
  const ShimmerSweepV2({super.key});
  @override
  State<ShimmerSweepV2> createState() => _ShimmerSweepV2State();
}

class _ShimmerSweepV2State extends State<ShimmerSweepV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4500),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (_, c) {
          final w = c.maxWidth;
          final bandW = w * 0.42;
          return AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              // -0.6 -> 1.15 (nghỉ một nhịp cuối chu kỳ)
              final p = (_c.value / 0.7).clamp(0.0, 1.0);
              final dx = (-0.6 + 1.75 * p) * w;
              return Stack(children: [
                Positioned(
                  left: dx,
                  top: 0,
                  bottom: 0,
                  width: bandW,
                  child: Transform(
                    transform: Matrix4.skewX(-0.35),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0x1FFFFFFF), // white ~12%
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]);
            },
          );
        },
      ),
    );
  }
}

/// Chấm tròn "live" nhấp nháy (scale + mờ). Tự đứng yên khi reduce-motion.
class PulseDotV2 extends StatefulWidget {
  final Color color;
  final double size;
  const PulseDotV2({super.key, required this.color, this.size = 8});
  @override
  State<PulseDotV2> createState() => _PulseDotV2State();
}

class _PulseDotV2State extends State<PulseDotV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.9),
            blurRadius: 8,
          ),
        ],
      ),
    );
    if (MediaQuery.of(context).disableAnimations) return dot;
    final anim = CurvedAnimation(parent: _c, curve: AppTokensV2.easeExpo);
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: 0.5 + 0.5 * anim.value,
        child: Transform.scale(scale: 0.85 + 0.35 * anim.value, child: child),
      ),
      child: dot,
    );
  }
}
