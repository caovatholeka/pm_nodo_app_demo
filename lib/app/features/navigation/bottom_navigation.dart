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
    const StaffPage(),
    const CheckInPage(),
    const OnLeavePage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.themePrimaryDefault,
          unselectedItemColor: AppColors.themeBlackDefault,
          items: [
            BottomNavigationBarItem(
              icon: _selectedIndex == 0 ? SvgPicture.asset(AppAssets.icHomeActive,width: 18,height: 18,) :
              SvgPicture.asset(AppAssets.icHomeInactive,width: 18,height: 18,),
              label: "Trang chủ",//S.current.menu_home,
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 1 ? SvgPicture.asset(AppAssets.icStaffActive,width: 18,height: 18,) :
              SvgPicture.asset(AppAssets.icStaffInactive,width: 18,height: 18,),
              label: "Nhân viên",//S.current.menu_schedule,
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 2 ? SvgPicture.asset(AppAssets.icCheckinActivate,width: 16,height: 18,) :
              SvgPicture.asset(AppAssets.icCheckinInActivate,width: 16,height: 18,),
              label: "Chấm công"//S.current.menu_attendance,
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 3 ? SvgPicture.asset(AppAssets.icOnLeaveActive,width: 18,height: 18,) :
              SvgPicture.asset(AppAssets.icOnLeaveInactive,width: 18,height: 18,),
              label: "Nghỉ phép"//S.current.menu_notify,
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 4 ? SvgPicture.asset(AppAssets.icAccountActive,width: 18,height: 18,) :
              SvgPicture.asset(AppAssets.icAccountInactive,width: 18,height: 18,),
              label: "Cá nhân"//S.current.menu_account,
            ),
          ],
          selectedLabelStyle: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
            color: AppColors.themePrimaryDefault,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11.0,
            color: AppColors.themeBlackDefault,
          ),
        ),
      ),
    );
  }
}
