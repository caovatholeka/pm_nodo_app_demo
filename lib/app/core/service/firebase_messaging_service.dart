import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import '../../../firebase_options.dart';

import 'package:pm_app/app/core/commons/global_data.dart';

import '../logger/logger.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("🔵 Background FCM: ${message.messageId}");
  }

  static void _openNotificationPage() {
    final navigator = GlobalData.instance.navigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
          child: const NotificationPage(),
        ),
      ),
    );
  }

  static void openFromLocalNotification() {
    _openNotificationPage();
  }

  static Future<String?> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return android.id;
    }
    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.identifierForVendor;
    }
    return null;
  }

  static Future<void> initializeFCM({int retry = 0}) async {
    const maxRetry = 3;

    try {
      FirebaseMessaging.onBackgroundMessage(backgroundHandler);

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
          if (apnsToken == null) {
            await Future.delayed(const Duration(seconds: 1));
          }
          apnsRetry++;
        }

        if (apnsToken == null) {

          _setupForegroundHandlers();
          return;
        }
      }

      final token = await _messaging.getToken();
      final deviceId = await _getDeviceId();
      logger.d("🔔 FCM TOKEN: $token");
      logger.d("📱 DEVICE ID: $deviceId");

      _setupForegroundHandlers();
    } on FirebaseException catch (e, s) {
      if (e.plugin == 'firebase_messaging') {
        logger.d(
            "FCM FirebaseException: ${e.code} - ${e.message} (retry = $retry)");
        logger.d('$s');

        final msg = (e.message ?? '').toLowerCase();
        final isNetworkLost = msg.contains('network connection was lost') ||
            msg.contains('network') ||
            msg.contains('connection');

        if (isNetworkLost && retry < maxRetry) {
          await Future.delayed(const Duration(seconds: 2));
          return initializeFCM(retry: retry + 1);
        }

        if (e.code == 'apns-token-not-set') {
          logger.d(
            "⚠apns-token-not-set .",
          );
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.d("Foreground FCM: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      logger.d("Clicked notification → open NotificationPage");
      _openNotificationPage();
    });
  }
}
