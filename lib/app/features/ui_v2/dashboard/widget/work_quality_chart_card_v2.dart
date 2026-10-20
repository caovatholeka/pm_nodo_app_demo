import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Bản v2 (dark) của `WorkQualityChartCard`
/// (lib/app/features/ui/dashboard/widgets/work_quality_chart_card.dart).
/// Cùng contract dữ liệu/callback (chọn tháng+năm, danh sách thanh điểm).
class WorkQualityChartCardV2 extends StatefulWidget {
  final DateTime? initialDate;
  final List<WorkQualityMetricBarDataV2> bars;
  final ValueChanged<DateTime>? onMonthChanged;

  const WorkQualityChartCardV2({
    super.key,
    required this.initialDate,
    required this.bars,
    this.onMonthChanged,
  });

  @override
  State<WorkQualityChartCardV2> createState() =>
      _WorkQualityChartCardV2State();
}

class _WorkQualityChartCardV2State extends State<WorkQualityChartCardV2> {
  late DateTime _selectedDate;

  String _monthLabel(BuildContext context) =>
      '${S.of(context).month} ${DateFormat('MM/yyyy').format(_selectedDate)}';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant WorkQualityChartCardV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      _selectedDate = widget.initialDate ?? _selectedDate;
    }
  }

  void _pickMonth() {
    final s = S.of(context);
    int tempYear = _selectedDate.year;
    int tempMonth = _selectedDate.month;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTokensV2.bgTop,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetContext),
                      child: Text(
                        s.cancel,
                        style: AppTokensV2.body
                            .copyWith(color: AppTokensV2.fgMuted),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final nextDate = DateTime(tempYear, tempMonth);
                        setState(() {
                          _selectedDate = nextDate;
                        });
                        widget.onMonthChanged?.call(nextDate);
                        Navigator.pop(sheetContext);
                      },
                      child: Text(
                        s.day_off_donebtn,
                        style: TextStyle(
                          color: AppTokensV2.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.dark),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          backgroundColor: Colors.transparent,
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
                                style: AppTokensV2.body.copyWith(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          backgroundColor: Colors.transparent,
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
                                style: AppTokensV2.body.copyWith(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _pickMonth,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              border: Border.all(color: AppTokensV2.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14, color: AppTokensV2.fgMuted),
                const SizedBox(width: 8),
                Text(_monthLabel(context), style: AppTokensV2.body),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: AppTokensV2.fgMuted),
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
                _ScaleTextV2('0'),
                _ScaleTextV2('20'),
                _ScaleTextV2('40'),
                _ScaleTextV2('60'),
                _ScaleTextV2('80'),
                _ScaleTextV2('100'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...widget.bars.map(
          (item) => SizedBox(
            width: double.infinity,
            child: _MetricBarV2(item: item),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _LegendDotV2(
                color: const Color(0xFF7B88E8),
                label: s.appraisal_metric_volume,
              ),
              _LegendDotV2(
                color: const Color(0xFFF4A640),
                label: s.appraisal_metric_progress,
              ),
              _LegendDotV2(
                color: const Color(0xFF35C3D9),
                label: s.appraisal_metric_quality,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScaleTextV2 extends StatelessWidget {
  final String text;

  const _ScaleTextV2(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTokensV2.caption);
  }
}

class _MetricBarV2 extends StatelessWidget {
  final WorkQualityMetricBarDataV2 item;

  const _MetricBarV2({required this.item});

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
                    color: AppTokensV2.surface,
                  ),
                ),
                for (final fraction in [0.2, 0.4, 0.6, 0.8, 1.0])
                  Positioned(
                    left: constraints.maxWidth * fraction - 0.5,
                    top: 0,
                    bottom: 0,
                    child: CustomPaint(
                      size: const Size(1, barHeight),
                      painter: _DashedLinePainterV2(),
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
                        style: AppTokensV2.body.copyWith(fontSize: 13.5),
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

class _LegendDotV2 extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDotV2({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTokensV2.caption),
      ],
    );
  }
}

class WorkQualityMetricBarDataV2 {
  final double value;
  final Color color;

  const WorkQualityMetricBarDataV2({
    required this.value,
    required this.color,
  });
}

class _DashedLinePainterV2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 3.0;
    const dashSpace = 3.0;
    final paint = Paint()
      ..color = AppTokensV2.border
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
