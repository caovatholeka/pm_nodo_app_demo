import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool subtitleIsLink;
  final bool showDivider;

  const InfoRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.subtitleIsLink = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: Color(0xFF9B9B9B))),
        SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: subtitleIsLink ? Color(0xFF1976D2) : Color(0xFF222222),
          ),
        ),
        if (showDivider) ...[
          SizedBox(height: 12),
          Divider(height: 1, color: Colors.black12),
          SizedBox(height: 12),
        ] else ...[
          SizedBox(height: 12),
        ]
      ],
    );
  }
}
