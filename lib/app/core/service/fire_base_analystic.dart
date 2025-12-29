import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalysticService {
  FirebaseAnalysticService._();

  static final FirebaseCrashlytics _crashlytics =
      FirebaseCrashlytics.instance;

  static final FirebaseAnalytics analytics =
      FirebaseAnalytics.instance;

  static Future<void> initialize() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = (FlutterErrorDetails details) {
      _crashlytics.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static void log(String message) {
    _crashlytics.log(message);
  }

  static void recordError(
    dynamic error,
    StackTrace stack, {
    bool fatal = false,
  }) {
    _crashlytics.recordError(error, stack, fatal: fatal);
  }

  static Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
    await analytics.setUserId(id: userId);
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    await analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  static void setCustomKey(String key, Object value) {
    _crashlytics.setCustomKey(key, value);
  }

  static void testCrash() {
    _crashlytics.crash();
  }
}
