import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/features/ui/checkin/check_in_page.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_page.dart';
import 'package:pm_app/app/features/ui/task/task_manage_page.dart';


class QuickNavigator {
  static void navigate(String type) {
    if (type == 'action_checkin') {
      GlobalData.instance.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const CheckInPage()),
      );
    }
    if (type == 'action_tasks') {
      GlobalData.instance.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const TaskManagePage()),
      );
    }
    if (type == 'action_leave') {
      GlobalData.instance.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const OnLeavePage()),
      );
    }
  }
}
