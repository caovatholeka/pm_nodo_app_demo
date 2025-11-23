import 'package:flutter/material.dart';
import 'dart:math' as math;

class StatusWidget extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const StatusWidget({
    super.key,
    required this.color,
    this.width = 14,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: RightHalfCirclePainter(color: color),
    );
  }
}

class RightHalfCirclePainter extends CustomPainter {
  final Color color;

  RightHalfCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Rect arcRect = Rect.fromLTWH(
      -size.width,
      0,
      size.width * 2,
      size.height,
    );


    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant RightHalfCirclePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
