import 'package:flutter/material.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';

import 'day_cell.dart';
import 'week_cell.dart';

class MonthView extends StatelessWidget {
  final DateTime month; // first day of month
  final Map<DateTime, String> dayDisplay;
  final Map<DateTime, List<WorkEntity>> entriesByDate;
  final bool loading;
  final String? error;
  final ValueChanged<DateTime>? onTapDay;
  final DateTime? selectedDate;

  const MonthView({
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
    final first = DateTime(month.year, month.month, 1);
    // CN là cột đầu tiên → offset = Sun=0, Mon=1..Sat=6
    final offset = first.weekday % 7; // Mon=1..Sun=0
    final firstOfGrid = first.subtract(Duration(days: offset));
    // Lưới cố định 6 hàng × 7 cột = 42
    const totalCells = 42;

    return Column(
      children: [
        // header weekdays: CN T2..T7
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          child: Row(
            children: const [
              WeekCell('CN'), WeekCell('T2'), WeekCell('T3'),
              WeekCell('T4'), WeekCell('T5'), WeekCell('T6'), WeekCell('T7'),
            ],
          ),
        ),
        if (loading) const LinearProgressIndicator(minHeight: 2),
        if (error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(error!, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(
          child: GridView.builder(
            // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              final code = dayDisplay[DateTime(date.year, date.month, date.day)] ?? '';
              final isSelected = selectedDate != null &&
                  date.year == selectedDate!.year &&
                  date.month == selectedDate!.month &&
                  date.day == selectedDate!.day;
              return DayCell(date: date, code: code, dimmed: !isCurrentMonth,
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
