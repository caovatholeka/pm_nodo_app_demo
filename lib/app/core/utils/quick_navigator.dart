import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/router/routers.dart';
import 'package:pm_app/app/features/ui/task/task_manage_page.dart';

class QuickNavigator {
  static void navigate(String type, {bool ensureHomeBase = true}) {
    final nav = GlobalData.instance.navigatorKey.currentState;
    if (nav == null) return;

    if (type == 'action_checkin') {
      _openBottomTab(nav, index: 2, ensureHomeBase: ensureHomeBase);
      return;
    }

    if (type == 'action_leave') {
      _openBottomTab(nav, index: 3, ensureHomeBase: ensureHomeBase);
      return;
    }

    if (type == 'action_tasks') {
      _openBottomTab(nav, index: 0, ensureHomeBase: ensureHomeBase);
      GlobalData.instance.quickActionPending = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentNav = GlobalData.instance.navigatorKey.currentState;
        if (currentNav == null) return;

        currentNav.push(
          MaterialPageRoute(
            builder: (_) => const TaskManagePage(isFromHome: true),
          ),
        );
      });
    }
  }

  static void _openBottomTab(
    NavigatorState nav, {
    required int index,
    required bool ensureHomeBase,
  }) {
    GlobalData.instance.bottomNavIndex.value = index;
    GlobalData.instance.quickActionPending = null;
    GlobalData.instance.isFromQuickAction = false;

    if (ensureHomeBase) {
      nav.pushNamedAndRemoveUntil(Routes.home, (route) => false);
      return;
    }

    try {
      nav.popUntil((route) => route.isFirst);
    } catch (_) {}
  }
}
