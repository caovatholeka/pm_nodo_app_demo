import 'dart:math';
import 'package:flutter/material.dart';

class CenteredFaceGuidePainter extends CustomPainter {
  Rect computeGuideRect(Size screenSize) {
    final w = screenSize.width * 0.70;
    final hRaw = w * 1.25;
    final h = hRaw.clamp(0.0, screenSize.height * 0.82);
    return Rect.fromCenter(
      center: Offset(screenSize.width / 2, screenSize.height / 2),
      width: w,
      height: h,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = computeGuideRect(size);

    final p = Paint()
      ..color = const Color(0xFF2F80ED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..isAntiAlias = true;

    _drawCornerBrackets(canvas, rect, p, cornerRadius: 18, arm: 28);

    final dot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final y = rect.top + rect.height * 0.58;
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _dottedLine(canvas, Offset(rect.left + 12, y), Offset(rect.right - 12, y), dashPaint,
        dash: 6, gap: 6);

    final cx = rect.center.dx;
    final cy = rect.top + rect.height * 0.62;
    final pts = <Offset>[
      Offset(cx, cy),
      Offset(cx - 14, cy - 10),
      Offset(cx + 14, cy - 10),
      Offset(cx - 22, cy),
      Offset(cx + 22, cy),
      Offset(cx, cy + 14),
      Offset(rect.left + rect.width * .28, rect.top + rect.height * .38),
      Offset(rect.right - rect.width * .28, rect.top + rect.height * .37),
      Offset(rect.left + rect.width * .40, rect.top + rect.height * .56),
      Offset(rect.right - rect.width * .40, rect.top + rect.height * .56),
    ];
    for (int i = 0; i < pts.length; i++) {
      final r = (i == 0) ? 4.0 : 3.0; // tâm to hơn chút
      canvas.drawCircle(pts[i], r, dot);
    }
  }

  void _drawCornerBrackets(Canvas c, Rect r, Paint p,
      {double cornerRadius = 16, double arm = 24}) {
    _corner(c, r.topLeft, p, _CornerDir.tl, cornerRadius, arm);
    _corner(c, r.topRight, p, _CornerDir.tr, cornerRadius, arm);
    _corner(c, r.bottomLeft, p, _CornerDir.bl, cornerRadius, arm); // BL OK
    _corner(c, r.bottomRight, p, _CornerDir.br, cornerRadius, arm);
  }

  void _corner(Canvas c, Offset o, Paint p, _CornerDir d, double rad, double arm) {
    switch (d) {
      case _CornerDir.tl:
        c.drawArc(Rect.fromCircle(center: o + Offset(rad, rad), radius: rad), pi, pi / 2, false, p);
        c.drawLine(o + Offset(rad, 0), o + Offset(rad + arm, 0), p);
        c.drawLine(o + Offset(0, rad), o + Offset(0, rad + arm), p);
        break;
      case _CornerDir.tr:
        c.drawArc(Rect.fromCircle(center: o + Offset(-rad, rad), radius: rad), -pi / 2, pi / 2, false, p);
        c.drawLine(o + Offset(-rad, 0), o + Offset(-rad - arm, 0), p);
        c.drawLine(o + Offset(0, rad), o + Offset(0, rad + arm), p);
        break;
      case _CornerDir.bl:
        c.drawArc(Rect.fromCircle(center: o + Offset(rad, -rad), radius: rad), pi / 2, pi / 2, false, p);
        c.drawLine(o + Offset(rad, 0), o + Offset(rad + arm, 0), p);
        c.drawLine(o + Offset(0, -rad), o + Offset(0, -rad - arm), p);
        break;
      case _CornerDir.br:
        c.drawArc(Rect.fromCircle(center: o + Offset(-rad, -rad), radius: rad), 0, pi / 2, false, p);
        c.drawLine(o + Offset(-rad, 0), o + Offset(-rad - arm, 0), p);
        c.drawLine(o + Offset(0, -rad), o + Offset(0, -rad - arm), p);
        break;
    }
  }

  void _dottedLine(Canvas c, Offset a, Offset b, Paint p, {double dash = 6, double gap = 6}) {
    final total = b - a;
    final len = total.distance;
    final dir = total / len;
    var drawn = 0.0;
    while (drawn < len) {
      final start = a + dir * drawn;
      final end = a + dir * min(drawn + dash, len);
      c.drawLine(start, end, p);
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

enum _CornerDir { tl, tr, bl, br }

