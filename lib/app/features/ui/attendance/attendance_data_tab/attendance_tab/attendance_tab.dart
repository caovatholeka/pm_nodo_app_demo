import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/commons/screen_size.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/utils/utils.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_cubit.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/widgets/activity_item.dart';
import 'package:pm_app/app/features/widgets/attendance_card.dart' as attendance;
import 'package:pm_app/app/features/widgets/leave_balance_card.dart' as leave;
import 'package:pm_app/app/features/widgets/legend_item.dart' as legend;

import '../../widget/month_view.dart';

class AttendanceTab extends StatefulWidget {
  AttendanceDataCubit cubit;
  AttendanceTab({super.key, required this.cubit});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  bool isMonth = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedMonth = "Tháng 11";
  String _selectedYear = "2025";

  final List<String> months = List.generate(12, (i) => "${i + 1}");
  final List<String> years = List.generate(6, (i) => (2023 + i).toString());

  final Map<DateTime, Color> _dayColors = {
    DateTime(2025, 11, 1): Colors.green,
    DateTime(2025, 11, 2): Colors.red,
    DateTime(2025, 11, 3): Colors.orange,
    DateTime(2025, 11, 4): Colors.green,
  };

  // swipe calendar
  double _dragDx = 0;

  @override
  void initState() {
    // get list attendance
    widget.cubit.setYearMonth(DateTime.now().year, DateTime.now().month-1);
    widget.cubit.getListAttendances(DateTime(DateTime.now().year,DateTime.now().month-1));  //DateTime.now()
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Helpers func
  String todayFormatted({Locale? locale, DateTime? now}) {
    final DateTime d = now ?? DateTime.now();
    final String lang = (locale?.languageCode ?? 'en').toLowerCase();
    final String prefix = (lang == 'vi') ? 'Hôm nay' : 'Today';

    final String dateStr = DateFormat('d/M/yyyy', lang == 'vi' ? 'vi' : 'en')
        .format(d);

    return '$prefix, $dateStr';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceDataCubit,AttendanceDataState>(
        bloc: widget.cubit,
        listener: (context,state){
          if(state.loadStatus == LoadStatus.LOADING){
            LoadingOverlay.show(context);
          }else{
            LoadingOverlay.hide(context);
          }
        },
        builder: (context,state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<AttendanceDataCubit,AttendanceDataState>(
                    bloc: widget.cubit,
                    buildWhen: (prev,cur) => prev.selectedDateTime != cur.selectedDateTime ||
                      prev.listSelectedEntries != cur.listSelectedEntries ||
                    prev.selectedDate != cur.selectedDate,
                    builder: (context,state){
                      return attendance.AttendanceCard(
                        date: state.selectedDateTime ?? todayFormatted(locale: const Locale('vi')),
                        status: state.listSelectedEntries?.first.workEntryType?.name ??  "Đúng giờ",
                        timerage: "08:30 - 18:00",
                        iconPath: AppAssets.ic_roundG,
                      );
                    }),

                const SizedBox(height: 12),
                leave.LeaveBalanceCard(remainingDays: (GlobalData.instance.userProfile?.remainLeave ?? '0.0').toString()),
                const SizedBox(height: 10),
                _buildAttendanceCalendar,
                // _buildCalendar(),
                const SizedBox(height: 20),
                _buildLegend(),
                const SizedBox(height: 24),
                _buildActivityHeader(),
                const SizedBox(height: 12),
                _buildActivityList(),
                const SizedBox(height: 40),
              ],
            ),
          );
        });

  }


  get _buildAttendanceCalendar {
    return BlocBuilder<AttendanceDataCubit,AttendanceDataState>(
        bloc: widget.cubit,
        buildWhen: (prev,cur) =>
          prev.loadStatus != cur.loadStatus ||
          prev.listAttendances != cur.listAttendances ||
          prev.attendanceDateMap != cur.attendanceDateMap ||
          prev.focusedMonth != cur.focusedMonth,
        builder: (context,state){
          return SizedBox(
            width: double.infinity,
            height: ScreenSize.of(context).height*0.45,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: _buildYearMonthDropdown(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GestureDetector(
                    // onHorizontalDragUpdate: (d) => _dragDx += d.delta.dx,
                    // onHorizontalDragEnd: (_) {
                    //   if (_dragDx <= -40) {
                    //     widget.cubit.nextMonth();
                    //   } else if (_dragDx >= 40) {
                    //     widget.cubit.prevMonth();
                    //   }
                    //   _dragDx = 0;
                    // },
                    child: MonthView(
                      month: state.focusedMonth ?? DateTime(DateTime.now().year, DateTime.now().month-1),
                      dayDisplay: state.attendanceDateMap ?? {},
                      entriesByDate: state.entriesByDate ?? {},
                      loading: state.loadStatus == LoadStatus.LOADING ? true : false,
                      error: "",//state.error,
                      onTapDay: (date) {

                        final key = DateTime(date.year, date.month, date.day);
                        List<WorkEntity> entries = state.entriesByDate?[key] ?? const [];
                        if(entries.isNotEmpty){
                          String day = Utils().dayLabel(date);
                          widget.cubit.onChangeSelectedDateTime(day);
                          widget.cubit.onChangeSelectedEntries(entries);
                          widget.cubit.onChangeSelectedDate(date);
                        }

                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
  Widget _buildYearMonthDropdown() {
    return BlocBuilder<AttendanceDataCubit,AttendanceDataState>(
        bloc: widget.cubit,
        buildWhen: (prev,cur) => prev.selectedMonth != cur.selectedMonth ||
          prev.selectedYear != cur.selectedYear ||
          prev.focusedMonth != cur.focusedMonth,
        builder: (context,state){
          return Row(
            children: [
              Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: (){
                      openYearBottomSheet(context, int.parse(state.selectedYear ?? ""), (year){
                            widget.cubit.setYearMonth(year, int.parse(state.selectedMonth ?? "0"));
                      });
                    },
                    child: Center(
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.selectedYear ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),),
                          const SizedBox(width: 6,),
                          SvgPicture.asset(AppAssets.icArrowDown)
                        ],
                      ),
                    ),
                  )),
               Container(height: 24,width: 1,color: Colors.grey,),
              Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: (){
                      openMonthBottomSheet(context, int.parse(state.selectedMonth ?? ""), (month){
                        widget.cubit.setYearMonth(int.parse(state.selectedYear ?? ""), month);
                      });
                    },
                    child: Center(
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Tháng ${state.selectedMonth}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),),
                          const SizedBox(width: 6,),
                          SvgPicture.asset(AppAssets.icArrowDown)
                        ],
                      ),
                    ),
                  )),
            ],
          );
        });

  }

  // Widgets
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

  // functions
  Future<void> openYearBottomSheet(
      BuildContext context, int selected, ValueChanged<int> onPicked) async {
    final nowY = DateTime.now().year;
    // range: now-10 .. now+10 (bạn có thể điều chỉnh dễ dàng)
    final years = List.generate(7, (i) => nowY - 3 + i);

    final primary = Theme.of(context).colorScheme.primary;

    final picked = await showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text('Năm',
                    style: Theme.of(ctx)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: years.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final y = years[i];
                      final isSel = y == selected;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: (){
                          Navigator.pop(ctx, y);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? primary.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Spacer(),
                              Text(
                                '$y',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSel ? AppColors.themePrimaryDefault : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              if (isSel)
                                Icon(Icons.check, color: AppColors.themePrimaryDefault, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) onPicked(picked);
  }

  Future<void> openMonthBottomSheet(
      BuildContext context, int selected, ValueChanged<int> onPicked) async {
    final months = List.generate(12, (i) => i + 1);
    final primary = Theme.of(context).colorScheme.primary;

    final picked = await showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text('Tháng',
                    style: Theme.of(ctx)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: months.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final m = months[i];
                      final isSel = m == selected;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(ctx, m),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? primary.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Spacer(),
                              Text(
                                'Tháng $m',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSel ? AppColors.themePrimaryDefault : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              if (isSel)
                                Icon(Icons.check, color: AppColors.themePrimaryDefault, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) onPicked(picked);
  }

}
