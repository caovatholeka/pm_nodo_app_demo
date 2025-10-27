import 'package:flutter/material.dart';

import '../../core/commons/app_colors.dart';


class CheckBoxIcon extends StatelessWidget {
  const CheckBoxIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          width: 1,
          color: AppColors.gray,
        ),
      ),
    );
  }
}
