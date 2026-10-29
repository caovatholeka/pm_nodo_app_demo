import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/generated/l10n.dart';

class AppSnackBar {
  static void showInfo({String? title, String? message, OnTap? onTap}) {
    Get.snackbar(
      title ?? S.current.attention,
      message ?? '',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      onTap: onTap
    );
  }

  static void showWarning({String? title, String? message}) {
    Get.snackbar(
      title ?? S.current.warning,
      message ?? '',
      backgroundColor: Colors.amber,
      colorText: Colors.white,
    );
  }

  static void showError({String? title, String? message}) {
    Get.snackbar(
      title ?? S.current.error,
      message ?? '',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
