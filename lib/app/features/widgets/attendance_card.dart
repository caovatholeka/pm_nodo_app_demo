import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    super.key,
    required this.date,
    required this.status,
    required this.timerage,
    required this.iconPath,
  });

  final String date;
  final String status;
  final String timerage;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadow.boxShadowNormal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(iconPath, width: 10, height: 10),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.themeBlackDefault,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.themeBlackDefault,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "",//'Chấm công vào/ra: $timerage',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subtitle,
            ),
          ),
        ],
      ),
    );
  }
}
