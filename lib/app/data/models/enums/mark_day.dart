import 'dart:ui';
import '../../../core/commons/app_colors.dart';

enum Mark { red, green, yellow }

extension MarkColor on Mark {
  Color get color => switch (this) {
    Mark.red => AppColors.colorNoClockIn,
    Mark.green => AppColors.colorCompliant,
    Mark.yellow => AppColors.colorLateClockIn
  };
}