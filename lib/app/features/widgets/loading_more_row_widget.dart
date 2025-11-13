import 'package:flutter/material.dart';

import '../../core/commons/app_colors.dart';

class LoadingMoreRowWidget extends StatelessWidget {
  final double? height;
  final Color color;
  final double loadingSize;
  final double strokeWidth;

  const LoadingMoreRowWidget({
    super.key,
    this.height = 80,
    this.color = Colors.white,
    this.loadingSize = 24,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        alignment: Alignment.center,
        child: SizedBox(
          width: loadingSize,
          height: loadingSize,
          child: CircularProgressIndicator(
            backgroundColor: color,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.themePrimaryDefault),
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}
