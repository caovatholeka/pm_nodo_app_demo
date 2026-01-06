import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_cubit.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/attendance_tab/attendance_tab.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/explanation_tab/explanation_tab.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/development_alert_dialog.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_colors.dart';


class AttendanceDataPage extends StatefulWidget {
  const AttendanceDataPage({super.key});

  @override
  State<AttendanceDataPage> createState() => _AttendanceDataPageState();
}

class _AttendanceDataPageState extends State<AttendanceDataPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final _cubit = GetIt.I<AttendanceDataCubit>();

  late PageController _pageController;
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.bodyColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<AppCubit, AppState>(
          buildWhen: (prev, cur) => prev.totalUnread != cur.totalUnread,
          builder: (context, appState) {
            return MyAppBar(
              titleAppbar: s.work_data_tab1,
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
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left : 16,right:16,top: 6),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: TabBar(
                      padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                      indicator: BoxDecoration(
                          color: Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(6),
                      ),
                      labelColor:AppColors.themePrimaryDefault,
                      unselectedLabelColor: AppColors.themeBlackDefault,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      tabs: [
                        Tab(text: s.work_data_tab1),
                        Tab(text: s.work_data_tab2),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        AttendanceTab(cubit: _cubit,),
                        ExplanationTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
