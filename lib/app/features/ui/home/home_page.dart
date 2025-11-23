import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/features/ui/home/home_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/staff/staff_page.dart';
import 'package:pm_app/app/features/ui/task/task_manage_page.dart';
import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../widgets/attendance_status_card.dart';
import '../../widgets/news_card.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import '../attendance/attendance_data_page.dart';
import '../attendance/explanation/explanation_approval_page.dart';
import '../notification/noti_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _cubit = GetIt.I<HomeCubit>();
  final _appCubit = GetIt.I<AppCubit>();


  @override
  void initState() {
    _appCubit.getProfile();
    if((_appCubit.state.listTaskStages ?? []).isEmpty){
      _appCubit.getListTaskStages();
    }
    _cubit.getListAttendanceToday();
    super.initState();
  }

  void _goNoti() {
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
      MaterialPageRoute(builder: (_) => StaffPage(isFromHome: true,)),
    );
  }

  void _goAttendanceData() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AttendanceDataPage()),
    );
  }

  void _goWorkEntry() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => WorkEntryPage()));
  }

  void _openTaskList() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TaskManagePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: SizedBox(
              height: 290,
              width: double.infinity,
              child: SvgPicture.asset(AppAssets.homeBG, fit: BoxFit.fill),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<AppCubit, AppState>(
                          bloc: _appCubit,
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi ${state.userProfile?.name ?? ""} 👋',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Let's Find Your Work!",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: _goNoti,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SvgPicture.asset(
                            AppAssets.ic_notification,
                            width: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),


                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.92,
                      child: AttendanceStatusCard(
                        dateText: DateFormat(
                          "d 'tháng' M, yyyy",
                          "vi",
                        ).format(DateTime.now()),
                        checkInTime: "08.30 AM",
                        checkOutTime: "06.00 PM",
                        checkInStatus: "Done at 08.22 AM",
                        checkOutStatus: "Not yet",
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    "Tiện ích",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.menuText,
                    ),
                  ),

                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                    children: [
                      _item(AppAssets.ic_employee, "Nhân viên",
                        onTap: _openStaffPage
                      ),
                      _item(
                        AppAssets.ic_paper,
                        "Dữ liệu công",
                        onTap: _goAttendanceData,
                      ),
                      _item(AppAssets.ic_paper2, "Nghỉ phép"),
                      _item(
                        AppAssets.ic_timekeeping,
                        "Chấm công",
                        onTap: _goWorkEntry,
                      ),
                      _item(
                        AppAssets.ic_work, "Việc cần làm",
                        onTap: _openTaskList
                      ),
                    ],
                  ),

                  const SizedBox(height: 38),
                  Text(
                    "Lịch sử chấm công",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.menuText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(String asset, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(asset, width: 26, height: 26),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
