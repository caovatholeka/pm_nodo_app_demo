import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';

/// Overlay HUD kiểu "facial scan" (sci-fi) phủ trên camera preview ở màn chấm
/// công. THUẦN TRANG TRÍ — không đụng logic nhận diện khuôn mặt.
///
/// Hiệu năng: khung góc + lưới điểm vẽ MỘT lần (bọc RepaintBoundary, không
/// animate). Chỉ đường quét + vòng % chạy theo một AnimationController duy nhất.
/// Không dùng BackdropFilter.
class FaceScanHudV2 extends StatefulWidget {
  /// Đang trong quá trình quét (ẩn/hiện đường quét & đổi chữ trạng thái).
  final bool scanning;

  /// Khuôn mặt đã ổn định/căn giữa -> chuyển tông xanh lá cho cảm giác "matched".
  final bool faceOk;

  /// Vị trí khuôn mặt trên màn (đã quy đổi). null = chưa thấy mặt -> dùng khung
  /// mặc định ở giữa. Nếu có, khung target sẽ bám theo mặt.
  final Rect? faceRect;

  const FaceScanHudV2({
    super.key,
    this.scanning = true,
    this.faceOk = false,
    this.faceRect,
  });

  @override
  State<FaceScanHudV2> createState() => _FaceScanHudV2State();
}

class _FaceScanHudV2State extends State<FaceScanHudV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final accent = widget.faceOk ? AppTokensV2.success : AppTokensV2.accent;
    final size = MediaQuery.of(context).size;
    // Khung mặc định (chưa thấy mặt): vuông ~78% bề ngang, lệch lên. Panel HUD
    // luôn neo theo khung mặc định này (không nhảy theo mặt).
    final frame = size.width * 0.78;
    final top = size.height * 0.16;
    final left = (size.width - frame) / 2;
    final rect = Rect.fromLTWH(left, top, frame, frame);

    // Khung target: bám mặt nếu có (nới nhẹ cho thoáng), ngược lại = khung mặc định.
    final target = widget.faceRect == null
        ? rect
        : widget.faceRect!.inflate(widget.faceRect!.shortestSide * 0.05);

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Khung góc + lưới + đường quét — BÁM theo mặt, glide mượt khi mặt di chuyển.
          TweenAnimationBuilder<Rect?>(
            tween: RectTween(end: target),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            builder: (_, r, __) {
              final tr = r ?? target;
              return Stack(fit: StackFit.expand, children: [
                CustomPaint(
                  painter: _FrameGridPainter(rect: tr, color: accent),
                  size: Size.infinite,
                ),
                if (widget.scanning && !reduce)
                  AnimatedBuilder(
                    animation: _c,
                    builder: (_, __) {
                      final t = (math.sin(_c.value * 2 * math.pi) + 1) / 2;
                      final y = tr.top + t * tr.height;
                      return CustomPaint(
                        painter:
                            _ScanLinePainter(rect: tr, y: y, color: accent),
                        size: Size.infinite,
                      );
                    },
                  ),
              ]);
            },
          ),

          // Panel trạng thái trên cùng.
          Positioned(
            left: left,
            right: left,
            top: top - 46,
            child: _topBar(accent),
          ),

          // Panel MATCHING (phải) + SCAN DATA (trái).
          Positioned(
            left: 14,
            top: top + frame * 0.30,
            child: _scanDataPanel(),
          ),
          Positioned(
            right: 14,
            top: top + frame * 0.30,
            child: _matchingPanel(accent),
          ),

          // "PLEASE KEEP STILL"
          Positioned(
            left: left,
            right: left,
            top: rect.bottom + 16,
            child: _keepStill(accent),
          ),
        ],
      ),
    );
  }

  Widget _topBar(Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FACIAL SCAN',
                style: TextStyle(
                    color: AppTokensV2.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5)),
            Text(widget.faceOk ? 'MATCHED' : 'SCANNING...',
                style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
          ],
        ),
        const Spacer(),
        AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Text(
            '${_percent()}%',
            style: TextStyle(
                color: accent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ),
      ],
    );
  }

  int _percent() {
    if (widget.faceOk) return 100;
    // 40 -> 96, nhịp theo controller (chỉ mang tính minh hoạ).
    return 40 + (((math.sin(_c.value * 2 * math.pi) + 1) / 2) * 56).round();
  }

  Widget _hudBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTokensV2.bgDeep.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTokensV2.border),
      ),
      child: child,
    );
  }

  Widget _label(String k, String v, {Color? vColor}) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$k ',
              style: const TextStyle(
                  color: AppTokensV2.fgMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          TextSpan(
              text: v,
              style: TextStyle(
                  color: vColor ?? AppTokensV2.fgSoft,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
        ]),
      ),
    );
  }

  Widget _scanDataPanel() {
    return _hudBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SCAN DATA',
              style: TextStyle(
                  color: AppTokensV2.fg,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          _label('FACE ID:', '87A2F1'),
          _label('STATUS:', widget.faceOk ? 'READY' : 'SCANNING',
              vColor: widget.faceOk ? AppTokensV2.success : AppTokensV2.accent),
        ],
      ),
    );
  }

  Widget _matchingPanel(Color accent) {
    return _hudBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('MATCHING',
              style: TextStyle(
                  color: AppTokensV2.fg,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) => SizedBox(
              width: 40,
              height: 40,
              child: CustomPaint(
                painter: _RingPainter(
                    progress: _percent() / 100, color: accent),
                child: Center(
                  child: Text('${_percent()}%',
                      style: TextStyle(
                          color: accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _keepStill(Color accent) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: AppTokensV2.bgDeep.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.6)),
        ),
        child: Text(
          widget.faceOk ? 'GIỮ NGUYÊN — ĐANG CHỤP' : 'VUI LÒNG GIỮ YÊN',
          style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2),
        ),
      ),
    );
  }
}

/// Khung 4 góc + lưới điểm mờ bên trong (vẽ tĩnh).
class _FrameGridPainter extends CustomPainter {
  final Rect rect;
  final Color color;
  _FrameGridPainter({required this.rect, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Lưới điểm mờ bên trong khung.
    final dot = Paint()..color = color.withValues(alpha: 0.14);
    const step = 26.0;
    for (double x = rect.left; x <= rect.right; x += step) {
      for (double y = rect.top; y <= rect.bottom; y += step) {
        canvas.drawCircle(Offset(x, y), 0.9, dot);
      }
    }

    // Viền khung mờ.
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.22);
    canvas.drawRect(rect, border);

    // 4 góc đậm.
    final corner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;
    const len = 26.0;
    void bracket(Offset o, Offset hx, Offset vy) {
      canvas.drawLine(o, o + hx, corner);
      canvas.drawLine(o, o + vy, corner);
    }

    bracket(rect.topLeft, const Offset(len, 0), const Offset(0, len));
    bracket(rect.topRight, const Offset(-len, 0), const Offset(0, len));
    bracket(rect.bottomLeft, const Offset(len, 0), const Offset(0, -len));
    bracket(rect.bottomRight, const Offset(-len, 0), const Offset(0, -len));
  }

  @override
  bool shouldRepaint(_FrameGridPainter old) =>
      old.rect != rect || old.color != color;
}

/// Đường quét ngang có quầng sáng.
class _ScanLinePainter extends CustomPainter {
  final Rect rect;
  final double y;
  final Color color;
  _ScanLinePainter({required this.rect, required this.y, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(rect);

    // Quầng sáng gradient quanh đường quét.
    final glow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.28),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTRB(rect.left, y - 26, rect.right, y + 26));
    canvas.drawRect(Rect.fromLTRB(rect.left, y - 26, rect.right, y + 26), glow);

    // Đường sáng chính.
    final line = Paint()
      ..color = color
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), line);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScanLinePainter old) => old.y != y || old.color != color;
}

/// Vòng % nhỏ cho panel MATCHING.
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 3;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppTokensV2.border;
    canvas.drawCircle(c, r, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2,
        2 * math.pi * progress.clamp(0, 1), false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
