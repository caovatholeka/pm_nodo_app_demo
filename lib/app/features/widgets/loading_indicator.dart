import 'package:flutter/material.dart';

import '../../core/commons/app_colors.dart';


class LoadingIndicatorWidget extends StatelessWidget {
  final Color color;
  final double size;

  const LoadingIndicatorWidget({super.key, this.color = AppColors.themePrimaryDefault, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          backgroundColor: color,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.loadingIndicator),
        ),
      ),
    );
  }
}
