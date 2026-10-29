import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pm_app/generated/l10n.dart';

import '../bloc/app_cubit.dart';

class CalendarWeekSheet extends StatefulWidget {
  const CalendarWeekSheet({super.key, required this.initial});
  final DateTimeRange initial;

  @override
  State<CalendarWeekSheet> createState() => _CalendarWeekSheetState();
}

class _CalendarWeekSheetState extends State<CalendarWeekSheet> {
  late DateTime _focusedDay;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  final _appCubit = GetIt.I.get<AppCubit>();

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initial.start;
    _rangeStart = _mondayOf(_focusedDay);
    _rangeEnd = _rangeStart.add(const Duration(days: 6));
  }

  static DateTime _mondayOf(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    final delta = x.weekday - 1;
    return x.subtract(Duration(days: delta));
  }

  void _selectWeek(DateTime day) {
    final start = _mondayOf(day);
    final end = start.add(const Duration(days: 6));
    setState(() {
      _focusedDay = day;
      _rangeStart = start;
      _rangeEnd = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 12, right: 12, top: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                '${df.format(_rangeStart)} - ${df.format(_rangeEnd)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            TableCalendar(
              locale: _appCubit.state.locale?.languageCode ?? "en",
              firstDay: DateTime(2015),
              lastDay: DateTime(2035),
              focusedDay: _focusedDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,

              selectedDayPredicate: (_) => false,
              // onDaySelected: (selectedDay, focusedDay) => _selectWeek(selectedDay),
              onDaySelected: (selectedDay, focusedDay){
                _selectWeek(selectedDay);
                Navigator.pop<DateTimeRange>(
                  context,
                  DateTimeRange(start: _rangeStart, end: _rangeEnd),
                );
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(fontWeight: FontWeight.w700),
                weekdayStyle: TextStyle(fontWeight: FontWeight.w700),
              ),
              calendarStyle: CalendarStyle(

                todayDecoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
                todayTextStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.w800),

                rangeHighlightColor: const Color(0xFFE9F3FF),
                withinRangeTextStyle: const TextStyle(color: Colors.black87),

                rangeStartDecoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                rangeEndDecoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                rangeStartTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                rangeEndTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                // Cells
                defaultTextStyle: const TextStyle(fontWeight: FontWeight.w600),
                weekendTextStyle: const TextStyle(fontWeight: FontWeight.w600),
                outsideDaysVisible: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).cancel),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    Navigator.pop<DateTimeRange>(
                      context,
                      DateTimeRange(start: _rangeStart, end: _rangeEnd),
                    );
                  },
                  child: Text(S.of(context).employee_advanced_apply),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
