import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';
import 'package:pm_app/generated/l10n.dart';
import '../../core/commons/app_colors.dart';

class ActivityItem extends StatelessWidget {
   ActivityItem({
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadow.boxShadowNormal,
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
                    color: AppColors.themeBlackDefault,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${S.of(context).work_data_location}: ${place ?? ""}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
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
                  color: AppColors.themeBlackDefault,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subtitle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
