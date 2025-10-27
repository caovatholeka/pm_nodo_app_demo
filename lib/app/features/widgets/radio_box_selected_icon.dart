import 'package:flutter/material.dart';

import '../../core/commons/app_colors.dart';


class RadioBoxSelectedIcon extends StatelessWidget {
  const RadioBoxSelectedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 1,
          color: AppColors.themePrimaryDefault,
        ),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.themePrimaryDefault,
          ),
        ),
      ),
    );
  }
}
