import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/commons/app_colors.dart';
import '../../core/commons/screen_size.dart';

class CalendarRangeSheet extends StatefulWidget {
  const CalendarRangeSheet({
    super.key,
    required this.initial,
    required this.locale,
  });

  final DateTimeRange initial;
  final String locale;

  @override
  State<CalendarRangeSheet> createState() => _CalendarRangeSheetState();
}

class _CalendarRangeSheetState extends State<CalendarRangeSheet> {
  late DateTime _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initial.start;
    _rangeStart = DateTime(widget.initial.start.year, widget.initial.start.month, widget.initial.start.day);
    _rangeEnd = DateTime(widget.initial.end.year, widget.initial.end.month, widget.initial.end.day);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _rangeStart = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      _rangeEnd = _rangeStart;
    });
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _rangeStart = start != null ? DateTime(start.year, start.month, start.day) : null;
      _rangeEnd = end != null ? DateTime(end.year, end.month, end.day) : null;
      if (_rangeStart != null && _rangeEnd == null) _rangeEnd = _rangeStart;
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + offset, 1);
    });
  }

  void _clearRange() {
    setState(() {
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final df = DateFormat('dd/MM/yyyy');
    final label = (_rangeStart != null && _rangeEnd != null)
        ? '${df.format(_rangeStart!)} - ${df.format(_rangeEnd!)}'
        : s.calendar_title;

    final monthLabel = DateFormat('MMMM yyyy', widget.locale).format(_focusedDay);

    return Container(
      height: ScreenSize.of(context).height * 0.65,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.black, size: 24),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),

          const SizedBox(height: 4),
          SizedBox(
            height: ScreenSize.of(context).height * 0.4,
            child: TableCalendar(
              locale: widget.locale,
              firstDay: DateTime(2015),
              lastDay: DateTime(2035),
              focusedDay: _focusedDay,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              selectedDayPredicate: (_) => false,
              onDaySelected: _onDaySelected,
              onRangeSelected: _onRangeSelected,
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              headerVisible: false,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(fontWeight: FontWeight.w700),
                weekdayStyle: TextStyle(fontWeight: FontWeight.w700),
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: Colors.transparent),
                todayTextStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                rangeHighlightColor: Color(0xFFE9F3FF),
                withinRangeTextStyle: TextStyle(color: Colors.black87),
                rangeStartDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                rangeEndDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                rangeStartTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                rangeEndTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                defaultTextStyle: TextStyle(fontWeight: FontWeight.w600),
                weekendTextStyle: TextStyle(fontWeight: FontWeight.w600),
                outsideDaysVisible: true,
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _clearRange();
                      Navigator.pop(context, null); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      s.day_off_btn_delete,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: AppColors.themeBlackDefault,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_rangeStart != null && _rangeEnd != null)
                        ? () {
                            Navigator.pop(context, DateTimeRange(start: _rangeStart!, end: _rangeEnd!));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.themePrimaryDefault,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      s.confirm,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
