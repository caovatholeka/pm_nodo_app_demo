import 'dart:math';

import 'package:flutter/material.dart';

class FaceGuidePainter extends CustomPainter {
  final Rect rect;

  const FaceGuidePainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final double pad = 24;
    final RRect frame = RRect.fromRectAndCorners(
      Rect.fromLTWH(pad, pad, size.width - 2 * pad, size.height - 2 * pad),
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );

    final cornerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    _drawCorners(canvas, frame.outerRect, cornerPaint);

    final y = size.height * 0.55;
    final dashPaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _drawDottedLine(
      canvas,
      Offset(pad + 8, y),
      Offset(size.width - pad - 8, y),
      dashPaint,
      dashWidth: 6,
      gapWidth: 6,
    );

    final center = Offset(size.width / 2, size.height * 0.58);
    final cross = Paint()
      ..color = Colors.blue.shade300
      ..strokeWidth = 2;
    canvas.drawLine(center + const Offset(-8, 0), center + const Offset(8, 0), cross);
    canvas.drawLine(center + const Offset(0, -8), center + const Offset(0, 8), cross);
    final dot = Paint()..color = Colors.white;
    for (final p in [
      Offset(size.width * .28, size.height * .40),
      Offset(size.width * .72, size.height * .39),
      Offset(size.width * .50, size.height * .60),
      Offset(size.width * .60, size.height * .56),
      Offset(size.width * .40, size.height * .56),
    ]) {
      canvas.drawCircle(p, 3, dot);
    }
  }

  void _drawCorners(Canvas canvas, Rect r, Paint p) {
    const len = 26.0;
    const radius = 16.0;

    // TL
    canvas.drawArc(
      Rect.fromCircle(center: r.topLeft + const Offset(radius, radius), radius: radius),
      pi, pi / 2, false, p,
    );
    canvas.drawLine(r.topLeft + const Offset(radius, 0), r.topLeft + const Offset(radius + len, 0), p);
    canvas.drawLine(r.topLeft + const Offset(0, radius), r.topLeft + const Offset(0, radius + len), p);

    // TR
    canvas.drawArc(
      Rect.fromCircle(center: r.topRight + const Offset(-radius, radius), radius: radius),
      -pi / 2, pi / 2, false, p,
    );
    canvas.drawLine(r.topRight + const Offset(-radius, 0), r.topRight + const Offset(-radius - len, 0), p);
    canvas.drawLine(r.topRight + const Offset(0, radius), r.topRight + const Offset(0, radius + len), p);

    // BL
    canvas.drawArc(
      Rect.fromCircle(center: r.bottomLeft + const Offset(radius, -radius), radius: radius),
      pi / 2, pi / 2, false, p,
    );
    canvas.drawLine(r.bottomLeft + const Offset(radius, 0), r.bottomLeft + const Offset(radius + len, 0), p);
    canvas.drawLine(r.bottomLeft + const Offset(0, -radius), r.bottomLeft + const Offset(0, -radius - len), p);

    // BR
    canvas.drawArc(
      Rect.fromCircle(center: r.bottomRight + const Offset(-radius, -radius), radius: radius),
      0, pi / 2, false, p,
    );
    canvas.drawLine(r.bottomRight + const Offset(-radius, 0), r.bottomRight + const Offset(-radius - len, 0), p);
    canvas.drawLine(r.bottomRight + const Offset(0, -radius), r.bottomRight + const Offset(0, -radius - len), p);
  }

  void _drawDottedLine(Canvas c, Offset a, Offset b, Paint p,
      {double dashWidth = 6, double gapWidth = 4}) {
    final total = (b - a);
    final len = total.distance;
    final dir = total / len;
    double drawn = 0;
    while (drawn < len) {
      final start = a + dir * drawn;
      final end = a + dir * min(drawn + dashWidth, len);
      c.drawLine(start, end, p);
      drawn += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant FaceGuidePainter oldDelegate) =>
      oldDelegate.rect != rect;
}