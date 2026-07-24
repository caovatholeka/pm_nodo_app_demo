import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui_v2/attendance/tabs/attendance_tab_v2.dart';
import 'package:pm_app/app/features/ui_v2/attendance/tabs/explanation_tab_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Dữ liệu công — giao diện tối (v2).
///
/// Đây là **lớp vỏ (shell)** v2: thanh tiêu đề + tab bar được vẽ lại bằng
/// `AppTokensV2`/nền tối, hành vi (2 tab, cubit, điều hướng thông báo) giữ
/// nguyên như [AttendanceDataPage] bản cũ.
///
/// Nội dung 2 tab con dùng bản tối [AttendanceTabV2] (lịch tháng, số ngày
/// phép, hoạt động chấm công) và [ExplanationTabV2] (danh sách giải trình
/// công) — cùng cubit/hành vi như bản cũ, chỉ đổi trình bày sang tối.
class AttendanceDataPageV2 extends StatefulWidget {
  const AttendanceDataPageV2({super.key});

  @override
  State<AttendanceDataPageV2> createState() => _AttendanceDataPageV2State();
}

class _AttendanceDataPageV2State extends State<AttendanceDataPageV2>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final _cubit = GetIt.I<AttendanceDataCubit>();

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
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
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
      backgroundColor: AppTokensV2.bgDeep,
      body: AmbientBackgroundV2(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: StaggerRevealV2(index: 0, child: _topBar(s)),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: StaggerRevealV2(index: 1, child: _tabBar(s)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTokensV2.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppTokensV2.radius),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      AttendanceTabV2(cubit: _cubit),
                      const ExplanationTabV2(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(S s) {
    return Row(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(s.work_data_tab1,
            style: AppTokensV2.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNotification,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            border: Border.all(color: AppTokensV2.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.notifications_none_rounded,
              size: 20, color: AppTokensV2.fgSoft),
        ),
      ),
    ]);
  }

  Widget _tabBar(S s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppTokensV2.surfaceStrong,
        border: Border.all(color: AppTokensV2.border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 2),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        indicator: BoxDecoration(
          gradient: AppTokensV2.accentGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTokensV2.fgSoft,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        onTap: (_) => HapticFeedback.selectionClick(),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        tabs: [
          Tab(text: s.work_data_tab1),
          Tab(text: s.work_data_tab2),
        ],
      ),
    );
  }
}
