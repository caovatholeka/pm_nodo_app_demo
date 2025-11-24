import 'package:flutter/material.dart';

class DayCell extends StatelessWidget {
  final DateTime? date;
  final String? code; // "X" | "MS" | "C" | "CT" | ""
  final bool dimmed;
  final bool isSelected;
  final VoidCallback? onTap;

  const DayCell({this.date, this.code, this.dimmed = false,
    this.isSelected = false, this.onTap});

  const DayCell.empty()
      : date = null, code = null, dimmed = true,isSelected = false, onTap = null;

  Color _textColor() {
    switch ((code ?? '').toUpperCase()) {
      case 'X':case 'working_days':  return Color(0xFF41B100); // đúng giờ
      case 'MS': return Color(0xFFF69212); // đi muộn về sớm
      case 'C':  return Color(0xFFDA3535); // không chấm công
      case 'CT': return Color(0xFF71717A); // cuối tuần
      default:   return Color(0xFF232120); // khác : nghỉ phép, nghỉ không lương, thiếu giờ vào/ra
    }
  }

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();

    final isToday = _sameDate(date!, DateTime.now());
    final color = _textColor();

    final bgDecoration = isSelected
        ? BoxDecoration(
      color: Colors.blue,
      shape: BoxShape.circle,
    )
        : (isToday
        ? const BoxDecoration(
        color: Colors.green, shape: BoxShape.circle)
        : null);

    String textDay = '${date!.day}';
    if((code ?? "") == "MS" || (code ?? "") == "C"){
      textDay = '${date!.day}';
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: Container(
            // today
            padding: const EdgeInsets.all(8),
            decoration: bgDecoration,
            child: Text(
              textDay,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isToday
                    ? Colors.white
                    : color.withOpacity(dimmed ? 0.35 : 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}