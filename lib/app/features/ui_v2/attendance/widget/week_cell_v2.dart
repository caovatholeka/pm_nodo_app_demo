import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';

/// Bản tối (v2) của [WeekCell] — nhãn thứ trong tuần (CN/T2../T7) ở đầu lịch tháng.
class WeekCellV2 extends StatelessWidget {
  final String label;
  const WeekCellV2(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTokensV2.fgSoft,
          ),
        ),
      ),
    );
  }
}
