import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/generated/l10n.dart';

class SummaryRatingCard extends StatefulWidget {
  final VoidCallback? onTap;

  const SummaryRatingCard({
    super.key,
    this.onTap,
  });

  @override
  State<SummaryRatingCard> createState() => _SummaryRatingCardState();
}

class _SummaryRatingCardState extends State<SummaryRatingCard> {
  DateTime _selectedDate = DateTime.now();

  static const List<Color> _metricColors = [
    Color(0xFF7B8CF4),
    Color(0xFFFFAF4D),
    Color(0xFF35D4EF),
  ];

  String _monthLabel(BuildContext context) =>
      '${S.of(context).month} ${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

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
    final s = S.of(context);
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
                      child: Text(
                        s.cancel,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                              '${s.month} ${(i + 1).toString().padLeft(2, '0')}',
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

  List<Metric> _buildMetrics(DashboardState state, S s) {
    final workQuality = state.workQuality;
    return [
      Metric(s.appraisal_metric_volume, workQuality?.volumeScore ?? 0),
      Metric(s.appraisal_metric_progress, workQuality?.progressScore ?? 0),
      Metric(s.appraisal_metric_quality, workQuality?.qualityScore ?? 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final data = _buildMetrics(state, s);

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
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
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF6FF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppAssets.icCheckBlue,
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF1778FF),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.appraisal_work_quality_title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _pickMonth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE7EBF2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppAssets.icCalendar,
                              width: 13,
                              height: 13,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF222B36),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _monthLabel(context),
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 1),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 17,
                              color: Color(0xFF222B36),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (state.workQualityStatus == LoadStatus.LOADING)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 44),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4B7BFF),
                      ),
                    ),
                  )
                else if (state.workQualityStatus == LoadStatus.FAILURE)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        s.appraisal_load_failed,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else
                  _MetricChart(
                    data: data,
                    colors: _metricColors,
                  ),
              ],
            ),
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

class _MetricChart extends StatelessWidget {
  final List<Metric> data;
  final List<Color> colors;

  const _MetricChart({
    required this.data,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(left: 2, right: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AxisLabel('0'),
                _AxisLabel('20'),
                _AxisLabel('40'),
                _AxisLabel('60'),
                _AxisLabel('80'),
                _AxisLabel('100'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        ...List.generate(
          data.length.clamp(0, 3),
          (index) => SizedBox(
            width: double.infinity,
            child: _MetricBar(
              item: data[index],
              color: colors[index],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendDot(color: const Color(0xFF7B88E8), label: s.appraisal_metric_volume),
              _LegendDot(color: const Color(0xFFF4A640), label: s.appraisal_metric_progress),
              _LegendDot(color: const Color(0xFF35C3D9), label: s.appraisal_metric_quality),
            ],
          ),
        ),
      ],
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String text;

  const _AxisLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: Color(0xFF5B616B),
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final Metric item;
  final Color color;

  const _MetricBar({
    required this.item,
    required this.color,
  });

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
                  child: Container(color: color),
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

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
