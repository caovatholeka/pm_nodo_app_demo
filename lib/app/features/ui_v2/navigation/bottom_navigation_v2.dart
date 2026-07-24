import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/features/ui_v2/account/account_page_v2.dart';
import 'package:pm_app/app/features/ui/checkin/check_in_page.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_page.dart';
import 'package:pm_app/app/features/ui_v2/home/home_page_v2.dart';

class BottomNavigationV2 extends StatelessWidget {
  const BottomNavigationV2({super.key});

  static const _pages = <Widget>[
    HomePageV2(), StaffPage(), CheckInPage(), OnLeavePage(), AccountPageV2(),
  ];
  static const _icons = <IconData>[
    Icons.home_rounded, Icons.people_alt_rounded, Icons.fingerprint,
    Icons.event_available_rounded, Icons.person_rounded,
  ];
  static const _labels = <String>['Trang chủ', 'Nhân viên', 'Chấm công', 'Nghỉ phép', 'Cá nhân'];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: GlobalData.instance.bottomNavIndex,
      builder: (_, index, __) {
        final safeIndex = (index >= 0 && index < _pages.length) ? index : 0;
        return Scaffold(
          backgroundColor: AppTokensV2.bgDeep,
          extendBody: true,
          body: _pages[safeIndex],
          bottomNavigationBar: _GlassBar(current: safeIndex, icons: _icons, labels: _labels),
        );
      },
    );
  }
}

class _GlassBar extends StatelessWidget {
  final int current;
  final List<IconData> icons;
  final List<String> labels;
  const _GlassBar({required this.current, required this.icons, required this.labels});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom > 0 ? bottom : 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0x8C14141A),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTokensV2.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < icons.length; i++)
                  _BarItem(
                    icon: icons[i], label: labels[i], active: i == current,
                    onTap: () => GlobalData.instance.bottomNavIndex.value = i,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _BarItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTokensV2.accent : AppTokensV2.fgMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
