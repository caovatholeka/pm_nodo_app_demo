import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';

import 'package:flutter_svg/flutter_svg.dart';

class FaceMaskWithWave extends StatefulWidget {
  final Animation<double> anim;        // 0..1, KHÔNG reverse (top -> bottom)
  final Duration countdown;            // ví dụ: Duration(seconds: 4)
  final VoidCallback onCountdownDone;  // gọi khi hết countdown -> bắt đầu scan

  const FaceMaskWithWave({super.key, 
    required this.anim,
    required this.countdown,
    required this.onCountdownDone,
  });

  @override
  State<FaceMaskWithWave> createState() => _FaceMaskWithWaveState();
}

class _FaceMaskWithWaveState extends State<FaceMaskWithWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countCtrl;
  late final Animation<double> _progress;
  Timer? _doneTimer;

  double _tMax = 0.0;
  double _tPrev = 0.0;

  @override
  void initState() {
    super.initState();

    _countCtrl = AnimationController(vsync: this, duration: widget.countdown);
    _progress = CurvedAnimation(parent: _countCtrl, curve: Curves.linear);
    _countCtrl.forward();
    _doneTimer = Timer(widget.countdown, () {
      if (mounted) widget.onCountdownDone();
    });

    widget.anim.addListener(() {
      final t = widget.anim.value;
      if (t >= _tPrev) {
        if (t > _tMax) _tMax = t;
      }
      _tPrev = t;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _doneTimer?.cancel();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          child: ClipPath(
            clipper: _OvalClipper(rect),
            child: CustomPaint(
              painter: _SingleSweepPainter(
                rect: rect,
                t: widget.anim.value,
                tMax: _tMax,
              ),
            ),
          ),
        ),


        Positioned.fromRect(
          rect: rect,
          child: IgnorePointer(
            child: SvgPicture.asset(AppAssets.faceRecog,
                fit: BoxFit.fill),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 88 + MediaQuery.of(context).padding.bottom,
          child: Column(
            children: [
              const Text(
                'Giữ yên camera',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Nhìn thẳng vào camera trong khi chúng tôi xác minh\nkhuôn mặt của bạn',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: LinearProgressIndicator(
                      value: _progress.value,
                      minHeight: 4,
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _SingleSweepPainter extends CustomPainter {
  final Rect rect;
  final double t;
  final double tMax;

  _SingleSweepPainter({
    required this.rect,
    required this.t,
    required this.tMax,
  });

  @override
  void paint(Canvas canvas, Size size) {

    if (tMax > 0) {
      final fillRect = Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * tMax);
      final fillPaint = Paint()..color = const Color(0xFF1EA7FF).withOpacity(0.12);
      canvas.drawRect(fillRect, fillPaint);
    }


    final barH = rect.height * 0.11;
    final yTop = rect.top + (rect.height - barH) * t;
    final barRect = Rect.fromLTWH(rect.left, yTop, rect.width, barH);

    final barPaint = Paint()..color = Colors.white.withOpacity(0.92);
    canvas.drawRect(barRect, barPaint);


    final mid = barRect.center.dy;
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = barH * 0.18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(barRect.left, mid), Offset(barRect.right, mid), linePaint);
  }

  @override
  bool shouldRepaint(covariant _SingleSweepPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.tMax != tMax || oldDelegate.rect != rect;
}

class _OvalClipper extends CustomClipper<Path> {
  final Rect rect;
  _OvalClipper(this.rect);
  @override
  Path getClip(Size size) => Path()..addOval(rect);
  @override
  bool shouldReclip(covariant _OvalClipper oldClipper) => oldClipper.rect != rect;
}