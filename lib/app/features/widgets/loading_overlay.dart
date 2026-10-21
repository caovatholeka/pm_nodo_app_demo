import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/commons/app_colors.dart';

class LoadingOverlay {
  static bool _shown = false;

  // Gắn vào nội dung hộp loading đang hiện, để hide() tắt ĐÚNG hộp đó — kể cả khi đã có
  // route khác (Flushbar, dialog...) mở đè lên trên. Trước đây hide() pop route trên cùng
  // → đóng nhầm Flushbar, hộp loading kẹt lại trên màn hình.
  static GlobalKey? _key;
  // Hộp loading hiện tại đã được dựng chưa (để phân biệt "chưa kịp dựng" với "đã bị đóng").
  static bool _built = false;

  static void show(BuildContext context, {
    Color? color,
    double size = 56,
    String? message,
  }) {
    if (_shown) return;
    _shown = true;

    final spinnerColor = color ?? AppColors.themePrimaryDefault;
    final key = GlobalKey();
    _key = key;
    _built = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) {
        if (identical(_key, key)) _built = true;
        return Center(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chọn 1 trong các SpinKit:
            // SpinKitFadingCircle, SpinKitThreeBounce, SpinKitWave, ...
            SpinKitFadingCircle(
              size: size,
              color: spinnerColor,
              // nếu muốn nhiều màu, dùng SpinKitFadingCube + itemBuilder
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
      },
    );
  }

  static void hide(BuildContext context) {
    if (_shown) {
      _shown = false;
      final dialogContext = _key?.currentContext;
      _key = null;

      final route = dialogContext != null ? ModalRoute.of(dialogContext) : null;
      if (route != null) {
        if (route.isCurrent) {
          Navigator.of(dialogContext!).pop();
        } else if (route.isActive) {
          // Có route khác đè lên trên: gỡ riêng hộp loading, không đụng route kia.
          Navigator.of(dialogContext!).removeRoute(route);
        }
        return;
      }

      // Đã dựng nhưng không còn (bị đóng bằng nút Back...) → không pop gì nữa, tránh đóng
      // nhầm màn hình đang mở.
      if (_built) return;

      // Hộp loading chưa kịp dựng (show/hide trong cùng 1 frame): nó đang ở trên cùng.
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
