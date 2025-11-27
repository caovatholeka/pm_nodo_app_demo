import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pm_app/app/core/service/notification_service.dart';
import 'package:pm_app/generated/intl/messages_en.dart';
import '../../../firebase_options.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("🔵 Background FCM: ${message.messageId}");
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

    await LocalNotificationService.initialize();

    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    final deviceId = await _getDeviceId();

    print("🔔 FCM TOKEN: $token");
    print("📱 DEVICE ID: $deviceId");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🟢 Foreground FCM: ${message.notification?.title}");
      LocalNotificationService.showNotification(message);
    });
    
    FirebaseMessaging.onMessageOpenedApp.listen((messages) {
      print("🟡 App opened from notification");
    });
  }
}
