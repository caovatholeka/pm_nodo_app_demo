import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/dashboard/widgets/attendance_data.dart';
import 'package:pm_app/app/features/ui/dashboard/widgets/birthday_card.dart';
import 'package:pm_app/app/features/ui/dashboard/widgets/rating_line_chart.dart';
import 'package:pm_app/app/features/ui/dashboard/widgets/summary_rating_card.dart';
import 'package:pm_app/app/features/ui/dashboard/widgets/total_project.dart';
import 'package:pm_app/app/features/ui/dashboard/widgets/work_status_card.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/birthday_list_detail_v2.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/discipline_evaluation_detail_v2.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/projects_detail_v2.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/timesheet_data_detail_v2.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/work_quality_detail_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Dashboard (đánh giá công việc) — phiên bản giao diện tối (v2).
///
/// QUYẾT ĐỊNH PHẠM VI (đã nêu trong report): đây là màn "shell" — chỉ đổi
/// khung ngoài (nền/top bar) sang hệ thiết kế v2. Các widget con và 5 trang
/// chi tiết mà bản gốc [DashboardPage] điều hướng tới **giữ nguyên giao diện
/// sáng**, vì việc restyle toàn bộ cây con (bao gồm biểu đồ Syncfusion) nằm
/// ngoài phạm vi task này (đã ghi rõ trong đề bài). Danh sách còn sáng:
/// - `lib/app/features/ui/dashboard/widgets/work_status_card.dart`
/// - `lib/app/features/ui/dashboard/widgets/summary_rating_card.dart`
/// - `lib/app/features/ui/dashboard/widgets/rating_line_chart.dart` (RatingSummaryCard, dùng Syncfusion)
/// - `lib/app/features/ui/dashboard/widgets/total_project.dart` (dùng Syncfusion)
/// - `lib/app/features/ui/dashboard/widgets/birthday_card.dart`
/// - `lib/app/features/ui/dashboard/widgets/attendance_data.dart` + `attendance_data_item.dart`
/// - `lib/app/features/ui/dashboard/work_quality_detail.dart` (+ `widgets/work_quality_*`)
/// - `lib/app/features/ui/dashboard/discipline_evaluation_detail.dart` (+ `widgets/discipline_evaluation_detail_card.dart`)
/// - `lib/app/features/ui/dashboard/projects_detail.dart` (+ `widgets/project_bar_chart_card.dart`, `progress_list_card.dart`)
/// - `lib/app/features/ui/dashboard/birthday_list_detail.dart`
/// - `lib/app/features/ui/dashboard/timesheet_data_detail.dart`
/// - `lib/app/features/ui/dashboard/widgets/comment_card.dart`
///
/// Hành vi giữ NGUYÊN bản cũ: cùng [DashboardCubit] (qua GetIt, `BlocProvider`
/// bọc toàn màn như bản gốc), cùng thứ tự gọi ở initState
/// (getRequestSummaries/getProjectTasks/getTimeSheetData/getBirthdaysThisMonth),
/// cùng 5 điều hướng chi tiết.
class DashboardPageV2 extends StatefulWidget {
  const DashboardPageV2({super.key});

  @override
  State<DashboardPageV2> createState() => _DashboardPageV2State();
}

class _DashboardPageV2State extends State<DashboardPageV2> {
  final _cubit = GetIt.I.get<DashboardCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getRequestSummaries();
    _cubit.getProjectTasks();
    _cubit.getTimeSheetData(DateTime.now().month);
    _cubit.getBirthdaysThisMonth(DateTime.now().month);
  }

  void _goWorkQuality() {
    HapticFeedback.selectionClick();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const WorkQualityDetailV2()));
  }

  void _goDisciplineEvaluationDetail() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DisciplineEvaluationDetailV2()),
    );
  }

  void _goProject() {
    HapticFeedback.selectionClick();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProjectsDetailV2()));
  }

  void _goBirthdayList() {
    HapticFeedback.selectionClick();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BirthdayListDetailV2()));
  }

  void _goTimeSheetData() {
    HapticFeedback.selectionClick();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TimesheetDataDetailV2()));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
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
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: StaggerRevealV2(
                      index: 1,
                      child: Column(
                        children: [
                          const WorkStatusCard(),
                          const SizedBox(height: 12),
                          SummaryRatingCard(onTap: _goWorkQuality),
                          const SizedBox(height: 12),
                          RatingSummaryCard(
                            onTap: _goDisciplineEvaluationDetail,
                          ),
                          const SizedBox(height: 12),
                          TotalProject(onTap: _goProject),
                          const SizedBox(height: 12),
                          BirthdayCard(onTap: _goBirthdayList),
                          const SizedBox(height: 12),
                          AttendanceData(onTap: _goTimeSheetData),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
        child: Text(
          s.appraisal_work_quality_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}
