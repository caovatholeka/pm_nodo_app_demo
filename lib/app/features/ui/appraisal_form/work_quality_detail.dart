import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/task_evaluation_entity.dart';
import 'package:pm_app/app/data/models/entities/work_quality_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/work_quality_chart_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/work_quality_suggestion_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/work_quality_task_card.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

class WorkQualityDetail extends StatefulWidget {
  const WorkQualityDetail({super.key});

  @override
  State<WorkQualityDetail> createState() => _WorkQualityDetailState();
}

class _WorkQualityDetailState extends State<WorkQualityDetail> {
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

  List<WorkQualityTaskItemData> _mapTaskItems(WorkQualityEntity? entity) {
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
          final subtitleDate =
              evaluationDate == null
                  ? (task.evaluationDate ?? '')
                  : AppDateUtils.formatFlexibleDateForDisplay(
                    task.evaluationDate,
                  );

          return WorkQualityTaskItemData(
            title: task.taskName ?? '',
            subtitle:
                'Đánh giá bởi: ${task.evaluatorName ?? ''} • $subtitleDate',
            description: task.feedback ?? '',
            owner: task.assignedEmployeeName ?? '',
            duration: '${task.executionHours ?? 0} giờ',
            tags: task.tags ?? const <String>[],
          );
        })
        .toList();
  }

  List<WorkQualityMetricBarData> _buildBars(WorkQualityEntity? entity) {
    return [
      WorkQualityMetricBarData(
        value: (entity?.volumeScore ?? 0).toDouble(),
        color: const Color(0xFF7B88E8),
      ),
      WorkQualityMetricBarData(
        value: (entity?.progressScore ?? 0).toDouble(),
        color: const Color(0xFFF4A640),
      ),
      WorkQualityMetricBarData(
        value: (entity?.qualityScore ?? 0).toDouble(),
        color: const Color(0xFF35C3D9),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        backgroundColor: AppColors.bodyColor,
        extendBodyBehindAppBar: true,
        appBar: const MyAppBar(
          titleAppbar: 'Chất lượng công việc',
          haveBackButton: true,
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                AppAssets.appbarBg,
                height: 170,
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  final detail = state.worQualityDetail;
                  final taskItems = _mapTaskItems(detail);
                  final bars = _buildBars(detail);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      children: [
                        WorkQualityChartCard(
                          initialDate: _selectedMonth,
                          bars: bars,
                          onMonthChanged: (value) {
                            setState(() {
                              _selectedMonth = value;
                            });
                            _loadData();
                          },
                        ),
                        const SizedBox(height: 12),
                        if (state.workQualityStatus == LoadStatus.LOADING)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.themePrimaryDefault,
                              ),
                            ),
                          )
                        else if (state.workQualityStatus == LoadStatus.FAILURE)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'Không tải được dữ liệu',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          )
                        else if (taskItems.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text('Không có đánh giá trong tháng này'),
                            ),
                          )
                        else
                          WorkQualityTaskList(items: taskItems),
                        const SizedBox(height: 12),
                        WorkQualitySuggestionCard(month: _monthApi),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
