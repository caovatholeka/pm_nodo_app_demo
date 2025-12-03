import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/commons/screen_size.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/core/utils/utils.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_cubit.dart';
import 'package:pm_app/app/features/ui/attendance/bottom_sheet/detail_work_entry_bottom_sheet.dart';
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

  bool _isDetailSheetOpen = false;

  final List<String> months = List.generate(12, (i) => "${i + 1}");
  final List<String> years = List.generate(6, (i) => (2023 + i).toString());

  final Map<DateTime, Color> _dayColors = {
    DateTime(2025, 11, 1): Colors.green,
    DateTime(2025, 11, 2): Colors.red,
    DateTime(2025, 11, 3): Colors.orange,
    DateTime(2025, 11, 4): Colors.green,
  };

  DateTime? _initDate;

  @override
  void initState() {
    // get list attendance
    widget.cubit.setYearMonth(DateTime.now().year, DateTime.now().month);
    widget.cubit.getListAttendances(DateTime(DateTime.now().year,DateTime.now().month));  //DateTime.now()
    widget.cubit.onChangeSelectedDate(DateTime.now());
    // widget.cubit.getListAttendanceHistory();
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
        listener: (context,state) async{
          if(state.loadStatus == LoadStatus.LOADING ||
            state.detailStatus == LoadStatus.LOADING){
            LoadingOverlay.show(context);
          }else if(state.detailStatus == LoadStatus.SUCCESS){
            LoadingOverlay.hide(context);
            // show popup
            // _showSelectedDayDialog(state.listDetailEntry?.first ?? WorkEntity());
            if (!_isDetailSheetOpen) {
              _isDetailSheetOpen = true;

              final work = state.listDetailEntry?.first ?? WorkEntity();

              await _showSelectedDayDialog(work);

              if (mounted) {
                _isDetailSheetOpen = false;
              }
            }

            widget.cubit.resetStatus();
          }
          else{
            widget.cubit.resetStatus();
            LoadingOverlay.hide(context);
          }
        },
        builder: (context,state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                leave.LeaveBalanceCard(remainingDays:
                  (GlobalData.instance.
                  userProfile?.remainLeave ?? '0.0').toString().replaceAll(".0", "")),
                const SizedBox(height: 12),
                _buildAttendanceCalendar,
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
          prev.focusedMonth != cur.focusedMonth ||
          prev.selectedDate != cur.selectedDate,
        builder: (context,state){
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildYearMonthDropdown(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: ScreenSize.of(context).height*0.35,
                  child: MonthView(
                    month: state.focusedMonth ?? DateTime(DateTime.now().year, DateTime.now().month-1),
                    dayDisplay: state.attendanceDateMap ?? {},
                    entriesByDate: state.entriesByDate ?? {},
                    loading: state.loadStatus == LoadStatus.LOADING ? true : false,
                    error: "",//state.error,
                    selectedDate: state.selectedDate,
                    onTapDay: (date) {
                      if (_isDetailSheetOpen ||
                          widget.cubit.state.detailStatus == LoadStatus.LOADING) {
                        return;
                      }

                      final key = DateTime(date.year, date.month, date.day);
                      List<WorkEntity> entries = state.entriesByDate?[key] ?? const [];
                      widget.cubit.onChangeSelectedDate(date);
                      if(entries.isNotEmpty){
                        // show popup
                        widget.cubit.getDetailWorkEntry(entries.first.id ?? 0);
                      }

                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
  Widget _buildYearMonthDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () async{
            final s = widget.cubit.state;
            await _showYearMonthPicker(
              context: context,
              defaultValue: DateTime(int.parse(s.selectedYear ?? "0") , int.parse(s.selectedMonth ?? "0") , 1),
              onConfirm: (month, year) {
                widget.cubit.setYearMonth(int.parse(year) , int.parse(month));
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.themePrimaryDefault,
                borderRadius: BorderRadius.all(Radius.circular(100))
            ),
            child: BlocBuilder<AttendanceDataCubit,AttendanceDataState>(
              bloc: widget.cubit,
              buildWhen: (prev,cur) => prev.selectedMonth != cur.selectedMonth ||
                  prev.selectedYear != cur.selectedYear ||
                  prev.focusedMonth != cur.focusedMonth,
              builder: (context,state){
                return Text(
                  "Tháng ${state.selectedMonth}, ${state.selectedYear}",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white
                  ),
                );
              }
            ),

          ),
        ),
        Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: InkWell(
                onTap: (){
                  _shiftMonth(-1);
                },
                child: Icon(Icons.arrow_back_ios,color: AppColors.themePrimaryDefault,size: 20,),
              ).paddingOnly(right: 8),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: InkWell(
                onTap: (){
                  _shiftMonth(1);
                },
                child: Icon(Icons.arrow_forward_ios,color: AppColors.themePrimaryDefault,size: 20,),
              ).paddingOnly(right: 4),
            )
          ],
        )
      ],
    );
  }

  // Widgets
  Widget _buildLegend() {
    return BlocBuilder<AttendanceDataCubit,AttendanceDataState>(
        bloc: widget.cubit,
        buildWhen: (prev,cur) => prev.isLegendExpand != cur.isLegendExpand,
        builder: (context,state){
          return Column(
            children: [
              InkWell(
                onTap: (){
                  widget.cubit.changeIsLegendExpand();
                },
                child: Container(
                  width: double.infinity,
                  height: 36,
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  decoration: BoxDecoration(
                      color: Color(0xFFE4F0FF),
                      borderRadius: BorderRadius.all(Radius.circular(6))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Trạng thái chấm công",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.themePrimaryDefault
                            ),
                        ),
                        state.isLegendExpand ? Icon(Icons.expand_less,color: AppColors.themePrimaryDefault)
                            : Icon(Icons.expand_more, color: AppColors.themePrimaryDefault,)
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12,),
              BlocBuilder<AttendanceDataCubit,AttendanceDataState>(
                  bloc: widget.cubit,
                  buildWhen: (prev,cur) => prev.isLegendExpand != cur.isLegendExpand,
                  builder: (context,state){
                    return state.isLegendExpand ? Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              legend.LegendItem(color: Color(0xFF41B100), label: "Công đi làm"),
                              const SizedBox(height: 8,),
                              legend.LegendItem(color: Color(0xFFDA3535), label: "Chưa chấm công"),
                              const SizedBox(height: 8,),
                              legend.LegendItem(color: Color(0xFf2C00CC), label: "Thiếu giờ ra"),
                              const SizedBox(height: 8,),
                              legend.LegendItem(color: Color(0xFFDC00C6), label: "Nghỉ không lương"),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              legend.LegendItem(color: Color(0xFFD9A8CC), label: "Đi muộn / Về sớm"),
                              const SizedBox(height: 8,),
                              legend.LegendItem(color: Color(0xFFA5A5A9), label: "Nghỉ cuối tuần"),
                              const SizedBox(height: 8,),
                              legend.LegendItem(color: Color(0xFF9F5D00), label: "Thiếu giờ vào"),
                              const SizedBox(height: 8,),
                              legend.LegendItem(color: Color(0xFF00D3D6), label: "Nửa ngày công"),
                            ],
                          )
                        ],
                      ),
                    ) : SizedBox.shrink() ;
                  })
            ],
          );
        });
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
        // Text("Xem tất cả", style: TextStyle(color: AppColors.subtitle)),
      ],
    );
  }

  Widget _buildActivityList() {
    return BlocBuilder<AttendanceDataCubit,AttendanceDataState>(
      bloc: widget.cubit,
      buildWhen: (prev,cur) => prev.listAttendanceHistory != cur.listAttendanceHistory
        || prev.historyStatus != cur.historyStatus,
      builder: (context,state){
        return state.historyStatus == LoadStatus.LOADING ?
          Center(child: CircularProgressIndicator(color: AppColors.themePrimaryDefault,),) :
        ((state.listAttendanceHistory ??[]).isNotEmpty) ?
          Column(
            children: (state.listAttendanceHistory ?? []).map((his) {
              String status = "Đúng giờ";
              if(his.isEarly ?? false){
                status = "Về sớm";
              }else if (his.isLate ?? false){
                status = "Đi muộn";
              }
              return ActivityItem(
                icon: his.action == "check_in" ? AppAssets.icCheckin : AppAssets.icCheckout,
                title: his.action == "check_in" ?  "Check In" : "Check Out",
                time: AppDateUtils().formatTimeAmPm(his.datetime ?? ""),
                subtitle: AppDateUtils().formatDateTime(his.datetime ?? ""),
                place: his.location?.name ?? "",
                status: status,
              );
            }).toList(),
          ) : Center(child: Text("Chưa có dữ liệu"),);
      }
    );

  }

  // functions
  Future<void> _showSelectedDayDialog(WorkEntity workEntity) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (BuildContext context) =>
          DetailWorkEntryBottomSheet(
           workEntity: workEntity,
            date: workEntity.date,
          ),
    );
  }

  Future<void> _showYearMonthPicker({
    required BuildContext context,
    DateTime? defaultValue,
    required void Function(String month, String year) onConfirm,
  }) async {
    final now = DateTime.now();
    final initial = defaultValue ?? DateTime(now.year, now.month, 1);

    DatePicker.showPicker(
      context,
      showTitleActions: true,
      locale: LocaleType.vi,
      pickerModel: YearMonthPicker(
        currentTime: initial,
        minTime: DateTime(2015, 1, 1),
        maxTime: DateTime(2035, 12, 31),
        locale: LocaleType.vi,
      ),
      onConfirm: (dt) {
        final y = dt.year.toString();
        final m = dt.month.toString().padLeft(2, '0');
        onConfirm(m, y);
      },
    );
  }

  // on change month
  void _shiftMonth(int delta) {
    final s = widget.cubit.state;
    int y = int.parse(s.selectedYear ?? "0") ;
    int m = int.parse(s.selectedMonth ?? "0") + delta;

    if (m > 12) { m = 1;  y += 1; }
    if (m < 1)  { m = 12; y -= 1; }

    widget.cubit.setYearMonth(y, m);
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

class YearMonthPicker extends CommonPickerModel {
  YearMonthPicker({
    required DateTime currentTime,
    DateTime? minTime,
    DateTime? maxTime,
    super.locale,
  }) {
    this.currentTime = currentTime;
    this.minTime = minTime ?? DateTime(2000, 1, 1);
    this.maxTime = maxTime ?? DateTime(2100, 12, 31);


    setLeftIndex(currentTime.year - this.minTime.year);
    setMiddleIndex(currentTime.month - 1);
    setRightIndex(0);
  }

  late DateTime minTime;
  late DateTime maxTime;


  @override
  String? leftStringAtIndex(int index) {
    final year = minTime.year + index;
    if (year < minTime.year || year > maxTime.year) return null;
    return '$year';
  }


  @override
  String? middleStringAtIndex(int index) {
    if (index < 0 || index > 11) return null;
    final m = index + 1;
    return 'Tháng $m';
  }

  @override
  String? rightStringAtIndex(int index) => '';

  @override
  List<int> layoutProportions() => [2, 2, 0];

  @override
  DateTime finalTime() {
    final year = minTime.year + currentLeftIndex();
    final month = currentMiddleIndex() + 1;
    return DateTime(year, month, 1);
  }
}

