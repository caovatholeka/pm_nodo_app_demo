import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Bản tối (v2) của [ActivityItem] — 1 dòng lịch sử check-in/check-out.
class ActivityItemV2 extends StatelessWidget {
  ActivityItemV2({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    required this.subtitle,
    this.place,
    required this.status,
  });

  final String icon;
  final String title;
  final String time;
  final String subtitle;
  String? place;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTokensV2.surfaceStrong,
        border: Border.all(color: AppTokensV2.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            icon,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTokensV2.fg,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTokensV2.fgMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${S.of(context).work_data_location}: ${place ?? ""}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTokensV2.fgMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTokensV2.fg,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTokensV2.fgMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
