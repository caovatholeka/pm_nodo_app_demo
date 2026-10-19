import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_page.dart';
import '../../core/commons/app_assets.dart';
import '../../core/commons/app_colors.dart';
import '../ui/account/account_page.dart';
import '../ui/checkin/check_in_page.dart';
import '../ui/home/home_page.dart';
import '../../core/commons/global_data.dart';
import '../../core/utils/quick_navigator.dart';
import '../../core/commons/app_flags.dart';
import '../ui_v2/navigation/bottom_navigation_v2.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final List<Widget> _pages = const [
    HomePage(),
    StaffPage(),
    CheckInPage(),
    OnLeavePage(),
    AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = GlobalData.instance.quickActionPending;
      if (pending != null) {
        GlobalData.instance.quickActionPending = null;
        QuickNavigator.navigate(pending, ensureHomeBase: false);
      }
    });
  }

  void _onItemTapped(int index) {
    GlobalData.instance.bottomNavIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    if (AppFlags.isBetaUiActive()) {
      return const BottomNavigationV2();
    }
    final padding = MediaQuery.of(context).viewPadding.bottom;

    return ValueListenableBuilder<int>(
      valueListenable: GlobalData.instance.bottomNavIndex,
      builder: (_, selectedIndex, __) {
        return Scaffold(
          body: Stack(
            children: [
              _pages[selectedIndex],
              Positioned(
                left: 0,
                right: 0,
                bottom: padding,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.profileContainer,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (i) => _buildNavItem(i, selectedIndex),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, int selectedIndex) {
    final iconsActive = [
      AppAssets.icHomeActive,
      AppAssets.icStaffActive,
      AppAssets.icCheckinActivate,
      AppAssets.icOnLeaveActive,
      AppAssets.icAccountActive,
    ];

    final iconsInactive = [
      AppAssets.icHomeInactive,
      AppAssets.icStaffInactive,
      AppAssets.icCheckinInActivate,
      AppAssets.icOnLeaveInactive,
      AppAssets.icAccountInactive,
    ];

    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          isSelected ? iconsActive[index] : iconsInactive[index],
          width: 24,
          height: 24,
          colorFilter:
              isSelected ? null
          : const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
