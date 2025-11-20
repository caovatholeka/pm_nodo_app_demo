import 'package:flutter/material.dart';

class InfoRowSpecial extends StatelessWidget {
  final String title;
  final String subtitlePrefix;
  final String subtitleValue;
  final bool showDivider;

  const InfoRowSpecial({
    super.key,
    required this.title,
    required this.subtitlePrefix,
    required this.subtitleValue,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: subtitlePrefix,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6F6F6F),
                ),
              ),
              TextSpan(
                text: subtitleValue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1976D2), 
                ),
              ),
            ],
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.black.withOpacity(0.06)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
