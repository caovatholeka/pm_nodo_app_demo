import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_tokens_v2.dart';

/// Thẻ kiểu kính với viền hairline.
///
/// HIỆU NĂNG: [BackdropFilter] rất tốn GPU — mỗi thẻ là một lượt blur toàn vùng.
/// Nhiều thẻ cùng lúc sẽ làm máy nóng và tụt pin. Vì vậy mặc định [blur] = false:
/// dùng nền bán trong suốt (trông vẫn "kính" vì lộ nền gradient/blob phía sau)
/// mà gần như không tốn gì. Chỉ bật [blur] = true ở 1–2 chỗ thật cần
/// (ví dụ thanh nav nổi trên nội dung cuộn).
///
/// Nếu truyền [gradient] thì thẻ dùng nền đặc (không blur).
class GlassCardV2 extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final bool blur;

  const GlassCardV2({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = AppTokensV2.radius,
    this.gradient,
    this.blur = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        // Không blur thì tăng nhẹ độ đục để vẫn đọc rõ trên nền tối.
        color: gradient == null
            ? (blur ? AppTokensV2.surface : AppTokensV2.surfaceStrong)
            : null,
        borderRadius: r,
        border: Border.all(color: AppTokensV2.border, width: 1),
        boxShadow: gradient != null
            ? [
                BoxShadow(
                    color: AppTokensV2.glow,
                    blurRadius: 26,
                    offset: const Offset(0, 12))
              ]
            : null,
      ),
      child: child,
    );

    if (gradient != null || !blur) {
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
