import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/weeks_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DisciplineEvaluationDetailCard extends StatefulWidget {
  const DisciplineEvaluationDetailCard({super.key});

  @override
  State<DisciplineEvaluationDetailCard> createState() =>
      _DisciplineEvaluationDetailCardState();
}

class _DisciplineEvaluationDetailCardState
    extends State<DisciplineEvaluationDetailCard> {
  int _selectedMonth = DateTime.now().month;
  final int _selectedYear = DateTime.now().year;

  String get _monthLabel =>
      'Tháng ${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().getDisciplineEvaluationDetail(_selectedMonth);
    });
  }

  void _pickMonth() {
    int tempMonth = _selectedMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMonth = tempMonth;
                        });
                        context.read<DashboardCubit>().getDisciplineEvaluationDetail(
                          tempMonth,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Xong',
                        style: TextStyle(
                          color: Color(0xFF2E87FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: tempMonth - 1,
                  ),
                  onSelectedItemChanged: (index) {
                    tempMonth = index + 1;
                  },
                  children: List.generate(
                    12,
                    (i) => Center(
                      child: Text(
                        'Tháng ${(i + 1).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
    final maxValue = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 10) return 10;
    final normalized = (maxValue / 2).ceil() * 2;
    return normalized.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final detail = state.disciplineEvaluationDetail;
        final weeks = detail?.weeks ?? const <WeeksEntity>[];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE7F3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.icUserRating,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Đánh giá nề nếp',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF50555C),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _pickMonth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.icCalendar,
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _monthLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, size: 18),
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
                    child: CircularProgressIndicator(color: Color(0xFF2E87FF)),
                  ),
                )
              else if (state.disciplineDetailStatus == LoadStatus.FAILURE)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      'Không tải được dữ liệu',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else ...[
                const Padding(
                  padding: EdgeInsets.only(left: 2, bottom: 6),
                  child: Text(
                    'Số lần',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 380,
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 1,
                    plotAreaBorderColor: const Color(0xFFD9D9D9),
                    margin: EdgeInsets.zero,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(
                        width: 1,
                        dashArray: [3, 3],
                        color: Color(0xFFD6D6D6),
                      ),
                      axisLine: const AxisLine(
                        width: 1,
                        color: Color(0xFFA3A3A3),
                      ),
                      majorTickLines: const MajorTickLines(size: 0),
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555555),
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: _axisMax(weeks),
                      interval: 2,
                      axisLine: const AxisLine(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                      majorGridLines: const MajorGridLines(
                        width: 1,
                        dashArray: [3, 3],
                        color: Color(0xFFD6D6D6),
                      ),
                      labelFormat: '{value}',
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555555),
                      ),
                    ),
                    legend: const Legend(isVisible: false),
                    series: <CartesianSeries>[
                      LineSeries<_DisciplinePoint, String>(
                        dataSource: _lateEarlyPoints(weeks),
                        xValueMapper: (point, _) => point.x,
                        yValueMapper: (point, _) => point.y,
                        color: const Color(0xFF7489FF),
                        width: 2,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          width: 10,
                          height: 10,
                          color: Color(0xFF7489FF),
                          borderColor: Color(0xFFD5DAFF),
                          borderWidth: 4,
                        ),
                      ),
                      LineSeries<_DisciplinePoint, String>(
                        dataSource: _leavePoints(weeks),
                        xValueMapper: (point, _) => point.x,
                        yValueMapper: (point, _) => point.y,
                        color: const Color(0xFF69C88A),
                        width: 2,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          width: 10,
                          height: 10,
                          color: Color(0xFF69C88A),
                          borderColor: Color(0xFFD9F4E2),
                          borderWidth: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                      color: Color(0xFF7489FF),
                      text: 'Đi sớm về muộn',
                    ),
                    SizedBox(width: 20),
                    _LegendItem(
                      color: Color(0xFF69C88A),
                      text: 'Nghỉ phép',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SummaryBox(
                  onTimePercent: detail?.onTimePercent ?? 0,
                  absentCount: detail?.absentCount ?? 0,
                  lateEarlyCount: detail?.lateEarlyCount ?? 0,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final int onTimePercent;
  final int absentCount;
  final int lateEarlyCount;

  const _SummaryBox({
    required this.onTimePercent,
    required this.absentCount,
    required this.lateEarlyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              value: '$onTimePercent%',
              label: 'Đúng giờ',
              color: const Color(0xFF7C3AED),
            ),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryItem(
              value: '$absentCount',
              label: 'Vắng mặt',
              color: const Color(0xFFEF4444),
            ),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryItem(
              value: '$lateEarlyCount',
              label: 'Đi muộn/Về sớm',
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: const Color(0xFFE3E3E3),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 28,
                height: 5,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.98),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.95),
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

class _DisciplinePoint {
  final String x;
  final double y;

  const _DisciplinePoint({
    required this.x,
    required this.y,
  });
}
