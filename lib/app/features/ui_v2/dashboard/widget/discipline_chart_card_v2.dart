import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/data/models/entities/weeks_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/month_picker_sheet_v2.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Bản v2 (dark) của `DisciplineEvaluationDetailCard`
/// (lib/app/features/ui/dashboard/widgets/discipline_evaluation_detail_card.dart).
///
/// Biểu đồ dùng syncfusion_flutter_charts — CHỈ đổi màu/theme, giữ nguyên
/// data mapping, trục và series như bản gốc.
class DisciplineChartCardV2 extends StatefulWidget {
  const DisciplineChartCardV2({super.key});

  @override
  State<DisciplineChartCardV2> createState() => _DisciplineChartCardV2State();
}

class _DisciplineChartCardV2State extends State<DisciplineChartCardV2> {
  int _selectedMonth = DateTime.now().month;
  final int _selectedYear = DateTime.now().year;

  String _monthLabel(BuildContext context) =>
      '${S.of(context).month} ${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().getDisciplineEvaluationDetail(
            _selectedMonth,
          );
    });
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPickerV2(context, initialMonth: _selectedMonth);
    if (picked == null || !mounted) return;
    setState(() => _selectedMonth = picked);
    context.read<DashboardCubit>().getDisciplineEvaluationDetail(picked);
  }

  List<_DisciplinePoint> _lateEarlyPoints(List<WeeksEntity> weeks) {
    return weeks
        .map(
          (e) => _DisciplinePoint(
            x: e.weekLabel ?? '',
            y: (e.earlyLateCount ?? 0).toDouble(),
          ),
        )
        .toList();
  }

  List<_DisciplinePoint> _leavePoints(List<WeeksEntity> weeks) {
    return weeks
        .map(
          (e) => _DisciplinePoint(
            x: e.weekLabel ?? '',
            y: (e.leaveCount ?? 0).toDouble(),
          ),
        )
        .toList();
  }

  double _axisMax(List<WeeksEntity> weeks) {
    final values = [
      ...weeks.map((e) => (e.earlyLateCount ?? 0).toDouble()),
      ...weeks.map((e) => (e.leaveCount ?? 0).toDouble()),
    ];
    final maxValue =
        values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 10) return 10;
    final normalized = (maxValue / 2).ceil() * 2;
    return normalized.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final detail = state.disciplineEvaluationDetail;
        final weeks = detail?.weeks ?? const <WeeksEntity>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.appraisal_occurrence_label,
                    style: AppTokensV2.body,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _pickMonth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTokensV2.surfaceStrong,
                      border: Border.all(color: AppTokensV2.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 13, color: AppTokensV2.fgMuted),
                        const SizedBox(width: 6),
                        Text(_monthLabel(context), style: AppTokensV2.caption),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 18, color: AppTokensV2.fgMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (state.disciplineDetailStatus == LoadStatus.LOADING)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppTokensV2.accent, strokeWidth: 2.2),
                ),
              )
            else if (state.disciplineDetailStatus == LoadStatus.FAILURE)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Text(
                    s.appraisal_load_failed,
                    style: AppTokensV2.captionStrong
                        .copyWith(color: AppTokensV2.danger),
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 380,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 1,
                  plotAreaBorderColor: AppTokensV2.border,
                  margin: EdgeInsets.zero,
                  primaryXAxis: CategoryAxis(
                    majorGridLines: MajorGridLines(
                      width: 1,
                      dashArray: const [3, 3],
                      color: AppTokensV2.border,
                    ),
                    axisLine: AxisLine(
                      width: 1,
                      color: AppTokensV2.fgMuted.withValues(alpha: 0.4),
                    ),
                    majorTickLines: const MajorTickLines(size: 0),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      color: AppTokensV2.fgMuted,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: _axisMax(weeks),
                    interval: 2,
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      dashArray: const [3, 3],
                      color: AppTokensV2.border,
                    ),
                    labelFormat: '{value}',
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      color: AppTokensV2.fgMuted,
                    ),
                  ),
                  legend: const Legend(isVisible: false),
                  series: <CartesianSeries>[
                    LineSeries<_DisciplinePoint, String>(
                      dataSource: _lateEarlyPoints(weeks),
                      xValueMapper: (point, _) => point.x,
                      yValueMapper: (point, _) => point.y,
                      color: AppTokensV2.accent2,
                      width: 2,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        width: 10,
                        height: 10,
                        color: AppTokensV2.accent2,
                        borderColor:
                            AppTokensV2.accent2.withValues(alpha: 0.35),
                        borderWidth: 4,
                      ),
                    ),
                    LineSeries<_DisciplinePoint, String>(
                      dataSource: _leavePoints(weeks),
                      xValueMapper: (point, _) => point.x,
                      yValueMapper: (point, _) => point.y,
                      color: AppTokensV2.success,
                      width: 2,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        width: 10,
                        height: 10,
                        color: AppTokensV2.success,
                        borderColor:
                            AppTokensV2.success.withValues(alpha: 0.35),
                        borderWidth: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendItemV2(
                    color: AppTokensV2.accent2,
                    text: s.appraisal_late_early_summary,
                  ),
                  const SizedBox(width: 20),
                  _LegendItemV2(
                    color: AppTokensV2.success,
                    text: s.appraisal_leave_label,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SummaryBoxV2(
                onTimePercent: detail?.onTimePercent ?? 0,
                absentCount: detail?.absentCount ?? 0,
                lateEarlyCount: detail?.lateEarlyCount ?? 0,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SummaryBoxV2 extends StatelessWidget {
  final int onTimePercent;
  final int absentCount;
  final int lateEarlyCount;

  const _SummaryBoxV2({
    required this.onTimePercent,
    required this.absentCount,
    required this.lateEarlyCount,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppTokensV2.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokensV2.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItemV2(
              value: '$onTimePercent%',
              label: s.appraisal_on_time,
              color: AppTokensV2.accent2,
            ),
          ),
          const _SummaryDividerV2(),
          Expanded(
            child: _SummaryItemV2(
              value: '$absentCount',
              label: s.appraisal_absent,
              color: AppTokensV2.danger,
            ),
          ),
          const _SummaryDividerV2(),
          Expanded(
            child: _SummaryItemV2(
              value: '$lateEarlyCount',
              label: s.appraisal_late_early_summary,
              color: AppTokensV2.warn,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItemV2 extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryItemV2({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTokensV2.number.copyWith(fontSize: 18, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: AppTokensV2.caption),
      ],
    );
  }
}

class _SummaryDividerV2 extends StatelessWidget {
  const _SummaryDividerV2();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: AppTokensV2.border);
  }
}

class _LegendItemV2 extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItemV2({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: AppTokensV2.caption),
      ],
    );
  }
}

class _DisciplinePoint {
  final String x;
  final double y;

  const _DisciplinePoint({required this.x, required this.y});
}
