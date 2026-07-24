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

/// Chữ hiện ra kiểu đánh máy, kèm con trỏ nhấp nháy — hợp tông "công ty công nghệ".
/// Reduce-motion: hiện thẳng toàn bộ chữ.
class TypewriterTextV2 extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration perChar;
  final Duration startDelay;

  const TypewriterTextV2(
    this.text, {
    super.key,
    this.style,
    this.perChar = const Duration(milliseconds: 38),
    this.startDelay = const Duration(milliseconds: 350),
  });

  @override
  State<TypewriterTextV2> createState() => _TypewriterTextV2State();
}

class _TypewriterTextV2State extends State<TypewriterTextV2>
    with TickerProviderStateMixin {
  late final AnimationController _type = AnimationController(
    vsync: this,
    duration: widget.perChar * widget.text.characters.length,
  );
  late final AnimationController _caret = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.startDelay, () {
      if (mounted) _type.forward();
    });
  }

  @override
  void dispose() {
    _type.dispose();
    _caret.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return Text(widget.text, style: widget.style);
    }
    final chars = widget.text.characters.toList();
    return AnimatedBuilder(
      animation: Listenable.merge([_type, _caret]),
      builder: (_, __) {
        final n = (_type.value * chars.length).round().clamp(0, chars.length);
        final shown = chars.take(n).join();
        final typing = n < chars.length;
        // Con trỏ nhấp nháy: luôn hiện khi đang gõ, nháy khi gõ xong.
        final caretOn = typing || _caret.value > 0.5;
        return Text(
          caretOn ? '$shown▌' : shown,
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.clip,
        );
      },
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
