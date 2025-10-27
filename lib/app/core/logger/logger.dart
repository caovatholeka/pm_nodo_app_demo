import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

var logger = AppLogger();

class AppLogger {
  /// Log a message at level verbose.
  void v(dynamic message) {
    _log("🤍 VERBOSE: $message");
  }

  /// Log a message at level debug.
  void d(dynamic message) {
    _log("💙 DEBUG: $message");
  }

  /// Log a message at level info.
  void i(dynamic message) {
    _log("💚️ INFO: $message");
  }

  /// Log a message at level warning.
  void w(dynamic message) {
    _log("💛 WARNING: $message");
  }

  /// Log a message at level error.
  void e(dynamic message) {
    _log("❤️ ERROR: $message");
  }

  /// Log a socket message
  void socket(String message, {dynamic data}) {
    String dataStr = '';
    if (data is Map<String, dynamic>) {
      dataStr = jsonEncode(data);
    } else if (data != null) {
      dataStr = data.toString();
    }
    long("🔥️ SOCKET - $message:\nData: $dataStr\n");
  }

  void _log(dynamic message) {
    if (kDebugMode) {
      print("$message");
    }
  }

  /// Log a long message
  void long(dynamic message) {
    if (kDebugMode) {
      log(message);
    }
  }
}
