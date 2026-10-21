import 'package:flutter/material.dart';
import '../app_tokens_v2.dart';

/// Nền dark premium: gradient + vài quầng sáng ĐỨNG YÊN.
///
/// HIỆU NĂNG: quầng sáng vẽ bằng [RadialGradient] (gần như miễn phí, không cần blur
/// filter), bọc [RepaintBoundary] để vẽ 1 lần rồi dùng lại.
///
/// Trước đây các quầng sáng trôi chậm liên tục (vẽ lại 60 lần/giây trên mọi màn v2):
/// lộ qua các thẻ bán trong suốt trông như thẻ "di chuyển, gợn sóng", tốn pin/GPU trên
/// máy yếu, và chỉ đứng yên ở máy bật "Xóa hiệu ứng động" (nên máy có máy không).
class AmbientBackgroundV2 extends StatelessWidget {
  final Widget child;
  const AmbientBackgroundV2({super.key, required this.child});

  /// Quầng sáng: RadialGradient mờ dần ra biên — thay cho blur filter.
  Widget _glow(double size, Color color, double opacity) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.45),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTokensV2.screenGradient),
      child: Stack(children: [
        RepaintBoundary(
          child: Stack(children: [
            Positioned(
              top: -90,
              left: -110,
              child: _glow(360, AppTokensV2.accent, 0.30 * AppTokensV2.ambientOpacity),
            ),
            Positioned(
              top: 90,
              right: -140,
              child: _glow(340, AppTokensV2.accent2, 0.26 * AppTokensV2.ambientOpacity),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: _glow(320, AppTokensV2.accent, 0.20 * AppTokensV2.ambientOpacity),
            ),
          ]),
        ),
        child,
      ]),
    );
  }
}
