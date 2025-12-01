import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_page.dart';

import '../../core/commons/app_assets.dart';
import '../../core/commons/app_colors.dart';
import '../ui/account/account_page.dart';
import '../ui/checkin/check_in_page.dart';
import '../ui/home/home_page.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    StaffPage(),
    const CheckInPage(),
    const OnLeavePage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).viewPadding.bottom;
return Scaffold(
  body: Stack(
    children: [
      _pages[_selectedIndex],
      Positioned(
        left: 0,
        right: 0,
        bottom: systemBottomPadding,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Container(
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.profileContainer,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return _buildNavItem(index);
              }),
            ),
          ),
        ),
      ),
    ],
  ),
);

  }

  Widget _buildNavItem(int index) {
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

    final isSelected = _selectedIndex == index;

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
          colorFilter: isSelected
              ? null
              : const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
