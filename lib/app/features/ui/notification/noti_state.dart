import 'package:flutter/material.dart';
import '../../../core/commons/app_assets.dart';

class NotificationItem {
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;
  final String imagepath;
  


  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.imagepath
  });
}

class NotiState {
  List<NotificationItem> today = [
    NotificationItem(
      title: 'Reminder for your meetings',
      subtitle: 'Learn more about managing account info and activity',
      time: '9 phút trước',
      isUnread: true,
      imagepath: AppAssets.ic_boxG
    ),
    NotificationItem(
      title: 'Robert mention you!',
      subtitle: 'Learn more about managing account info and activity',
      time: '14 phút trước',
      isUnread: false,
      imagepath: AppAssets.ic_boxR
    ),
  ];

  List<NotificationItem> yesterday = [
    NotificationItem(
      title: 'Reminder for your serial',
      subtitle: 'Looking forward to it',
      time: '9 phút trước',
      isUnread: true,
      imagepath: AppAssets.ic_boxY
    ),
    NotificationItem(
      title: 'Reminder for your serial',
      subtitle: 'Learn more about managing account info and activity',
      time: '14 phút trước',
      isUnread: false,
      imagepath: AppAssets.ic_boxG
    ),
  ];
}
