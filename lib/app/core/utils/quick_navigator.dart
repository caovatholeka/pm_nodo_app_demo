import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/features/ui/task/task_manage_page.dart';

class QuickNavigator {
  static void navigate(String type) {
    final nav = GlobalData.instance.navigatorKey.currentState;
    if (nav == null) return;

    try {
      nav.popUntil((route) => route.isFirst);
    } catch (_) {}

    if (type == 'action_checkin') {
      GlobalData.instance.bottomNavIndex.value = 2;
      GlobalData.instance.quickActionPending = null;
      return;
    }

    if (type == 'action_leave') {
      GlobalData.instance.bottomNavIndex.value = 3;
      GlobalData.instance.quickActionPending = null;
      return;
    }

if (type == 'action_tasks') {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      nav.push(
        MaterialPageRoute(builder: (_) => const TaskManagePage()),
      );
    } catch (e) {
      nav.pushNamed('/tasks');
    }
  });
}

  }
}
