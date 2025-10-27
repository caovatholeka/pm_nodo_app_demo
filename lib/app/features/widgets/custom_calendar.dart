import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/enums/mark_day.dart';


class CustomCalendar extends StatefulWidget {
   CustomCalendar({
    super.key,
    required this.marks,
    DateTime? initialMonth,
    this.localeForHeader = 'en',
    this.onMonthChanged,
    this.onCallback
  }) : initialMonth = initialMonth ?? _nowMonth;

  final Map<String, Mark> marks;
  final DateTime initialMonth;
  final String localeForHeader;
  final ValueChanged<DateTime>? onMonthChanged;
   void Function(String date)? onCallback;

  static DateTime get _nowMonth => DateTime(DateTime.now().year, DateTime.now().month);


  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _month;


  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.initialMonth.year, widget.initialMonth.month);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _prevMonth() {
    setState(() => _month = DateTime(_month.year, _month.month - 1));
    widget.onMonthChanged?.call(_month);
  }

  void _nextMonth() {
    setState(() => _month = DateTime(_month.year, _month.month + 1));
    widget.onMonthChanged?.call(_month);
  }

  List<DateTime> _buildMonthDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    // weekday: Mon=1..Sun=7  => offset Mon-first: 0..6
    final int offset = (first.weekday + 6) % 7; // Mon->0, Sun->6
    final start = first.subtract(Duration(days: offset));
    return List.generate(42, (i) => DateTime(start.year, start.month, start.day + i));
  }

  @override
  Widget build(BuildContext context) {
    final headerFmt = DateFormat('MMMM / yyyy', widget.localeForHeader); // ví dụ "August / 2025"
    final days = _buildMonthDays(_month);

    String mon = widget.localeForHeader == "en" ? "Mon" : "T2";
    String tue = widget.localeForHeader == "en" ? "Tue" : "T3";
    String wed = widget.localeForHeader == "en" ? "Wed" : "T4";
    String thu = widget.localeForHeader == "en" ? "Thu" : "T5";
    String fri = widget.localeForHeader == "en" ? "Fri" : "T6";
    String sat = widget.localeForHeader == "en" ? "Sat" : "T7";
    String sun = widget.localeForHeader == "en" ? "Sun" : "CN";


    return Column(
      children: [
        // ---- Header month + arrows
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            children: [
              IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: Center(
                  child: Text(
                    headerFmt.format(_month),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // ---- Weekday header (Mon..Sun)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children:  [
              _WeekdayLabel(mon),
              _WeekdayLabel(tue),
              _WeekdayLabel(wed),
              _WeekdayLabel(thu),
              _WeekdayLabel(fri),
              _WeekdayLabel(sat),
              _WeekdayLabel(sun),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ---- Grid 6x7
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 42, // 6 weeks * 7 days
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final date = days[index];
                final inMonth = (date.month == _month.month);
                final key = DateFormat('yyyy-MM-dd').format(date);
                final mark = widget.marks[key];

                return _DayCell(
                  date: date,
                  inCurrentMonth: inMonth,
                  mark: mark,
                  onTap: (){
                    final s = DateFormat('dd/MM/yyyy').format(date);
                    widget.onCallback?.call(s);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.inCurrentMonth,
    this.mark,
    this.onTap,
  });

  final DateTime date;
  final bool inCurrentMonth;
  final Mark? mark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final day = date.day;
    final textColor = inCurrentMonth
        ? Colors.black
        : Colors.black.withValues(alpha: 0.35);

    final hasMark = mark != null;

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: date.isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)) ? null : onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: hasMark
              ? BoxDecoration(
            color: mark!.color,
            borderRadius: BorderRadius.circular(10), // bo tròn kiểu trong ảnh
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          )
              : null,
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: hasMark ? Colors.white : textColor,
            ),
          ),
        ),
      ),
    );
  }
}
