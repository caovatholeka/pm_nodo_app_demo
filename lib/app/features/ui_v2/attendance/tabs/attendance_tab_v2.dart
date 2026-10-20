import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/commons/screen_size.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_cubit.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/attendance_tab/attendance_tab.dart'
    show YearMonthPicker;
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/generated/l10n.dart';

import '../widget/activity_item_v2.dart';
import '../widget/detail_work_entry_bottom_sheet_v2.dart';
import '../widget/leave_balance_card_v2.dart';
import '../widget/legend_item_v2.dart';
import '../widget/month_view_v2.dart';

/// Bản tối (v2) của [AttendanceTab]
/// (`lib/app/features/ui/attendance/attendance_data_tab/attendance_tab/attendance_tab.dart`).
///
/// Cùng constructor (`cubit`), tái dùng nguyên [AttendanceDataCubit] qua
/// tham số truyền vào (không tạo cubit mới, không close). Hành vi giữ nguyên:
/// nạp danh sách chấm công theo tháng ở initState, chọn ngày mở bottom sheet
/// chi tiết, đổi tháng/năm qua picker hoặc mũi tên, mở/thu gọn chú giải màu.
class AttendanceTabV2 extends StatefulWidget {
  AttendanceDataCubit cubit;
  AttendanceTabV2({super.key, required this.cubit});

  @override
  State<AttendanceTabV2> createState() => _AttendanceTabV2State();
}

class _AttendanceTabV2State extends State<AttendanceTabV2> {
  bool _isDetailSheetOpen = false;

  @override
  void initState() {
    // get list attendance
    widget.cubit.setYearMonth(DateTime.now().year, DateTime.now().month);
    widget.cubit.getListAttendances(
        DateTime(DateTime.now().year, DateTime.now().month));
    widget.cubit.onChangeSelectedDate(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceDataCubit, AttendanceDataState>(
        bloc: widget.cubit,
        listener: (context, state) async {
          if (state.loadStatus == LoadStatus.LOADING ||
              state.detailStatus == LoadStatus.LOADING) {
            LoadingOverlay.show(context);
          } else if (state.detailStatus == LoadStatus.SUCCESS) {
            LoadingOverlay.hide(context);
            if (!_isDetailSheetOpen) {
              _isDetailSheetOpen = true;

              final work = state.listDetailEntry?.first ?? WorkEntity();

              await _showSelectedDayDialog(work);

              if (mounted) {
                _isDetailSheetOpen = false;
              }
            }

            widget.cubit.resetStatus();
          } else {
            widget.cubit.resetStatus();
            LoadingOverlay.hide(context);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                LeaveBalanceCardV2(
                    remainingDays: (GlobalData
                                .instance.userProfile?.remainLeave ??
                            '0.0')
                        .toString()
                        .replaceAll(".0", "")),
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
    return BlocBuilder<AttendanceDataCubit, AttendanceDataState>(
        bloc: widget.cubit,
        buildWhen: (prev, cur) =>
            prev.loadStatus != cur.loadStatus ||
            prev.listAttendances != cur.listAttendances ||
            prev.attendanceDateMap != cur.attendanceDateMap ||
            prev.focusedMonth != cur.focusedMonth ||
            prev.selectedDate != cur.selectedDate,
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              border: Border.all(color: AppTokensV2.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildYearMonthDropdown(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: ScreenSize.of(context).height * 0.35,
                  child: MonthViewV2(
                    month: state.focusedMonth ??
                        DateTime(
                            DateTime.now().year, DateTime.now().month - 1),
                    dayDisplay: state.attendanceDateMap ?? {},
                    entriesByDate: state.entriesByDate ?? {},
                    loading: state.loadStatus == LoadStatus.LOADING,
                    error: "",
                    selectedDate: state.selectedDate,
                    onTapDay: (date) {
                      if (_isDetailSheetOpen ||
                          widget.cubit.state.detailStatus ==
                              LoadStatus.LOADING) {
                        return;
                      }

                      final key = DateTime(date.year, date.month, date.day);
                      List<WorkEntity> entries =
                          state.entriesByDate?[key] ?? const [];
                      widget.cubit.onChangeSelectedDate(date);
                      if (entries.isNotEmpty) {
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
    final s = S.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () async {
            final s = widget.cubit.state;
            await _showYearMonthPicker(
              context: context,
              defaultValue: DateTime(int.parse(s.selectedYear ?? "0"),
                  int.parse(s.selectedMonth ?? "0"), 1),
              onConfirm: (month, year) {
                widget.cubit.setYearMonth(int.parse(year), int.parse(month));
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppTokensV2.accentGradient,
              borderRadius: const BorderRadius.all(Radius.circular(100)),
            ),
            child: BlocBuilder<AttendanceDataCubit, AttendanceDataState>(
                bloc: widget.cubit,
                buildWhen: (prev, cur) =>
                    prev.selectedMonth != cur.selectedMonth ||
                    prev.selectedYear != cur.selectedYear ||
                    prev.focusedMonth != cur.focusedMonth,
                builder: (context, state) {
                  return Text(
                    "${s.work_data_monthYear} ${state.selectedMonth}, ${state.selectedYear}",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  );
                }),
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: InkWell(
                onTap: () {
                  _shiftMonth(-1);
                },
                child: Icon(Icons.arrow_back_ios,
                    color: AppTokensV2.fgSoft, size: 20),
              ).paddingOnly(right: 8),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: InkWell(
                onTap: () {
                  _shiftMonth(1);
                },
                child: Icon(Icons.arrow_forward_ios,
                    color: AppTokensV2.fgSoft, size: 20),
              ).paddingOnly(right: 4),
            )
          ],
        )
      ],
    );
  }

  // Widgets
  Widget _buildLegend() {
    final s = S.of(context);
    return BlocBuilder<AttendanceDataCubit, AttendanceDataState>(
        bloc: widget.cubit,
        buildWhen: (prev, cur) => prev.isLegendExpand != cur.isLegendExpand,
        builder: (context, state) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  widget.cubit.changeIsLegendExpand();
                },
                child: Container(
                  width: double.infinity,
                  height: 36,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                      color: AppTokensV2.accent.withOpacity(0.14),
                      border: Border.all(
                          color: AppTokensV2.accent.withOpacity(0.35)),
                      borderRadius: const BorderRadius.all(Radius.circular(6))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.work_data_checkInStatus,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTokensV2.accent)),
                        state.isLegendExpand
                            ? Icon(Icons.expand_less,
                                color: AppTokensV2.accent)
                            : Icon(Icons.expand_more,
                                color: AppTokensV2.accent)
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              BlocBuilder<AttendanceDataCubit, AttendanceDataState>(
                  bloc: widget.cubit,
                  buildWhen: (prev, cur) =>
                      prev.isLegendExpand != cur.isLegendExpand,
                  builder: (context, state) {
                    return state.isLegendExpand
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    LegendItemV2(
                                        color: const Color(0xFF3DDC6C),
                                        label: s.work_data_status1),
                                    const SizedBox(height: 8),
                                    LegendItemV2(
                                        color: AppTokensV2.danger,
                                        label: s.work_data_status2),
                                    const SizedBox(height: 8),
                                    LegendItemV2(
                                        color: const Color(0xFF8B7CFF),
                                        label: s.work_data_status3),
                                    const SizedBox(height: 8),
                                    LegendItemV2(
                                        color: const Color(0xFFF23DDB),
                                        label: s.work_data_status4),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    LegendItemV2(
                                        color: const Color(0xFFF2A6E0),
                                        label: s.work_data_status5),
                                    const SizedBox(height: 8),
                                    LegendItemV2(
                                        color: const Color(0xFF9CA3AF),
                                        label: s.work_data_stauts6),
                                    const SizedBox(height: 8),
                                    LegendItemV2(
                                        color: const Color(0xFFE8A33D),
                                        label: s.work_data_status7),
                                    const SizedBox(height: 8),
                                    LegendItemV2(
                                        color: const Color(0xFF00D3D6),
                                        label: s.work_data_status8),
                                  ],
                                )
                              ],
                            ),
                          )
                        : const SizedBox.shrink();
                  })
            ],
          );
        });
  }

  Widget _buildActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(S.of(context).work_data_title, style: AppTokensV2.section),
      ],
    );
  }

  Widget _buildActivityList() {
    return BlocBuilder<AttendanceDataCubit, AttendanceDataState>(
        bloc: widget.cubit,
        buildWhen: (prev, cur) =>
            prev.listAttendanceHistory != cur.listAttendanceHistory ||
            prev.historyStatus != cur.historyStatus,
        builder: (context, state) {
          return state.historyStatus == LoadStatus.LOADING
              ? Center(
                  child: CircularProgressIndicator(
                      color: AppTokensV2.accent, strokeWidth: 2.2))
              : ((state.listAttendanceHistory ?? []).isNotEmpty)
                  ? Column(
                      children:
                          (state.listAttendanceHistory ?? []).map((his) {
                        String status = "Đúng giờ";
                        if (his.isEarly ?? false) {
                          status = "Về sớm";
                        } else if (his.isLate ?? false) {
                          status = "Đi muộn";
                        }
                        return ActivityItemV2(
                          icon: his.action == "check_in"
                              ? AppAssets.icCheckin
                              : AppAssets.icCheckout,
                          title:
                              his.action == "check_in" ? "Check In" : "Check Out",
                          time: AppDateUtils()
                              .formatTimeAmPm(his.datetime ?? ""),
                          subtitle: AppDateUtils()
                              .formatDateTime(his.datetime ?? ""),
                          place: his.location?.name ?? "",
                          status: status,
                        );
                      }).toList(),
                    )
                  : Center(
                      child: Text(S.of(context).justification_emptyData,
                          style: AppTokensV2.caption),
                    );
        });
  }

  // functions
  Future<void> _showSelectedDayDialog(WorkEntity workEntity) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (BuildContext context) => DetailWorkEntryBottomSheetV2(
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
      theme: DatePickerTheme(
        backgroundColor: AppTokensV2.bgTop,
        itemStyle: TextStyle(color: AppTokensV2.fg, fontSize: 18),
        doneStyle: TextStyle(color: AppTokensV2.accent, fontSize: 16),
        cancelStyle: TextStyle(color: AppTokensV2.fgMuted, fontSize: 16),
      ),
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
    int y = int.parse(s.selectedYear ?? "0");
    int m = int.parse(s.selectedMonth ?? "0") + delta;

    if (m > 12) {
      m = 1;
      y += 1;
    }
    if (m < 1) {
      m = 12;
      y -= 1;
    }

    widget.cubit.setYearMonth(y, m);
  }
}
