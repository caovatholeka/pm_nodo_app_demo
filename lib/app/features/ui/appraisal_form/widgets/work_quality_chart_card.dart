import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';

class WorkQualityChartCard extends StatefulWidget {
  final DateTime? initialDate;
  final List<WorkQualityMetricBarData> bars;
  final ValueChanged<DateTime>? onMonthChanged;

  const WorkQualityChartCard({
    super.key,
    required this.initialDate,
    required this.bars,
    this.onMonthChanged,
  });

  @override
  State<WorkQualityChartCard> createState() => _WorkQualityChartCardState();
}

class _WorkQualityChartCardState extends State<WorkQualityChartCard> {
  late DateTime _selectedDate;

  String get _monthLabel => 'Tháng ${DateFormat('MM/yyyy').format(_selectedDate)}';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant WorkQualityChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      _selectedDate = widget.initialDate ?? _selectedDate;
    }
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
                        widget.onMonthChanged?.call(nextDate);
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
                              style: const TextStyle(fontSize: 16),
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
                              (i + 1).toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 16),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _pickMonth,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ScaleText('0'),
                  _ScaleText('20'),
                  _ScaleText('40'),
                  _ScaleText('60'),
                  _ScaleText('80'),
                  _ScaleText('100'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...widget.bars.map(
            (item) => SizedBox(
              width: double.infinity,
              child: _MetricBar(item: item),
            ),
          ),
          const SizedBox(height: 18),
          const SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _LegendDot(color: Color(0xFF7B88E8), label: 'Khối lượng CV'),
                _LegendDot(color: Color(0xFFF4A640), label: 'Tiến độ CV'),
                _LegendDot(color: Color(0xFF35C3D9), label: 'Chất lượng CV'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleText extends StatelessWidget {
  final String text;

  const _ScaleText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: Color(0xFF4F4F4F),
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final WorkQualityMetricBarData item;

  const _MetricBar({required this.item});

  @override
  Widget build(BuildContext context) {
    const barHeight = 42.0;
    final barValue = item.value.clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: barHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFF2F4FF),
                  ),
                ),
                for (final fraction in [0.2, 0.4, 0.6, 0.8, 1.0])
                  Positioned(
                    left: constraints.maxWidth * fraction - 0.5,
                    top: 0,
                    bottom: 0,
                    child: CustomPaint(
                      size: const Size(1, barHeight),
                      painter: _DashedLinePainter(),
                    ),
                  ),
                FractionallySizedBox(
                  widthFactor: barValue / 100,
                  heightFactor: 1,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: item.color.withValues(alpha: 0.96),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        barValue.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666B75),
          ),
        ),
      ],
    );
  }
}

class WorkQualityMetricBarData {
  final double value;
  final Color color;

  const WorkQualityMetricBarData({
    required this.value,
    required this.color,
  });
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 3.0;
    const dashSpace = 3.0;
    final paint = Paint()
      ..color = const Color(0xFFC9CED8)
      ..strokeWidth = 1;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
