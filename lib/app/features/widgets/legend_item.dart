import 'package:flutter/material.dart';

class LegendItem extends StatelessWidget {
  const LegendItem({
    super.key,
    required this.iconPath,
    required this.label,
  });

  final String iconPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}