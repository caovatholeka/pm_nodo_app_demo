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

  static Future<void> initializeFCM() async {
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    final deviceId = await _getDeviceId();
    print("🔔 FCM TOKEN: $token");
    print("📱 DEVICE ID: $deviceId");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🟢 Foreground FCM: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("🟡 Clicked notification → open NotificationPage");
      _openNotificationPage();
    });
  }
}
