import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGradient {
  static final homeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.appBarGradientStart,
      AppColors.appBarGradientEnd,
    ],

  );
}