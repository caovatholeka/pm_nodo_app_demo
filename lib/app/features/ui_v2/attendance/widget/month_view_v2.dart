import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';
import 'package:pm_app/generated/l10n.dart';

import 'day_cell_v2.dart';
import 'week_cell_v2.dart';

/// Bản tối (v2) của [MonthView] (`lib/app/features/ui/attendance/widget/month_view.dart`).
/// Cùng tham số, cùng bố cục lưới 6x7 — chỉ đổi màu.
class MonthViewV2 extends StatelessWidget {
  final DateTime month; // first day of month
  final Map<DateTime, String> dayDisplay;
  final Map<DateTime, List<WorkEntity>> entriesByDate;
  final bool loading;
  final String? error;
  final ValueChanged<DateTime>? onTapDay;
  final DateTime? selectedDate;

  const MonthViewV2({
    super.key,
    required this.month,
    required this.dayDisplay,
    required this.entriesByDate,
    required this.loading,
    required this.error,
    this.onTapDay,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final first = DateTime(month.year, month.month, 1);
    final int offset = first.weekday - 1;

    final firstOfGrid = first.subtract(Duration(days: offset));
    // Lưới cố định 6 hàng × 7 cột = 42
    const totalCells = 42;

    return Column(
      children: [
        // header weekdays: CN T2..T7
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          child: Row(
            children: [
              WeekCellV2(s.weekday_mon),
              WeekCellV2(s.weekday_tue),
              WeekCellV2(s.weekday_wed),
              WeekCellV2(s.weekday_thu),
              WeekCellV2(s.weekday_fri),
              WeekCellV2(s.weekday_sat),
              WeekCellV2(s.weekday_sun),
            ],
          ),
        ),

        if (loading)
          const LinearProgressIndicator(
            minHeight: 2,
            color: AppTokensV2.accent,
            backgroundColor: AppTokensV2.surfaceStrong,
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(error!, style: const TextStyle(color: AppTokensV2.danger)),
          ),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: totalCells,
            itemBuilder: (ctx, i) {
              final date = firstOfGrid.add(Duration(days: i));
              final isCurrentMonth =
                  (date.year == month.year && date.month == month.month);
              final code =
                  dayDisplay[DateTime(date.year, date.month, date.day)] ?? '';
              final isSelected = selectedDate != null &&
                  date.year == selectedDate!.year &&
                  date.month == selectedDate!.month &&
                  date.day == selectedDate!.day;
              return DayCellV2(
                date: date,
                code: code,
                dimmed: !isCurrentMonth,
                isSelected: isSelected,
                onTap: () => onTapDay?.call(date),
              );
            },
          ),
        ),
      ],
    );
  }
}
