import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/task_evaluation_entity.dart';
import 'package:pm_app/app/data/models/entities/work_quality_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/work_quality_chart_card_v2.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/work_quality_suggestion_card_v2.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/work_quality_task_card_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn "Chất lượng công việc" — chi tiết Dashboard, giao diện tối (v2).
///
/// Bản gốc: `lib/app/features/ui/dashboard/work_quality_detail.dart`.
/// Giữ nguyên [DashboardCubit] qua GetIt, cùng logic lọc theo tháng đã chọn
/// và cùng lời gọi `getWorkQualityDetail(month)`.
class WorkQualityDetailV2 extends StatefulWidget {
  const WorkQualityDetailV2({super.key});

  @override
  State<WorkQualityDetailV2> createState() => _WorkQualityDetailV2State();
}

class _WorkQualityDetailV2State extends State<WorkQualityDetailV2> {
  final _cubit = GetIt.I.get<DashboardCubit>();
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String get _monthApi =>
      '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

  void _loadData() {
    _cubit.getWorkQualityDetail(_monthApi);
  }

  DateTime? _parseEvaluationDate(String? raw) {
    return AppDateUtils.parseFlexibleDate(raw);
  }

  List<WorkQualityTaskItemDataV2> _mapTaskItems(
    WorkQualityEntity? entity,
    S s,
  ) {
    final tasks = entity?.taskEvaluations ?? const <TaskEvaluationEntity>[];

    return tasks
        .where((task) {
          final date = _parseEvaluationDate(task.evaluationDate);
          if (date == null) return false;
          return date.month == _selectedMonth.month &&
              date.year == _selectedMonth.year;
        })
        .map((task) {
          final evaluationDate = _parseEvaluationDate(task.evaluationDate);
          final subtitleDate = evaluationDate == null
              ? (task.evaluationDate ?? '')
              : AppDateUtils.formatFlexibleDateForDisplay(
                  task.evaluationDate,
                );

          return WorkQualityTaskItemDataV2(
            title: task.taskName ?? '',
            subtitle: s.appraisal_evaluated_by(
              task.evaluatorName ?? '',
              subtitleDate,
            ),
            description: task.feedback ?? '',
            owner: task.assignedEmployeeName ?? '',
            duration: s.appraisal_hours(task.executionHours ?? 0),
            tags: task.tags ?? const <String>[],
            projectLogo: task.projectLogo ?? '',
          );
        })
        .toList();
  }

  List<WorkQualityMetricBarDataV2> _buildBars(WorkQualityEntity? entity) {
    return [
      WorkQualityMetricBarDataV2(
        value: (entity?.volumeScore ?? 0).toDouble(),
        color: const Color(0xFF7B88E8),
      ),
      WorkQualityMetricBarDataV2(
        value: (entity?.progressScore ?? 0).toDouble(),
        color: const Color(0xFFF4A640),
      ),
      WorkQualityMetricBarDataV2(
        value: (entity?.qualityScore ?? 0).toDouble(),
        color: const Color(0xFF35C3D9),
      ),
    ];
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
                  child: BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, state) {
                      final detail = state.worQualityDetail;
                      final taskItems = _mapTaskItems(detail, s);
                      final bars = _buildBars(detail);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        child: StaggerRevealV2(
                          index: 1,
                          child: Column(
                            children: [
                              GlassCardV2(
                                child: WorkQualityChartCardV2(
                                  initialDate: _selectedMonth,
                                  bars: bars,
                                  onMonthChanged: (value) {
                                    setState(() {
                                      _selectedMonth = value;
                                    });
                                    _loadData();
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (state.workQualityStatus ==
                                  LoadStatus.LOADING)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: AppTokensV2.accent,
                                        strokeWidth: 2.2),
                                  ),
                                )
                              else if (state.workQualityStatus ==
                                  LoadStatus.FAILURE)
                                _emptyState(s.appraisal_load_failed)
                              else if (taskItems.isEmpty)
                                _emptyState(s.appraisal_no_review_this_month)
                              else
                                WorkQualityTaskListV2(items: taskItems),
                              const SizedBox(height: 12),
                              GlassCardV2(
                                child: WorkQualitySuggestionCardV2(
                                  month: _monthApi,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
        child: const Icon(Icons.arrow_back_ios_new_rounded,
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

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.rate_review_outlined,
                size: 36, color: AppTokensV2.fgMuted),
            const SizedBox(height: 10),
            Text(message, style: AppTokensV2.captionStrong),
          ],
        ),
      ),
    );
  }
}
