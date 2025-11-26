import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';

class DayCell extends StatelessWidget {
  final DateTime? date;
  final String? code; // "X" | "MS" | "C" | "CT" | ""
  final bool dimmed;
  final bool isSelected;
  final VoidCallback? onTap;

  const DayCell({super.key, 
    this.date,
    this.code,
    this.dimmed = false,
    this.isSelected = false,
    this.onTap,
  });

  const DayCell.empty({super.key})
      : date = null,
        code = null,
        dimmed = true,
        isSelected = false,
        onTap = null;

  Color _textColor() {
    switch ((code ?? '').toUpperCase()) {
      case 'X':
        return const Color(0xFF41B100); // Công đi làm
      case 'MS':
        return const Color(0xFFD9A8CC); // đi muộn về sớm
      case 'C':
        return const Color(0xFFDA3535); // chưa chấm công
      case 'CT':
        return const Color(0xFFA5A5A9); // nghỉ cuối tuần

      case 'TR':
        return const Color(0xFf2C00CC); // thiếu giờ ra
      case 'TV':
        return const Color(0xFF9F5D00); // thiếu giờ vào

      case 'working_days':
        return const Color(0xFF0088FF); // Công thực tế

      case 'P':
        return const Color(0xFFF49E00); // nghỉ phép

      case 'KL':
        return const Color(0xFFDC00C6); // nghỉ không lương

      case 'NX':
        return const Color(0xFF00D3D6); // nửa ngày công
      default:
        return const Color(0xFF232120); // khác
    }
  }

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();

    final isToday = _sameDate(date!, DateTime.now());
    final color = _textColor();

    final BoxDecoration? bgDecoration = isSelected
        ? const BoxDecoration(
      color: Color(0xFF5AC60D),
      shape: BoxShape.circle,
    )
        : (isToday
        ? const BoxDecoration(
      color: AppColors.themePrimaryDefault,
      shape: BoxShape.circle,
    )
        : null);

    String textDay = '${date!.day}';
    if ((code ?? "") == "MS" || (code ?? "") == "C") {
      textDay = '${date!.day}';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: bgDecoration,
            child: Text(
              textDay,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: (isToday)
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