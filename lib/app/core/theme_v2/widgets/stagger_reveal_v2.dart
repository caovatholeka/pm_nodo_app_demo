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
