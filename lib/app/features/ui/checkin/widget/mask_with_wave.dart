import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/generated/l10n.dart';

class FaceMaskWithWave extends StatefulWidget {
  const FaceMaskWithWave({super.key});

  @override
  State<FaceMaskWithWave> createState() => _FaceMaskWithWaveState();
}

class _FaceMaskWithWaveState extends State<FaceMaskWithWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = MediaQuery.of(context).size;
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    final maskW = size.width * 0.70;
    final maskH = maskW * 1.18;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: maskW,
      height: maskH,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _FaceWavePainter(
                    rect: rect,
                    progress: _controller.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ),
        Positioned.fromRect(
          rect: rect,
          child: IgnorePointer(
            child: SvgPicture.asset(AppAssets.faceRecog, fit: BoxFit.fill),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 88 + paddingBottom,
          child: Column(
            children: [
              Text(
                s.check_in_hint2,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                s.check_in_hint3,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaceWavePainter extends CustomPainter {
  final Rect rect;
  final double progress;

  const _FaceWavePainter({required this.rect, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (rect.isEmpty) return;

    final waveRect = rect.deflate(18);
    final rrect = RRect.fromRectAndRadius(waveRect, const Radius.circular(22));
    const baseColor = AppColors.PrimaryColor;

    canvas.save();
    canvas.clipRRect(rrect);

    _drawWaveLine(
      canvas,
      waveRect,
      y: waveRect.top + waveRect.height * 0.38,
      amplitude: 8,
      frequency: 2.2,
      phase: progress * math.pi * 2,
      color: baseColor.withValues(alpha: 0.72),
    );
    _drawWaveLine(
      canvas,
      waveRect,
      y: waveRect.top + waveRect.height * 0.53,
      amplitude: 10,
      frequency: 2.4,
      phase: progress * math.pi * 2 + math.pi / 3,
      color: baseColor.withValues(alpha: 0.95),
    );
    _drawWaveLine(
      canvas,
      waveRect,
      y: waveRect.top + waveRect.height * 0.68,
      amplitude: 7,
      frequency: 2.0,
      phase: progress * math.pi * 2 + math.pi / 1.7,
      color: baseColor.withValues(alpha: 0.66),
    );
    canvas.restore();
  }

  void _drawWaveLine(
    Canvas canvas,
    Rect rect, {
    required double y,
    required double amplitude,
    required double frequency,
    required double phase,
    required Color color,
  }) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..color = color;

    final path = Path();
    final step = math.max(4.0, rect.width / 40);
    var firstPoint = true;

    for (double x = rect.left; x <= rect.right; x += step) {
      final t = (x - rect.left) / rect.width;
      final wave = math.sin((t * math.pi * 2 * frequency) + phase);
      final dy = y + wave * amplitude;

      if (firstPoint) {
        path.moveTo(x, dy);
        firstPoint = false;
      } else {
        path.lineTo(x, dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceWavePainter oldDelegate) {
    return oldDelegate.rect != rect || oldDelegate.progress != progress;
  }
}
