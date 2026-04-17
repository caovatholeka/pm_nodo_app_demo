import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/service/local_notification_service.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';

import '../../../firebase_options.dart';
import '../../data/local/shared_prefs_helper.dart';
import '../logger/logger.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static bool _foregroundHandlersInitialized = false;
  static bool _tokenRefreshInitialized = false;

  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    logger.d(
      'Background FCM: id=${message.messageId}, '
      'title=${message.notification?.title}, data=${message.data}',
    );

    if (message.notification == null &&
        LocalNotificationService.hasDisplayableContent(message)) {
      await LocalNotificationService.initialize();
      await LocalNotificationService.showNotification(message);
    }
  }

  static void _openNotificationPage() {
    final navigator = GlobalData.instance.navigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
              child: const NotificationPage(),
            ),
      ),
    );
  }

  static void openFromLocalNotification() {
    _openNotificationPage();
  }

  static String? _encodeBase64(String? input) {
    if (input == null || input.isEmpty) return null;
    final bytes = utf8.encode(input);
    return base64Encode(bytes);
  }

  static Future<String?> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    String? rawId;

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      rawId = android.id;
    }
    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      rawId = ios.identifierForVendor;
    }
    return _encodeBase64(rawId);
  }

  static Future<String?> _getDeviceType() async {
    String? type;

    if (Platform.isAndroid) {
      type = "android";
    }
    if (Platform.isIOS) {
      type = "ios";
    }
    return type;
  }

  static Future<Map<String, String>> ensureCachedMessagingIdentifiers({
    bool refreshToken = false,
  }) async {
    String token = await SharedPrefsHelper.getFcmToken();
    String deviceId = await SharedPrefsHelper.getDeviceId();
    String deviceType = await SharedPrefsHelper.getDeviceType();

    if (deviceId.isEmpty) {
      deviceId = (await _getDeviceId()) ?? '';
      if (deviceId.isNotEmpty) {
        await SharedPrefsHelper.setDeviceId(deviceId);
      }
    }

    if (deviceType.isEmpty) {
      deviceType = (await _getDeviceType()) ?? '';
      if (deviceType.isNotEmpty) {
        await SharedPrefsHelper.setDeviceType(deviceType);
      }
    }

    if (refreshToken || token.isEmpty) {
      final latestToken = await _messaging.getToken();
      if (latestToken != null && latestToken.trim().isNotEmpty) {
        token = latestToken.trim();
        await SharedPrefsHelper.setFcmToken(token);
      }
    }

    logger.d(
      "FCM cache -> token=${token.isEmpty ? '<empty>' : token}, "
      "deviceId=${deviceId.isEmpty ? '<empty>' : deviceId}, "
      "deviceType=${deviceType.isEmpty ? '<empty>' : deviceType}",
    );

    return {
      'fcm_token': token,
      'device_id': deviceId,
      'device_type': deviceType,
    };
  }

  static void _setupTokenRefreshListener() {
    if (_tokenRefreshInitialized) return;
    _tokenRefreshInitialized = true;

    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((
      String token,
    ) async {
      final normalized = token.trim();
      if (normalized.isEmpty) {
        logger.d("Skip FCM token refresh because token is empty");
        return;
      }

      await SharedPrefsHelper.setFcmToken(normalized);
      logger.d("FCM token refreshed and cached");
    });
  }

  static Future<void> initializeFCM({int retry = 0}) async {
    const maxRetry = 3;

    try {
      FirebaseMessaging.onBackgroundMessage(backgroundHandler);
      _setupTokenRefreshListener();

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      logger.d("FCM permission: ${settings.authorizationStatus}");

      if (Platform.isIOS) {
        String? apnsToken;
        int apnsRetry = 0;
        const int maxApnsRetry = 5;

        while (apnsToken == null && apnsRetry < maxApnsRetry) {
          apnsToken = await _messaging.getAPNSToken();
          logger.d("APNs token (try $apnsRetry): $apnsToken");
          apnsRetry++;
        }

        if (apnsToken == null) {
          _setupForegroundHandlers();
          return;
        }
      }

      final identifiers = await ensureCachedMessagingIdentifiers(
        refreshToken: true,
      );

      logger.d("FCM TOKEN: ${identifiers['fcm_token']}");
      logger.d("DEVICE ID: ${identifiers['device_id']}");
      logger.d("DEVICE TYPE: ${identifiers['device_type']}");

      _setupForegroundHandlers();
    } on FirebaseException catch (e, s) {
      if (e.plugin == 'firebase_messaging') {
        logger.d(
          "FCM FirebaseException: ${e.code} - ${e.message} (retry = $retry)",
        );
        logger.d('$s');

        final msg = (e.message ?? '').toLowerCase();
        final isNetworkLost =
            msg.contains('network connection was lost') ||
            msg.contains('network') ||
            msg.contains('connection');

        if (isNetworkLost && retry < maxRetry) {
          await Future.delayed(const Duration(seconds: 2));
          return initializeFCM(retry: retry + 1);
        }

        if (e.code == 'apns-token-not-set') {
          logger.d("apns-token-not-set");
        }
      } else {
        logger.d("Firebase other error: $e");
        logger.d('$s');
      }
    } catch (e, s) {
      logger.d("Unexpected FCM error: $e");
      logger.d('$s');
    }
  }

  static void _setupForegroundHandlers() {
    if (_foregroundHandlersInitialized) return;
    _foregroundHandlersInitialized = true;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      logger.d("Foreground FCM: ${message.notification?.title}");
      await LocalNotificationService.showNotification(message);
      final data = message.data;
      logger.d("FCM DATA: $data");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      logger.d("Clicked notification -> open NotificationPage");
      _openNotificationPage();
    });
  }
}
