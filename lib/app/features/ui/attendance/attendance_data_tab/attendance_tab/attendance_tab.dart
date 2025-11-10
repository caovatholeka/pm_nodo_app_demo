import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/widgets/activity_item.dart';
import 'package:pm_app/app/features/widgets/attendance_card.dart' as attendance;
import 'package:pm_app/app/features/widgets/leave_balance_card.dart' as leave;
import 'package:pm_app/app/features/widgets/legend_item.dart' as legend;

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  bool isMonth = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedMonth = "Tháng 11";
  String _selectedYear = "2025";

  final List<String> months = List.generate(12, (i) => "Tháng ${i + 1}");
  final List<String> years = List.generate(6, (i) => (2023 + i).toString());

  final Map<DateTime, Color> _dayColors = {
    DateTime(2025, 11, 1): Colors.green,
    DateTime(2025, 11, 2): Colors.red,
    DateTime(2025, 11, 3): Colors.orange,
    DateTime(2025, 11, 4): Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          attendance.AttendanceCard(
            date: "Hôm nay, 4/11/2025",
            status: "Đúng giờ",
            timerage: "08:50 - 18:00",
            iconPath: AppAssets.ic_roundG,
          ),
          const SizedBox(height: 12),
          leave.LeaveBalanceCard(remainingDays: 19),
          const SizedBox(height: 12),
          _buildViewSwitchButtons(),
          const SizedBox(height: 10),
          _buildYearMonthDropdown(),
          const SizedBox(height: 8),
          _buildCalendar(),
          const SizedBox(height: 12),
          _buildLegend(),
          const SizedBox(height: 24),
          _buildActivityHeader(),
          const SizedBox(height: 12),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildViewSwitchButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => isMonth = false),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  !isMonth ? const Color.fromARGB(255, 0, 98, 255) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: AppColors.colorPrimary50),
            ),
            child: Text(
              "Tuần",
              style: TextStyle(
                color: !isMonth ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => isMonth = true),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  isMonth ? const Color.fromARGB(255, 6, 101, 255) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: AppColors.colorPrimary50),
            ),
            child: Text(
              "Tháng",
              style: TextStyle(
                color: isMonth ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearMonthDropdown() {
    return Row(
      children: [
        Expanded(child: _buildDropdown(years, _selectedYear, (val) => setState(() => _selectedYear = val!))),
        const SizedBox(width: 8),
        Expanded(child: _buildDropdown(months, _selectedMonth, (val) => setState(() => _selectedMonth = val!))),
      ],
    );
  }

  Widget _buildDropdown(List<String> items, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) => setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      }),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(color: AppColors.colorPrimary50, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final color = _dayColors[DateTime(day.year, day.month, day.day)];
          return Center(
            child: Text("${day.day}",
                style: TextStyle(color: color ?? Colors.black87, fontWeight: FontWeight.w500)),
          );
        },
      ),
      headerVisible: false,
      daysOfWeekHeight: 30,
      rowHeight: 42,
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        legend.LegendItem(iconPath: AppAssets.ic_roundG, label: "Đúng giờ"),
        legend.LegendItem(iconPath: AppAssets.ic_roundO, label: "Đi muộn / Về sớm"),
        legend.LegendItem(iconPath: AppAssets.ic_roundR, label: "Không chấm công"),
      ],
    );
  }

  Widget _buildActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("Hoạt động",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.themeBlackDefault)),
        Text("Xem tất cả", style: TextStyle(color: AppColors.subtitle)),
      ],
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: [
        ActivityItem(
          icon: AppAssets.icCheckin,
          title: "Check In",
          time: "08:50",
          subtitle: "Thứ 3, 4/11/2025",
          status: "Đúng giờ",
        ),
        ActivityItem(
          icon: AppAssets.launchBreak,
          title: "Nghỉ trưa",
          time: "12:00",
          subtitle: "Thứ 3, 4/11/2025",
          status: "Đúng giờ",
        ),
        ActivityItem(
          icon: AppAssets.icCheckout,
          title: "Check Out",
          time: "18:00",
          subtitle: "Thứ 3, 4/11/2025",
          status: "Đúng giờ",
        ),
      ],
    );
  }
}
