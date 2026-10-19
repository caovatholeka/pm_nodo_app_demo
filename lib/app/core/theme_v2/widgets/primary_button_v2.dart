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
