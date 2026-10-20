import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';

/// Bản tối (v2) của [LegendItem] — 1 dòng chú giải màu trạng thái chấm công.
class LegendItemV2 extends StatelessWidget {
  const LegendItemV2({
    super.key,
    this.iconPath,
    required this.label,
    required this.color,
  });

  final String? iconPath;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: AppTokensV2.fgSoft),
        ),
      ],
    );
  }
}
