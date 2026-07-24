import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_cubit.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/attendance_tab/attendance_tab.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/explanation_tab/explanation_tab.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Dữ liệu công — giao diện tối (v2).
///
/// Đây là **lớp vỏ (shell)** v2: thanh tiêu đề + tab bar được vẽ lại bằng
/// `AppTokensV2`/nền tối, hành vi (2 tab, cubit, điều hướng thông báo) giữ
/// nguyên như [AttendanceDataPage] bản cũ.
///
/// LƯU Ý PHẠM VI: nội dung 2 tab con — [AttendanceTab] (lịch tháng, số ngày
/// phép, hoạt động chấm công) và [ExplanationTab] (danh sách giải trình công)
/// — vẫn dùng nguyên UI **sáng** của bản cũ. Hai tab này chứa lịch tháng tự vẽ
/// (`MonthView`), bottom sheet chọn năm/tháng riêng, thẻ số ngày phép, danh
/// sách hoạt động và trang gửi giải trình — việc restyle toàn bộ sang v2 sẽ
/// vượt phạm vi hợp lý của task này. Nếu cần bản tối đầy đủ cho 2 tab, cần
/// một task riêng.
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
              // Nội dung 2 tab con giữ nguyên UI sáng của bản cũ (xem ghi chú
              // phạm vi ở đầu file). Bọc trong khối nền trắng bo góc để tránh
              // vùng chữ tối trên nền tối bị lẫn.
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppTokensV2.radius),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      AttendanceTab(cubit: _cubit),
                      const ExplanationTab(),
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
