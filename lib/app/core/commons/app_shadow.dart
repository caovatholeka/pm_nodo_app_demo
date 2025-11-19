import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadow {
  static final boxShadow = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 3,
      offset: Offset(0, 0),
    ),
  ];

  static const bottomShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 6,
      offset: Offset(0, -4),
    )
  ];

  static final pageBoxShadow = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 6,
      offset: Offset(0, 0),
    ),
  ];

  static final boxShadowHideBottom = [
    BoxShadow(
      color: Color(0xffEDEDED),
      blurRadius: 3,
      offset: Offset(0, -3),
    ),
  ];
  static final boxShadowHideTop = [
    BoxShadow(
      color: Color(0xffEDEDED),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static final boxShadowNormal = [
    BoxShadow(
      offset: Offset(0, 2),
      color: Color(0x32000029),
      blurRadius: 4.0,
    ),
  ];

  static final bottomButtonShadow = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 5,
      offset: Offset(0, -5),
    ),
  ];

  static const boxShadowCart = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 3,
      offset: Offset(0, 0),
    ),
  ];
}