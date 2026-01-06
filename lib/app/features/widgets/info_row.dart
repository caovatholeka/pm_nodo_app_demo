import 'package:flutter/material.dart';
import 'package:pm_app/app/features/widgets/contact_action_text.dart';

class InfoRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool subtitleIsLink;
  final bool showDivider;
  bool? isClickable;
  String? type;

   InfoRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.subtitleIsLink = false,
    this.showDivider = true,
     this.isClickable = false,
     this.type
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: Color(0xFF9B9B9B))),
        SizedBox(height: 1),
        (isClickable ?? false) ?
        ContactActionText(
            value: subtitle,
            type: type == "phone" ?  ContactType.phone : ContactType.email)
        : Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: subtitleIsLink ? Color.fromARGB(255, 0, 128, 255) : Color(0xFF222222),
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
