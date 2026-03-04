import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/task_line_id_entity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SummaryRatingCard extends StatefulWidget {
  List<TaskLineIdEntity> listTasks;
  SummaryRatingCard({ super.key, required this.listTasks});

  @override
  State<SummaryRatingCard> createState() => _SummaryRatingCardState();
}

class _SummaryRatingCardState extends State<SummaryRatingCard> {
  DateTime _selectedDate = DateTime.now();

  String get _monthLabel =>
      DateFormat("'Tháng' MM/yyyy", 'vi').format(_selectedDate);

  // helpers
  double? parseProgressToDouble(String? raw, {bool treat0to1AsPercent = true}) {
    if (raw == null) return null;

    final cleaned = raw.trim().replaceAll(',', '.');
    final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(cleaned);
    if (match == null) return null;

    final v = double.tryParse(match.group(0)!);
    if (v == null) return null;

    if (treat0to1AsPercent && v >= 0 && v <= 1) return v * 100;

    return v;
  }
  List<Metric> buildMetricsFromTasks(List<TaskLineIdEntity> tasks) {
    final metrics = <Metric>[];

    for (final t in tasks) {
      final label = (t.name ?? '').trim();
      if (label.isEmpty) continue;

      final p = parseProgressToDouble(t.progress);
      if (p == null) continue;

      final safe = p.clamp(0, 100).toDouble();

      metrics.add(Metric(label, safe));

      if (metrics.length == 3) break; // tối đa 3 item
    }

    return metrics;
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
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Hủy bỏ',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = DateTime(tempYear, tempMonth);
                        });
                        Navigator.pop(context);
                        // TODO: gọi cubit load data theo tháng ở đây
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
                              'Tháng ${i + 1}',
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
      dots.add(LegendDot(
        color: colors[i],
        text: data[i].label,
      ));

      if (i != count - 1) dots.add(const SizedBox(width: 14));
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

  Widget buildTaskLineWidget(List<Metric> data, List<Color> colors){
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


  @override
  Widget build(BuildContext context) {
    // lấy tối đa 3 task ở preview theo design
    // xem full sẽ show hết
    logger.d("widget.listtask ::: ${widget.listTasks}");

    // final data = [
    //   Metric('Khối lượng', 56),
    //   Metric('Tiến độ', 64),
    //   Metric('Chất lượng', 76),
    // ];
    //
    // final colors = [
    //   const Color(0xFF8FA2FF),
    //   const Color(0xFFFFB25C),
    //   const Color(0xFF39DDF2),
    // ];
    const metricColors = [
      Color(0xFF8FA2FF),
      Color(0xFFFFB25C),
      Color(0xFF39DDF2),
    ];

    final data = buildMetricsFromTasks(widget.listTasks);
    final colors = metricColors.take(data.length).toList();

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            fontSize: 12, color: Colors.black54),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildTaskLineWidget(data,colors),
          // SizedBox(
          //   height: 300,
          //   child: SfCartesianChart(
          //     plotAreaBorderWidth: 0,
          //     primaryXAxis: CategoryAxis(
          //       axisLine: const AxisLine(width: 0),
          //       majorTickLines: const MajorTickLines(size: 0),
          //       majorGridLines: const MajorGridLines(width: 0),
          //       labelStyle:
          //           const TextStyle(fontSize: 13, color: Colors.black87),
          //     ),
          //     primaryYAxis: NumericAxis(
          //       minimum: 0,
          //       maximum: 100,
          //       interval: 20,
          //       opposedPosition: true,
          //       axisLine: const AxisLine(width: 0),
          //       majorGridLines: const MajorGridLines(
          //         dashArray: [4, 4],
          //         color: Color(0xFFE8E8E8),
          //       ),
          //       labelStyle:
          //           const TextStyle(fontSize: 11, color: Colors.black54),
          //     ),
          //     series: [
          //       BarSeries<Metric, String>(
          //         dataSource: data,
          //         xValueMapper: (m, _) => m.label,
          //         yValueMapper: (m, _) => m.value,
          //         pointColorMapper: (_, index) =>
          //             colors[index % colors.length],
          //         spacing: 0.3,
          //         dataLabelSettings: const DataLabelSettings(
          //           isVisible: true,
          //           labelAlignment: ChartDataLabelAlignment.outer,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 16),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: const [
          //     LegendDot(color: Color(0xFF8FA2FF), text: 'Khối lượng CV'),
          //     SizedBox(width: 14),
          //     LegendDot(color: Color(0xFFFFB25C), text: 'Tiến độ CV'),
          //     SizedBox(width: 14),
          //     LegendDot(color: Color(0xFF39DDF2), text: 'Chất lượng CV'),
          //   ],
          // ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E87FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Xem chi tiết',
                style: TextStyle(
                  color: Color(0xFF2E87FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
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
