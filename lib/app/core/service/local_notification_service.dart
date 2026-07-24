import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'firebase_messaging_service.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription = 'Used for important notifications.';

  /// Id cố định cho thông báo nhắc chấm công ra (đặt lại sẽ ghi đè, không nhân bản).
  static const int checkOutReminderId = 8801;

  static bool _tzReady = false;

  /// Khởi tạo timezone kiểu lazy — chỉ chạy khi thật sự cần hẹn giờ, để không
  /// làm chậm lúc mở app.
  static void _ensureTimeZone() {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    // App dùng nội bộ tại Việt Nam.
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    _tzReady = true;
  }

  /// Hẹn thông báo nhắc chấm công ra vào thời điểm [at].
  /// Gọi lại sẽ ghi đè lịch cũ (cùng id).
  static Future<void> scheduleCheckOutReminder({
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (!at.isAfter(DateTime.now())) return;
    try {
      _ensureTimeZone();
      await _plugin.zonedSchedule(
        checkOutReminderId,
        title,
        body,
        tz.TZDateTime.from(at, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      logger.d('Đã hẹn nhắc chấm công ra lúc $at');
    } catch (e) {
      logger.e('Hẹn nhắc chấm công ra thất bại: $e');
    }
  }

  /// Huỷ lịch nhắc chấm công ra (đã chấm ra, hoặc không còn cần).
  static Future<void> cancelCheckOutReminder() async {
    try {
      await _plugin.cancel(checkOutReminderId);
    } catch (e) {
      logger.e('Huỷ nhắc chấm công ra thất bại: $e');
    }
  }

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse:
          (response) => FirebaseMessagingService.openFromLocalNotification(),
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static bool hasDisplayableContent(RemoteMessage message) {
    return _resolveTitle(message) != null || _resolveBody(message) != null;
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final title = _resolveTitle(message);
    final body = _resolveBody(message);

    if (title == null && body == null) {
      logger.d(
        'Skip local notification because payload is empty. '
        'messageId=${message.messageId}, data=${message.data}',
      );
      return;
    }

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static String? _resolveTitle(RemoteMessage message) {
    return _firstNonEmpty([
      message.notification?.title,
      message.data['title'],
      message.data['name'],
    ]);
  }

  static String? _resolveBody(RemoteMessage message) {
    return _firstNonEmpty([
      message.notification?.body,
      message.data['body'],
      message.data['content'],
      message.data['message'],
    ]);
  }

  static String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final normalized = _normalizeText(value);
      if (normalized != null) {
        return normalized;
      }
    }
    return null;
  }

  static String? _normalizeText(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
