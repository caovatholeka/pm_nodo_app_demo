import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/application/application_page.dart';
import 'package:pm_app/app/features/ui/checkin/check_in_page.dart';
import 'package:pm_app/app/features/ui/home/home_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_page.dart';
import 'package:pm_app/app/features/ui/task/task_detail_page.dart';
import 'package:pm_app/app/features/ui/task/task_manage_page.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../widgets/attendance_status_card.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import '../attendance/attendance_data_page.dart';
import '../notification/noti_page.dart';
import '../task/widget/list_task_item.dart';

extension ScaleExt on BuildContext {
  double sw(double v) => MediaQuery.of(this).size.width * v;
  double sh(double v) => MediaQuery.of(this).size.height * v;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _cubit = GetIt.I<HomeCubit>();
  final _appCubit = GetIt.I<AppCubit>();
  // final _attendanceCubit = GetIt.I<AttendanceDataCubit>();

  @override
  void initState() {
    super.initState();
    _appCubit.getProfile();

    if ((_appCubit.state.listTaskStages ?? []).isEmpty) {
      _appCubit.getListTaskStages();
    }

    _cubit.getListAttendanceToday();
    _cubit.getListNewTasks();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotiCubit>().countUnreadNoti();
    });
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

  void _openApplication() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ApplicationPage()),
    );
  }

  Future<void> _onRefresh() async {
    _cubit.getListAttendanceToday();
    _cubit.getListNewTasks();
  }

  Future<void> _openDetailTask(TaskEntity entity) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TaskDetailPage(taskEntity: entity, taskId: entity.id),
      ),
    );

    if (result != null && result) {
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = context.sh(0.30);

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(context.sw(0.05)),
              bottomRight: Radius.circular(context.sw(0.05)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: headerHeight,
              child: SvgPicture.asset(AppAssets.homeBG, fit: BoxFit.cover),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sw(0.04),
                    vertical: context.sh(0.015),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(context),
                      SizedBox(height: context.sh(0.02)),
                      _attendanceCard(context),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.sw(0.04),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: context.sh(0.002)),
                          _utilitiesTitle(context),
                          SizedBox(height: context.sh(0.015)),
                          _utilitiesGrid(context),
                          SizedBox(height: context.sh(0.03)),
                          _taskTitle(context),
                          SizedBox(height: context.sh(0.01)),
                          _taskList(context),
                          SizedBox(height: context.sh(0.03)),
                        ],
                      ),
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

  Widget _header(BuildContext context) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<AppCubit, AppState>(
            bloc: _appCubit,
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${s.home_title}${state.userProfile?.name ?? ""}",
                    style: TextStyle(
                      fontSize: context.sw(0.06),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.sh(0.006)),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: context.sw(0.035),
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: "${s.home_subtitle} "),
                        TextSpan(
                          text: s.home_subtitle_bold,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        BlocBuilder<NotiCubit, NotiState>(
          buildWhen: (prev, cur) => prev.totalUnread != cur.totalUnread,
          builder: (context, state) {
            final unread = state.totalUnread;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(context.sw(0.03)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.sw(0.04)),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      AppAssets.ic_notification,
                      width: context.sw(0.065),
                    ),

                    if (unread > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unread > 99 ? "99+" : unread.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _attendanceCard(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: _cubit,
      builder: (context, state) {
        String checkInStatus;
        String checkOutStatus;

        // String formatTime(String datetime) {
        //   try {
        //     final dt = DateFormat("yyyy-MM-dd HH:mm").parse(datetime);
        //     return DateFormat("hh:mm a", "en_US").format(dt);
        //   } catch (_) {
        //     return "";
        //   }
        // }

        if (state.checkInToday == null) {
          checkInStatus = s.attendance_cardCheck_in;
        } else {
          checkInStatus = AppDateUtils().formatTimeAmPm(
            state.checkInToday ?? "",
          );
        }

        if (state.checkOutToday == null) {
          checkOutStatus = s.attendance_cardCheck_in;
        } else {
          checkOutStatus = AppDateUtils().formatTimeAmPm(
            state.checkOutToday ?? "",
          );
        }

        return Center(
          child: SizedBox(
            width: context.sw(0.92),
            child: AttendanceStatusCard(
              dateText: DateFormat.yMMMMd(
                Localizations.localeOf(context).languageCode,
              ).format(DateTime.now()),
              checkInTime: "08:30",
              checkOutTime: "18:00",
              checkInStatus: checkInStatus,
              checkOutStatus: checkOutStatus,
              onCheckOutTap: _openCheckIn,
            ),
          ),
        );
      },
    );
  }

  Widget _utilitiesTitle(BuildContext context) {
    final s = S.of(context);
    return Text(
      s.utilities_title,
      style: TextStyle(
        fontSize: context.sw(0.045),
        fontWeight: FontWeight.bold,
        color: AppColors.menuText,
      ),
    );
  }

  Widget _utilitiesGrid(BuildContext context) {
    final s = S.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        const idealWidth = 90;
        final crossAxisCount = (screenWidth / idealWidth).floor().clamp(3, 4);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: context.sh(0.02),
            crossAxisSpacing: context.sw(0.03),
          ),
          itemBuilder: (_, index) {
            final map = [
              {"a": AppAssets.ic_employee, "t": s.utilities_tab1, "code": "nv"},
              {"a": AppAssets.ic_paper, "t": s.utilities_tab2, "code": "dlc"},
              {"a": AppAssets.ic_paper2, "t": s.utilities_tab3, "code": "np"},
              {
                "a": AppAssets.ic_timekeeping,
                "t": s.utilities_tab4,
                "code": "cc",
              },
              {"a": AppAssets.ic_work, "t": s.utilities_tab5, "code": "cv"},
              {"a": AppAssets.ic_paper2, "t": s.utilities_tab6, "code": "dt"},
            ];
            return _gridItem(
              context,
              map[index]["a"]!,
              map[index]["t"]!,
              map[index]["code"]!,
            );
          },
        );
      },
    );
  }

  Widget _gridItem(
    BuildContext context,
    String asset,
    String title,
    String code,
  ) {
    return InkWell(
      onTap: () {
        switch (code) {
          case "nv":
            _openStaffPage();
          case "dlc":
            _goAttendanceData();
          case "np":
            _openOnLeave();
          case "cc":
            _openCheckIn();
          case "cv":
            _openTaskList();
          case "dt":
            _openApplication();
        }
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.sw(0.035)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.sw(0.04)),
            ),
            child: Image.asset(
              asset,
              width: context.sw(0.065),
              height: context.sw(0.065),
            ),
          ),
          SizedBox(height: context.sh(0.008)),
          Text(
            title,
            style: TextStyle(fontSize: context.sw(0.032), color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _taskTitle(BuildContext context) {
    final s = S.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          s.to_do_title,
          style: TextStyle(
            fontSize: context.sw(0.045),
            fontWeight: FontWeight.w700,
            color: AppColors.menuText,
          ),
        ),

        InkWell(
          onTap: _openTaskList,
          child: Text(
            s.to_do_all,
            style: TextStyle(
              fontSize: context.sw(0.033),
              color: AppColors.subtitle,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _taskList(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: _cubit,
      buildWhen:
          (prev, cur) =>
              prev.listNewTasks != cur.listNewTasks ||
              prev.loadDataStatus != cur.loadDataStatus,
      builder: (context, state) {
        final tasks = state.listNewTasks ?? [];

        if (state.loadDataStatus == LoadStatus.LOADING) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: context.sh(0.02)),
              child: CircularProgressIndicator(
                color: AppColors.themePrimaryDefault,
              ),
            ),
          );
        }

        if (tasks.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: context.sh(0.015)),
            child: Text(s.to_do_no_data),
          );
        }

        return Column(
          children:
              tasks.map((e) {
                return ListTaskItem(
                  onShowDetail: () {
                    _openDetailTask(e);
                  },
                  entity: e,
                  isShowNote: false,
                ).paddingOnly(bottom: context.sh(0.02));
              }).toList(),
        );
      },
    );
  }
}
