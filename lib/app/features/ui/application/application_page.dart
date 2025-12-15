import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_page.dart';
import 'package:pm_app/app/features/ui/checkin/check_in_page.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_page.dart';
import 'package:pm_app/app/features/ui/task/task_manage_page.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  void _goNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
              child: const NotificationPage(),
            ),
      ),
    );
  }

  void _openStaffPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StaffPage(isFromHome: true)),
    );
  }

  void _goAttendanceData() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AttendanceDataPage()),
    );
  }

  void _openCheckIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckInPage(isFromHome: true)),
    );
  }

  void _openOnLeave() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OnLeavePage(isFromHome: true)),
    );
  }

  void _openTaskList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskManagePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                const SizedBox(height: 32),
                _buildGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MyAppBar(
        titleAppbar: "Đơn từ",
        haveBackButton: true,
        haveActionButton: true,
        iconPathAsset: AppAssets.icNotificationBell,
        actionCallBack: _goNotification,
      ),
    );
  }

  Widget _buildGrid() {
    final items = [
      {
        "icon": AppAssets.ic_employee,
        "title": "Nhân viên",
        "onTap": () => _openStaffPage(),
      },
      {
        "icon": AppAssets.ic_paper,
        "title": "Dữ liệu công",
        "onTap": () => _goAttendanceData(),
      },
      {
        "icon": AppAssets.ic_timekeeping,
        "title": "Chấm công",
        "onTap": () => _openCheckIn(),
      },
      {
        "icon": AppAssets.ic_work,
        "title": "Việc cần làm",
        "onTap": () => _openTaskList(),
      },
      {
        "icon": AppAssets.ic_paper2,
        "title": "Nghỉ phép",
        "onTap": () => _openOnLeave(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 28,
          crossAxisSpacing: 28,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _MenuItem(
            iconAsset: item["icon"] as String,
            title: item["title"] as String,
            onTap: item["onTap"] as VoidCallback,
          );
        },
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String iconAsset;
  final String title;
  final VoidCallback? onTap;

  const _MenuItem({required this.iconAsset, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(iconAsset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
