import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';

/// Bản tối (v2) của [DayCell] (`lib/app/features/ui/attendance/widget/day_cell.dart`).
///
/// Giữ NGUYÊN tham số/hành vi (date/code/dimmed/isSelected/onTap) và cùng
/// bảng mã trạng thái (`X`/`MS`/`C`/`CT`/`TR`/`TV`/`working_days`/`P`/`KL`/`NX`)
/// — chỉ đổi màu sang biến thể sáng hơn để đọc được trên nền tối (ô nền cũ
/// là trắng, ô v2 là `surfaceStrong`). Xem bảng mapping màu đầy đủ trong
/// `.superpowers/sdd/attendance-tabs-v2-report.md`.
class DayCellV2 extends StatelessWidget {
  final DateTime? date;
  final String? code; // "X" | "MS" | "C" | "CT" | ...
  final bool dimmed;
  final bool isSelected;
  final VoidCallback? onTap;

  const DayCellV2({
    super.key,
    this.date,
    this.code,
    this.dimmed = false,
    this.isSelected = false,
    this.onTap,
  });

  const DayCellV2.empty({super.key})
      : date = null,
        code = null,
        dimmed = true,
        isSelected = false,
        onTap = null;

  Color _textColor() {
    switch ((code ?? '').toUpperCase()) {
      case 'X':
        return const Color(0xFF3DDC6C); // Công đi làm (cũ #41B100)
      case 'MS':
        return const Color(0xFFF2A6E0); // đi muộn về sớm (cũ #D9A8CC)
      case 'C':
        return AppTokensV2.danger; // chưa chấm công (cũ #DA3535)
      case 'CT':
        return const Color(0xFF9CA3AF); // nghỉ cuối tuần (cũ #A5A5A9)

      case 'TR':
        return const Color(0xFF8B7CFF); // thiếu giờ ra (cũ #2C00CC)
      case 'TV':
        return const Color(0xFFE8A33D); // thiếu giờ vào (cũ #9F5D00)

      case 'working_days':
        return AppTokensV2.accent; // Công thực tế (cũ #0088FF)

      case 'P':
        return const Color(0xFFFFB020); // nghỉ phép (cũ #F49E00)

      case 'KL':
        return const Color(0xFFF23DDB); // nghỉ không lương (cũ #DC00C6)

      case 'NX':
        return const Color(0xFF00D3D6); // nửa ngày công (cũ #00D3D6, giữ nguyên)
      default:
        return AppTokensV2.fgMuted; // khác (cũ #232120 trên nền trắng)
    }
  }

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();

    final isToday = _sameDate(date!, DateTime.now());
    final color = _textColor();

    final BoxDecoration? bgDecoration = isSelected
        ? const BoxDecoration(
            color: Color(0xFF34D399),
            shape: BoxShape.circle,
          )
        : (isToday
            ? const BoxDecoration(
                color: AppTokensV2.accent,
                shape: BoxShape.circle,
              )
            : null);

    final String textDay = '${date!.day}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: const BoxDecoration(color: AppTokensV2.surfaceStrong),
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
                color: (isToday || isSelected)
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
