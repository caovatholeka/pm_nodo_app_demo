import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  static ThemeData theme = ThemeData(
    primaryColor: AppColors.whiteColor,
    primarySwatch: Colors.green,
    primaryTextTheme:  const TextTheme(labelLarge: TextStyle(color: Colors.white)),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Inter',
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.gray,
    ),
    colorScheme: const ColorScheme.light(primary: AppColors.whiteColor),
  );
}