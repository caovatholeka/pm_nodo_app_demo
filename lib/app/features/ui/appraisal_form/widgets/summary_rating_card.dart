import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SummaryRatingCard extends StatefulWidget {
  const SummaryRatingCard({super.key});

  @override
  State<SummaryRatingCard> createState() => _SummaryRatingCardState();
}

class _SummaryRatingCardState extends State<SummaryRatingCard> {
  DateTime _selectedDate = DateTime.now();

  static const List<Color> _metricColors = [
    Color(0xFF8FA2FF),
    Color(0xFFFFB25C),
    Color(0xFF39DDF2),
  ];

  String get _monthLabel => DateFormat('MM/yyyy', 'en').format(_selectedDate);

  String get _monthApi =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().getWorkQuality(_monthApi);
    });
  }

  void _pickMonth() {
    int tempYear = _selectedDate.year;
    int tempMonth = _selectedDate.month;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        final nextDate = DateTime(tempYear, tempMonth);
                        setState(() {
                          _selectedDate = nextDate;
                        });
                        context.read<DashboardCubit>().getWorkQuality(
                          '${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}',
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
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: tempYear - 2020,
                        ),
                        onSelectedItemChanged: (index) {
                          tempYear = 2020 + index;
                        },
                        children: List.generate(
                          20,
                          (i) => Center(
                            child: Text(
                              (2020 + i).toString(),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
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
                              '${(i + 1).toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 18),
                            ),
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
      },
    );
  }

  List<Widget> buildLegendDots(List<Metric> data, List<Color> colors) {
    final count = data.length.clamp(0, 3);
    final dots = <Widget>[];

    for (var i = 0; i < count; i++) {
      dots.add(LegendDot(color: colors[i], text: data[i].label));
      if (i != count - 1) {
        dots.add(const SizedBox(width: 14));
      }
    }
    return dots;
  }

  double chartHeightByCount(int count) {
    switch (count.clamp(1, 3)) {
      case 1:
        return 120;
      case 2:
        return 220;
      default:
        return 300;
    }
  }

  Widget buildTaskLineWidget(List<Metric> data, List<Color> colors) {
    final count = data.length.clamp(0, 3);
    final chartHeight = count == 0 ? 0.0 : chartHeightByCount(count);

    return Column(
      children: [
        if (count > 0)
          SizedBox(
            height: chartHeight,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
                interval: 20,
                opposedPosition: true,
                axisLine: const AxisLine(width: 0),
                majorGridLines: const MajorGridLines(
                  dashArray: [4, 4],
                  color: Color(0xFFE8E8E8),
                ),
                labelStyle: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              series: [
                BarSeries<Metric, String>(
                  dataSource: data.take(3).toList(),
                  xValueMapper: (m, _) => m.label,
                  yValueMapper: (m, _) => m.value,
                  pointColorMapper: (_, index) => colors[index],
                  spacing: 0.3,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.outer,
                  ),
                ),
              ],
            ),
          ),
        if (count > 0) const SizedBox(height: 16),
        if (count > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildLegendDots(
              data.take(3).toList(),
              colors.take(3).toList(),
            ),
          ),
      ],
    );
  }

  List<Metric> _buildMetrics(DashboardState state) {
    final workQuality = state.workQuality;
    return [
      Metric('Khối lượng', workQuality?.volumeScore ?? 0),
      Metric('Tiến độ', workQuality?.progressScore ?? 0),
      Metric('Chất lượng', workQuality?.qualityScore ?? 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final data = _buildMetrics(state);
        final colors = _metricColors.take(data.length).toList();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
                      color: const Color(0xFFEEF7FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.icCheckBlue,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Text(
                      'Chất lượng công việc',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
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
                          SvgPicture.asset(AppAssets.icCalendar, width: 14),
                          const SizedBox(width: 6),
                          Text(
                            _monthLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (state.workQualityStatus == LoadStatus.LOADING)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator(color: Colors.blue,)),
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
              else
                buildTaskLineWidget(data, colors),
            ],
          ),
        );
      },
    );
  }
}

class Metric {
  final String label;
  final double value;

  Metric(this.label, num v) : value = v.toDouble();
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const LegendDot({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
