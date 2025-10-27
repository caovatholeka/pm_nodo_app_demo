import 'package:flutter/material.dart';

import '../../core/commons/app_colors.dart';


class CheckBoxSelection extends StatelessWidget {
  const CheckBoxSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.themePrimaryDefault,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          width: 1,
          color: Colors.transparent,
        ),
      ),
      child: Center(
        child: Icon(Icons.check,color: Colors.white,size: 14,),
      ),
    );
  }
}
