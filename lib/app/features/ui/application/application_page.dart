import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/appraisal_form_page.dart';
import 'package:pm_app/app/features/ui/appraisal_form/appraisal_page.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_page.dart';
import 'package:pm_app/app/features/ui/checkin/check_in_page.dart';
import 'package:pm_app/app/features/ui/justification/justification_page.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_page.dart';
import 'package:pm_app/app/features/ui/overtime/overtime_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_page.dart';
import 'package:pm_app/app/features/ui/task/task_manage_page.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_page.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

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

  void _openJustifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JustificationPage(isFromHome: true)),
    );
  }

  void _openOT() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OvertimePage(isFromHome: true)),
    );
  }

  void _openAppraisalForm() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AppraisalPage()));
  }

  void _openBusinessTrip() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => WorkTripPage()));
  }

  void openDashborad() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AppraisalFormPage()));
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
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (prev, cur) => prev.totalUnread != cur.totalUnread,
        builder: (context, appState) {
          return MyAppBar(
            titleAppbar: s.application_title,
            haveBackButton: true,
            haveActionButton: true,
            iconPathAsset: AppAssets.icNotificationBell,
            badgeCount: appState.totalUnread,
            actionCallBack: () async {
              _goNotification();
            },
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    final s = S.of(context);
    final items = [
      {
        "icon": AppAssets.ic_paper2,
        "title": s.app_until1,
        "onTap": () => _openJustifications(),
      },

      {
        "icon": AppAssets.ic_paper2,
        "title": s.app_until2,
        "onTap": () => _openOT(),
      },

      {
        "icon": AppAssets.ic_paper2,
        "title": s.app_until3,
        "onTap": () => _openBusinessTrip(),
      },

      {
        "icon": AppAssets.ic_paper2,
        "title": s.app_until4,
        "onTap": () => _openAppraisalForm(),
      },
      {
        "icon": AppAssets.ic_paper,
        "title": "Dashboard",
        "onTap": () => openDashborad(),
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
          mainAxisExtent: 110,
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
