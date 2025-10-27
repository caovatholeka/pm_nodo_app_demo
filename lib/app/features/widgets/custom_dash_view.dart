import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../../core/commons/app_colors.dart';

class CustomDashView extends StatelessWidget {
  const CustomDashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: const DottedLine(
        direction: Axis.horizontal,
        lineLength: double.infinity,
        lineThickness: 1.0,
        dashLength: 4.0,
        dashColor: AppColors.gray,
        dashGapLength: 4.0,
        dashGapColor: Colors.transparent,
      ),
    );
  }
}