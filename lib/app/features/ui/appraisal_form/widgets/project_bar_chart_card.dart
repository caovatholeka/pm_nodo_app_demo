import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProjectBarChartCard extends StatefulWidget {
  const ProjectBarChartCard({super.key});

  @override
  State<ProjectBarChartCard> createState() => _ProjectBarChartCardState();
}

class _ProjectBarChartCardState extends State<ProjectBarChartCard> {
  DateTime _selectedDate = DateTime.now();

  void _pickMonth() {
    final s = S.of(context);
    var tempYear = _selectedDate.year;
    var tempMonth = _selectedDate.month;

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
                      child: Text(
                        s.cancel,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = DateTime(tempYear, tempMonth);
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        s.day_off_donebtn,
                        style: const TextStyle(
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
                        scrollController: FixedExtentScrollController(
                          initialItem: tempYear - 2020,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          tempYear = 2020 + index;
                        },
                        children: List.generate(
                          20,
                          (index) => Center(
                            child: Text(
                              '${2020 + index}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: tempMonth - 1,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          tempMonth = index + 1;
                        },
                        children: List.generate(
                          12,
                          (index) => Center(
                            child: Text(
                              '${s.month} ${index + 1}',
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

  String _monthLabel(BuildContext context) =>
      '${S.of(context).month} ${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final data = [
      _Data('1', 90),
      _Data('2', 70),
      _Data('3', 85),
      _Data('4', 45),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            title: s.appraisal_project_adherence_percent,
            trailing: _monthLabel(context),
            onTapTrailing: _pickMonth,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 230,
            width: double.infinity,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
                interval: 20,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: const MajorGridLines(
                  dashArray: [3, 3],
                  color: Color(0xFFE5E7EB),
                ),
                labelStyle: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              series: [
                ColumnSeries<_Data, String>(
                  dataSource: data,
                  xValueMapper: (item, _) => item.name,
                  yValueMapper: (item, _) => item.value,
                  color: const Color(0xFF8B87FF),
                  width: 0.5,
                  spacing: 0.1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E87FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                s.appraisal_view_detail,
                style: const TextStyle(
                  color: Color(0xFF2E87FF),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Data {
  final String name;
  final double value;

  const _Data(this.name, this.value);
}

class _Header extends StatelessWidget {
  final String title;
  final String trailing;
  final VoidCallback onTapTrailing;

  const _Header({
    required this.title,
    required this.trailing,
    required this.onTapTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SvgPicture.asset(AppAssets.icStatics, width: 20, height: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTapTrailing,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                SvgPicture.asset(AppAssets.icCalendar, width: 14, height: 14),
                const SizedBox(width: 6),
                Text(
                  trailing,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
