import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/activity_item.dart';
import 'package:pm_app/app/features/widgets/attendance_card.dart' as attendance;
import 'package:pm_app/app/features/widgets/leave_balance_card.dart' as leave;
import 'package:pm_app/app/features/widgets/legend_item.dart' as legend;
import 'package:pm_app/app/features/widgets/development_alert_dialog.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

class AttendanceDataPage extends StatefulWidget {
  const AttendanceDataPage({super.key});

  @override
  State<AttendanceDataPage> createState() => _AttendanceDataPageState();
}

class _AttendanceDataPageState extends State<AttendanceDataPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isMonth = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedMonth = "Tháng 11";
  String _selectedYear = "2025";

  final List<String> months = List.generate(12, (i) => "Tháng ${i + 1}");
  final List<String> years = List.generate(6, (i) => (2023 + i).toString());
  final TextEditingController _reasonController = TextEditingController();
  bool _isReasonFilled = false;

  final Map<DateTime, Color> _dayColors = {
    DateTime(2025, 11, 1): Colors.green,
    DateTime(2025, 11, 2): Colors.red,
    DateTime(2025, 11, 3): Colors.orange,
    DateTime(2025, 11, 4): Colors.green,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;

    _reasonController.addListener(() {
      setState(() {
        _isReasonFilled = _reasonController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        titleAppbar: "Dữ liệu chấm công",
        haveBackButton: true,
        haveActionButton: true,
        iconPathAsset: AppAssets.ic_bell,
        actionCallBack: () => DevelopmentAlertDialog.show(context),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.imgBg2,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: TabBar(
                    controller: _tabController,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3, color: Colors.white),
                      insets: EdgeInsets.symmetric(horizontal: 32.0),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    tabs: const [
                      Tab(text: "Dữ liệu chấm công"),
                      Tab(text: "Giải trình công"),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: AppShadow.pageBoxShadow,
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAttendanceTab(),
                        _buildExplanationTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 1 =================
  Widget _buildAttendanceTab() {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
        Expanded(
          child: _buildDropdown(years, _selectedYear, (val) {
            setState(() => _selectedYear = val!);
          }),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(months, _selectedMonth, (val) {
            setState(() => _selectedMonth = val!);
          }),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) {
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
          items: items
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
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
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: const BoxDecoration(
            color: AppColors.colorPrimary50, shape: BoxShape.circle),
        selectedDecoration:
            const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
        defaultTextStyle: const TextStyle(color: Colors.black87),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final color = _dayColors[DateTime(day.year, day.month, day.day)];
          return Center(
            child: Text(
              "${day.day}",
              style: TextStyle(
                color: color ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
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
        Text("Xem tất cả",
            style: TextStyle(color: AppColors.subtitle)),
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

  Widget _buildExplanationTab() {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadOnlyField("Nhân viên", "Trần Nam Thắng"),
        const SizedBox(height: 10),
        _buildReadOnlyField("Phòng ban", "TTS Mobile :) "),
        const SizedBox(height: 10),
        _buildReadOnlyField("Giờ đến", "08:30"),
        const SizedBox(height: 10),
        _buildReadOnlyField("Giờ về", "18:00"),
        const SizedBox(height: 10),
        const Text.rich(
          TextSpan(
            text: "Lý do ",
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 15),
            children: [
              TextSpan(
                text: "*",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Nhập lý do nghỉ",
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.colorPrimary50,
                width: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          mainText: "Xác nhận",
          enable: _isReasonFilled,
          callback: () {
            if (_isReasonFilled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Đã gửi giải trình thành công!"),
                ),
              );
            }
          },
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          borderRadius: 10,
        ),
      ],
    ),
  );
}


  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 15)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style:
                const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
