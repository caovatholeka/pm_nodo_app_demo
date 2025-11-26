import 'package:flutter/material.dart';

class WeekCell extends StatelessWidget {
  final String label;
  const WeekCell(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}