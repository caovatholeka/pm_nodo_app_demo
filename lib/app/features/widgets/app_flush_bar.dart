import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../core/commons/app_colors.dart';


final navigatorKey = GlobalKey<NavigatorState>();

class DxFlushBar {
  static void showErrorFlushBar(String? mess) => DxFlushBar.showFlushBar(navigatorKey.currentContext!,
      type: FlushBarType.ERROR, message: (mess ?? '').toString().trim());

  static void showSuccessFlushBar(String? mess) => DxFlushBar.showFlushBar(navigatorKey.currentContext!,
      type: FlushBarType.SUCCESS, message: (mess ?? '').toString().trim());

  static void showWarningFlushBar(String? mess) => DxFlushBar.showFlushBar(navigatorKey.currentContext!,
      type: FlushBarType.WARNING, message: (mess ?? '').toString().trim());

  static void showFlushBar(
      BuildContext context, {
        FlushBarType type = FlushBarType.NOTIFICATION,
        String title = "",
        String message = "",
        int duration = 3,
        FlushbarPosition position = FlushbarPosition.TOP,
      }) {
    Color _backgroundColor;
    Icon _icon;
    //String _title;
    switch (type) {
      case FlushBarType.NOTIFICATION:
        _backgroundColor = const Color(0xff63a026);
        _icon = const Icon(Icons.info, color: Colors.white);
        // _title = "Warning";
        break;
      case FlushBarType.SUCCESS:
        _backgroundColor = const Color(0xFF63a026);
        _icon = const Icon(Icons.check_circle, color: Colors.white);
        // _title = "Success";
        break;
      case FlushBarType.ERROR:
        _backgroundColor = const Color(0xFFf64438);
        _icon = const Icon(Icons.error, color: Colors.white);
        // _title = "Error";
        break;
      case FlushBarType.WARNING:
        _backgroundColor = const Color(0xFFedbc38);
        _icon = const Icon(Icons.warning, color: Colors.white);
        // _title = "Alert";
        break;
    }

    // if (title != null && title.isNotEmpty) {
    //   _title = title;
    // }

    Flushbar flushBar;
    flushBar = Flushbar(
      isDismissible: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      //title: _title,
      message: message != ""
          ? message
          : title == ""
          ? "Myllv"
          : title,
      duration: Duration(seconds: duration),
      flushbarPosition: position,
      backgroundColor: _backgroundColor,
      icon: _icon,
      flushbarStyle: FlushbarStyle.GROUNDED,
    );
    flushBar.show(context);
  }

  static void showNotificationFlushBar(
      BuildContext context,
      String title,
      String content,
      Function(Flushbar flushbar) onTap, {
        int duration = 3,
        FlushbarPosition position = FlushbarPosition.TOP,
        FlushbarStyle style = FlushbarStyle.FLOATING,
        String? imagePath,
        Color? backgroundColor,
        double? borderRadius,
      }) {
    Flushbar flushBar;

    flushBar = Flushbar(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      titleText: const Text(
        'NODO PM',
        style: TextStyle(
          color: AppColors.gray,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      messageText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.themeBlackDefault,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.themeBlackDefault,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      duration: Duration(seconds: duration),
      flushbarPosition: position,
      backgroundColor: backgroundColor ?? Colors.grey,
      icon: Image.asset(imagePath ?? ''),
      flushbarStyle: style,
      borderRadius: BorderRadius.circular(borderRadius ?? 10),
      onTap: onTap,
    );
    flushBar.show(context);
  }

  static void showMessageFlushBar(BuildContext context, String title, String message) {
    Flushbar flushBar;
    flushBar = Flushbar(
      title: title,
      message: message != ""
          ? message
          : title,
      isDismissible: true,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: const Color(0xFF63a026),
      icon: const Icon(Icons.mail_outline, color: Colors.white),
    );
    flushBar.show(context);
  }

  static void showCoordinationFlushBar(BuildContext context, String title, String message) {
    Flushbar flushBar;
    flushBar = Flushbar(
      title: title,
      message: message,
      isDismissible: true,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: const Color(0xFF63a026),
      icon: const Icon(Icons.mail_outline, color: Colors.white),
    );
    flushBar.show(context);
  }

  static void showPointFlushBar(BuildContext context, String title, String message) {
    Flushbar flushBar;
    flushBar = Flushbar(
      title: title,
      message: message,
      isDismissible: true,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: const Color(0xFF63a026),
      icon: const Icon(Icons.mail_outline, color: Colors.white),
    );
    flushBar.show(context);
  }
}

enum FlushBarType {
  NOTIFICATION,
  SUCCESS,
  WARNING,
  ERROR
}