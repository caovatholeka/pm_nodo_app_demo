import 'package:flutter/material.dart';

import '../../core/commons/app_colors.dart';

class RadioBoxIcon extends StatelessWidget {
  const RadioBoxIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 1,
          color: AppColors.themeBlackDefault,
        ),
      ),
    );
  }
}
