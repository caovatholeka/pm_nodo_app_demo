import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/appraisal_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/dashboard_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/justification/justification_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/overtime/overtime_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/work_trip/work_trip_page_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Đơn từ — giao diện tối (v2). Lưới tiện ích giữ nguyên 4 mục của bản cũ
/// [ApplicationPage] (Đi muộn/Về sớm, OT, Đơn công tác, Dashboard) và điều
/// hướng y hệt sang các trang gốc. Dashboard mở bản tối [DashboardPageV2]
/// (chỉ khung ngoài đổi màu — xem ghi chú phạm vi trong file đó); các mục
/// còn lại chưa có bản v2 tương ứng nên vẫn mở UI sáng gốc — đúng tinh thần
/// "chỉ đổi trình bày, không đổi nghiệp vụ".
class ApplicationPageV2 extends StatefulWidget {
  const ApplicationPageV2({super.key});

  @override
  State<ApplicationPageV2> createState() => _ApplicationPageV2State();
}

class _ApplicationPageV2State extends State<ApplicationPageV2> {
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

  void _openJustifications() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JustificationPageV2(isFromHome: true)),
    );
  }

  void _openOT() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OvertimePageV2(isFromHome: true)),
    );
  }

  void _openAppraisalForm() {
    HapticFeedback.selectionClick();
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AppraisalPageV2(isFromHome: true)));
  }

  void _openBusinessTrip() {
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute(builder: (_) => WorkTripPageV2()));
  }

  void _openDashboard() {
    HapticFeedback.selectionClick();
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const DashboardPageV2()));
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
              const SizedBox(height: 28),
              Expanded(
                child: StaggerRevealV2(index: 1, child: _grid(s)),
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
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(s.application_title,
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
          child: Icon(Icons.notifications_none_rounded,
              size: 20, color: AppTokensV2.fgSoft),
        ),
      ),
    ]);
  }

  Widget _grid(S s) {
    final items = <(IconData, String, VoidCallback)>[
      (Icons.schedule_rounded, s.app_until1, _openJustifications),
      (Icons.more_time_rounded, s.app_until2, _openOT),
      (Icons.card_travel_rounded, s.app_until3, _openBusinessTrip),
      // Phiếu đánh giá: bản v1 có, v2 bị thiếu. (Checkpoint không hiển thị theo yêu cầu.)
      (Icons.assignment_turned_in_rounded, s.app_until4, _openAppraisalForm),
      (Icons.dashboard_rounded, 'Dashboard', _openDashboard),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 12,
          mainAxisExtent: 104,
        ),
        itemBuilder: (context, index) {
          final it = items[index];
          return _menuItem(it.$1, it.$2, it.$3);
        },
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(children: [
        GlassCardV2(
          padding: EdgeInsets.zero,
          radius: 17,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(icon, color: AppTokensV2.accent, size: 25),
          ),
        ),
        const SizedBox(height: 8),
        Text(title,
            style: AppTokensV2.caption.copyWith(color: AppTokensV2.fgSoft),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
