import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';

class InfoRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showDivider;
  final bool subtitleIsLink;

  const InfoRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.showDivider = true,
    this.subtitleIsLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.subtitle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.themeBlackDefault,
          ),
        ),

        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),
          const SizedBox(height: 12),
        ]
      ],
    );
  }
}
