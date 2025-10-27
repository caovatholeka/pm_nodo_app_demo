import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/commons/app_colors.dart';

class LoadingOverlay {
  static bool _shown = false;

  static void show(BuildContext context, {
    Color? color,
    double size = 56,
    String? message,
  }) {
    if (_shown) return;
    _shown = true;

    final spinnerColor = color ?? AppColors.themePrimaryDefault;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Center(
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
      ),
    );
  }

  static void hide(BuildContext context) {
    if (_shown) {
      _shown = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}