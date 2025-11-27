import 'package:flutter/material.dart';

class LegendItem extends StatelessWidget {
  const LegendItem({
    super.key,
    this.iconPath,
    required this.label,
    required this.color
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
            border: Border.all(
              color: color,
              width: 3
            )
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13
          ),
        ),
      ],
    );
  }
}