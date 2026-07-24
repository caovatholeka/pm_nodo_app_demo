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
