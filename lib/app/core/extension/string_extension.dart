import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  DateTime? toDate(String format) {
    try {
      final date = DateFormat(format).parse(this);
      return date;
    } catch (e) {
      return null;
    }
  }
}

extension YmdRange on DateTimeRange {
  String toYmdLabel() =>
      '${DateFormat('dd/MM/yyyy').format(start)} - ${DateFormat('dd/MM/yyyy').format(end)}';
}