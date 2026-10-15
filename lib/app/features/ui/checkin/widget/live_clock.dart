import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Đồng hồ HH:mm tự cập nhật đúng lúc sang phút mới (trước đây chỉ vẽ 1 lần khi mở màn).
class LiveClock extends StatefulWidget {
  final TextStyle? style;

  const LiveClock({super.key, this.style});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scheduleNextMinute();
  }

  void _scheduleNextMinute() {
    final now = DateTime.now();
    final nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    _timer = Timer(nextMinute.difference(now), () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _scheduleNextMinute();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('HH:mm').format(_now),
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}
