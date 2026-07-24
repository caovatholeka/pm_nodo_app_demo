import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/on_leave/create_new_leave_page.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_detail_page.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/entities/on_leave_entity.dart';
import '../../../data/models/enums/load_status.dart';
import '../../ui/on_leave/bloc/on_leave_cubit.dart';
import 'widget/on_leave_list_item_v2.dart';

const int kManagerApproveStatusIdV2Page = 14;

/// Màn Nghỉ phép — phiên bản giao diện tối (v2). Nội dung/hành vi giữ nguyên
/// bản cũ [OnLeavePage]: lọc theo khoảng ngày, tạo đơn, cuộn tải thêm,
/// duyệt hàng loạt (chỉ Giám đốc), gửi duyệt/xoá đơn, mở chi tiết.
/// Tái dùng [OnLeaveCubit] qua GetIt (không tạo mới, không close).
class OnLeavePageV2 extends StatefulWidget {
  final bool? isFromHome;
  const OnLeavePageV2({super.key, this.isFromHome});

  @override
  State<OnLeavePageV2> createState() => _OnLeavePageV2State();
}

class _OnLeavePageV2State extends State<OnLeavePageV2> {
  final _cubit = GetIt.I.get<OnLeaveCubit>();
  final Set<int> selectedIds = {};
  final ScrollController controller = ScrollController();

  final TextEditingController filterController = TextEditingController();

  DateTimeRange selectedWeek = _weekOf(DateTime.now());
  final _df = DateFormat('dd/MM/yyyy');

  /// true = lịch tháng, false = danh sách dọc (mặc định, giữ nguyên hành vi cũ).
  bool _isCalendarView = true;
  DateTime _focusedDay = _dayOnly(DateTime.now());
  DateTime _selectedDay = _dayOnly(DateTime.now());

  /// Cache map ngày -> danh sách đơn nghỉ giao với ngày đó, tính lại chỉ khi
  /// tham chiếu `listLeaveEntities` đổi (tránh tính lại mỗi lần build).
  List<OnLeaveEntity>? _eventsSourceList;
  Map<DateTime, List<OnLeaveEntity>> _eventsByDay = const {};

  @override
  void initState() {
    super.initState();
    // Mặc định mở ở chế độ lịch tháng hiện tại -> nạp đúng dữ liệu tháng đó,
    // nếu để không lọc thì danh sách phân trang sẽ làm lịch thiếu marker.
    _applyMonthFilter(_focusedDay);
    filterController.clear();
    controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    controller.removeListener(_onScroll);
    controller.dispose();
    filterController.dispose();
    super.dispose();
  }

  /// Nạp danh sách đơn nghỉ của đúng tháng chứa [month] (dùng cho chế độ lịch).
  void _applyMonthFilter(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    _cubit.onChangeDateFilter(_df.format(first), _df.format(last));
    _cubit.getListOnLeaveTimes();
  }

  /// Bỏ lọc theo tháng (chế độ danh sách xem toàn bộ như trước).
  void _clearMonthFilter() {
    filterController.clear();
    _cubit.onChangeDateFilter("", "");
    _cubit.getListOnLeaveTimes();
  }

  void _onScroll() {
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 100) {
      _cubit.onLoadMore();
    }
  }

  void _showApproveBulkDialog() {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (_) => CustomDialog(
            title: s.confirm_authorize,
            content: s
                .on_leave_sub_confirm_authorize("{count}")
                .replaceFirst("{count}", selectedIds.length.toString()),
            cancelText: s.cancel,
            confirmText: s.confirm,
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              Navigator.pop(context);
              _cubit.approveBulkLeaves(selectedIds.toList());
            },
          ),
    );
  }

  bool get isDirector {
    final jobTitle = context.read<AppCubit>().state.userProfile?.jobTitle ?? "";
    return jobTitle.toLowerCase().contains("giám đốc");
  }

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Tính lại map ngày -> danh sách đơn (chỉ khi list đổi tham chiếu).
  /// Một đơn kéo dài dateFrom..dateTo được gán vào MỌI ngày trong khoảng
  /// (bao gồm hai đầu mút), so sánh theo ngày (bỏ giờ/phút).
  void _rebuildEventsMapIfNeeded(List<OnLeaveEntity> list) {
    if (identical(list, _eventsSourceList)) return;
    _eventsSourceList = list;

    final map = <DateTime, List<OnLeaveEntity>>{};
    for (final e in list) {
      final from = AppDateUtils.parseFlexibleDate(e.dateFrom);
      if (from == null) continue;
      final to = AppDateUtils.parseFlexibleDate(e.dateTo) ?? from;

      var cursor = _dayOnly(from);
      final end = _dayOnly(to);
      // Giới hạn số ngày lặp để tránh dữ liệu bất thường làm treo UI.
      var guard = 0;
      while (!cursor.isAfter(end) && guard < 366) {
        map.putIfAbsent(cursor, () => <OnLeaveEntity>[]).add(e);
        cursor = cursor.add(const Duration(days: 1));
        guard++;
      }
    }
    _eventsByDay = map;
  }

  static DateTime _mondayOf(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return x.subtract(Duration(days: x.weekday - 1));
  }

  static DateTimeRange _weekOf(DateTime d) {
    final start = _mondayOf(d);
    return DateTimeRange(start: start, end: start.add(const Duration(days: 6)));
  }

  Future<void> _onRefresh() async {
    _cubit.getListOnLeaveTimes();
  }

  void _approveSelected() {
    final s = S.of(context);
    if (selectedIds.isEmpty) {
      Flushbar(
        message: s.on_leave_no_data_approve,
        backgroundColor: AppTokensV2.fgMuted,
        flushbarPosition: FlushbarPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      return;
    }
    _showApproveBulkDialog();
  }

  void _goNotification() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
              child: const NotificationPage(),
            ),
      ),
    );
  }

  Future<void> _openDetail(OnLeaveEntity entity) async {
    if (selectedIds.isNotEmpty) return;

    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => OnLeaveDetailPage(detailEntity: entity, detailId: entity.id),
      ),
    );

    if (result == true) {
      _onRefresh();
    }
  }

  void _handleConfirmLeave(OnLeaveEntity entity) {
    final s = S.of(context);

    showDialog(
      context: context,
      builder:
          (_) => CustomDialog(
            title: s.confirm,
            content: "Bạn có muốn gửi duyệt đơn này không?",
            cancelText: s.cancel,
            confirmText: "Ok",
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              Navigator.pop(context);
              _cubit.confirmLeave(entity.id!);
            },
          ),
    );
  }

  void _handleDeleteLeave(OnLeaveEntity entity) {
    final s = S.of(context);

    showDialog(
      context: context,
      builder:
          (_) => CustomDialog(
            title: s.confirm,
            content: "Bạn có chắc muốn xóa đơn nghỉ không?",
            cancelText: s.cancel,
            confirmText: "Ok",
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              Navigator.pop(context);
              _cubit.deleteOnLeave(entity.id!);
            },
          ),
    );
  }

  Future<void> _createNewLeave() async {
    HapticFeedback.selectionClick();
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateNewLeavePage()),
    );

    if (result == true) {
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<OnLeaveCubit, OnLeaveState>(
      bloc: _cubit,
      listenWhen: (previous, current) =>
          previous.confirmStatus != current.confirmStatus ||
          previous.deleteStatus != current.deleteStatus ||
          previous.approveStatus != current.approveStatus,
      listener: (context, state) {
        if (state.confirmStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        }

        if (state.confirmStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          Flushbar(
            message: s.send_approval_success,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            flushbarPosition: FlushbarPosition.TOP,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          ).show(context);

          _cubit.resetConfirmStatus();
          _cubit.getListOnLeaveTimes();
        }

        if (state.confirmStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);

          Flushbar(
            message: s.on_leave_failed,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);

          _cubit.resetConfirmStatus();
        }

        if (state.deleteStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        }

        if (state.deleteStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          Flushbar(
            message: s.delete_success,
            backgroundColor: Colors.green,
            flushbarPosition: FlushbarPosition.TOP,
            duration: const Duration(seconds: 2),
          ).show(context);

          _cubit.resetDeleteStatus();
          _cubit.getListOnLeaveTimes();
        }

        if (state.deleteStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);

          Flushbar(
            message: s.delete_approval_failed,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ).show(context);

          _cubit.resetDeleteStatus();
        }
        if (state.approveStatus == LoadStatus.SUCCESS) {
          Flushbar(
            message: s.on_leave_success,
            backgroundColor: Colors.green,
            flushbarPosition: FlushbarPosition.TOP,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          setState(() {
            selectedIds.clear();
          });

          _cubit.getListOnLeaveTimes();
          _cubit.resetApproveStatus();
        }

        if (state.approveStatus == LoadStatus.FAILURE) {
          Flushbar(
            message: s.on_leave_failed,
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetApproveStatus();
        }
      },
      child: Scaffold(
        backgroundColor: AppTokensV2.bgDeep,
        body: AmbientBackgroundV2(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: StaggerRevealV2(index: 0, child: _topBar(s)),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: StaggerRevealV2(index: 1, child: _filterWidget),
                ),
                if (!_isCalendarView)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                    child: _bulkActionWidget,
                  ),
                const SizedBox(height: 6),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _isCalendarView ? _calendarViewWidget : _listWidget,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(S s) {
    final showBack = widget.isFromHome ?? false;
    return Row(
      children: [
        if (showBack) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.maybePop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTokensV2.fg,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            s.day_off_title,
            style: AppTokensV2.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isCalendarView = !_isCalendarView);
            if (_isCalendarView) {
              _applyMonthFilter(_focusedDay);
            } else {
              _clearMonthFilter();
            }
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              border: Border.all(color: AppTokensV2.border),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _isCalendarView
                  ? Icons.view_list_rounded
                  : Icons.calendar_month_rounded,
              size: 20,
              color: AppTokensV2.fgSoft,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _goNotification,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              border: Border.all(color: AppTokensV2.border),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: AppTokensV2.fgSoft,
            ),
          ),
        ),
      ],
    );
  }

  Widget get _filterWidget {
    return BlocBuilder<OnLeaveCubit, OnLeaveState>(
      bloc: _cubit,
      buildWhen:
          (p, c) =>
              p.startDateFilter != c.startDateFilter ||
              p.endDateFilter != c.endDateFilter,
      builder: (context, state) {
        final week =
            (state.startDateFilter ?? "").isNotEmpty
                ? "${state.startDateFilter} - ${state.endDateFilter}"
                : "";
        filterController.text = week;
        final hasFilter = week.isNotEmpty;

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final res = await showModalBottomSheet<DateTimeRange?>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder:
                        (_) => CalendarRangeSheet(
                          initial: selectedWeek,
                          locale: Localizations.localeOf(context).languageCode,
                        ),
                  );

                  if (res == null) {
                    filterController.clear();
                    _cubit.onChangeDateFilter("", "");
                  } else {
                    selectedWeek = res;
                    _cubit.onChangeDateFilter(
                      _df.format(res.start),
                      _df.format(res.end),
                    );
                  }

                  _cubit.getListOnLeaveTimes();
                },
                child: GlassCardV2(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  radius: 15,
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 17,
                          color: AppTokensV2.fgMuted,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            hasFilter ? week : S.of(context).calendar_title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                hasFilter
                                    ? AppTokensV2.body.copyWith(fontSize: 13)
                                    : AppTokensV2.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _createNewLeave,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppTokensV2.accentGradient,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppTokensV2.glow,
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget get _bulkActionWidget {
    final s = S.of(context);
    if (!isDirector) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<OnLeaveCubit, OnLeaveState>(
      bloc: _cubit,
      builder: (context, state) {
        final list = state.listLeaveEntities ?? [];
        final approvableIds =
            list
                .where((e) => e.leaveStage?.id == kManagerApproveStatusIdV2Page)
                .map((e) => e.id)
                .whereType<int>()
                .toSet();

        if (approvableIds.isEmpty) {
          return const SizedBox.shrink();
        }

        final isAllChecked =
            selectedIds.isNotEmpty && selectedIds.containsAll(approvableIds);

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: GlassCardV2(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            radius: 15,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            fillColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return AppTokensV2.accent;
                              }
                              return Colors.transparent;
                            }),
                            checkColor: WidgetStateProperty.all(Colors.white),
                            side: const BorderSide(
                              color: AppTokensV2.fgMuted,
                              width: 1.2,
                            ),
                          ),
                        ),
                        child: Checkbox(
                          value: isAllChecked,
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (value == true) {
                                selectedIds
                                  ..clear()
                                  ..addAll(approvableIds);
                              } else {
                                selectedIds.clear();
                              }
                            });
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(s.choose_all, style: AppTokensV2.captionStrong),
                    ],
                  ),
                ),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed:
                        selectedIds.isEmpty
                            ? null
                            : () {
                              HapticFeedback.selectionClick();
                              _approveSelected();
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokensV2.accent,
                      disabledBackgroundColor: AppTokensV2.accent.withValues(
                        alpha: 0.35,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      "${s.authorize} ${selectedIds.length}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget get _listWidget {
    return BlocBuilder<OnLeaveCubit, OnLeaveState>(
      bloc: _cubit,
      buildWhen:
          (p, c) =>
              p.loadStatus != c.loadStatus ||
              p.listLeaveEntities != c.listLeaveEntities,
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.LOADING) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppTokensV2.accent,
            ),
          );
        }

        final list = state.listLeaveEntities ?? [];
        if (list.isEmpty) {
          return Center(
            child: Text(
              S.of(context).bt_empty,
              style: AppTokensV2.captionStrong,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTokensV2.accent,
          backgroundColor: AppTokensV2.bgTop,
          child: ListView.builder(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 16, bottom: 120),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final e = list[i];
              final statusId = e.leaveStage?.id ?? 0;

              final isFinished = [11, 14, 15, 9].contains(statusId);
              final isCanceled = [20, 16, 12].contains(statusId);

              final item = StaggerRevealV2(
                index: i < 6 ? i : 0,
                child: OnLeaveListItemV2(
                  entity: e,
                  isDirector: isDirector,
                  isChecked: selectedIds.contains(e.id),
                  showCheckbox: true,
                  onCheckedChanged: (v) {
                    setState(() {
                      if (v == true) {
                        selectedIds.add(e.id!);
                      } else {
                        selectedIds.remove(e.id);
                      }
                    });
                  },
                  onShowDetail: () => _openDetail(e),
                ),
              );

              if (isFinished || isCanceled) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: item,
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Slidable(
                  key: ValueKey(e.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.45,
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          _handleConfirmLeave(e);
                        },
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        label: "Gửi duyệt",
                        icon: Icons.send,
                      ),
                      SlidableAction(
                        onPressed: (_) {
                          _handleDeleteLeave(e);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        label: "Xóa",
                        icon: Icons.delete,
                      ),
                    ],
                  ),
                  child: item,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Chế độ Lịch: lịch tháng ở trên + danh sách đơn giao với ngày đang chọn.
  /// Vẫn dùng chung `OnLeaveCubit`/dữ liệu với chế độ Danh sách.
  Widget get _calendarViewWidget {
    return BlocBuilder<OnLeaveCubit, OnLeaveState>(
      bloc: _cubit,
      buildWhen:
          (p, c) =>
              p.loadStatus != c.loadStatus ||
              p.listLeaveEntities != c.listLeaveEntities,
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.LOADING) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppTokensV2.accent,
            ),
          );
        }

        final list = state.listLeaveEntities ?? [];
        _rebuildEventsMapIfNeeded(list);
        final dayEvents = _eventsByDay[_selectedDay] ?? const <OnLeaveEntity>[];

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTokensV2.accent,
          backgroundColor: AppTokensV2.bgTop,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 4, bottom: 120),
            children: [
              GlassCardV2(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 8,
                ),
                radius: 18,
                child: _buildTableCalendar(),
              ),
              const SizedBox(height: 16),
              if (dayEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.event_busy_rounded,
                          size: 38,
                          color: AppTokensV2.fgMuted,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Không có đơn nghỉ ngày này",
                          style: AppTokensV2.captionStrong,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...List.generate(dayEvents.length, (i) {
                  final e = dayEvents[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StaggerRevealV2(
                      index: i < 6 ? i : 0,
                      child: OnLeaveListItemV2(
                        entity: e,
                        isDirector: isDirector,
                        isChecked: false,
                        showCheckbox: false,
                        onShowDetail: () => _openDetail(e),
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar<OnLeaveEntity>(
      locale: Localizations.localeOf(context).languageCode,
      firstDay: DateTime(2015, 1, 1),
      lastDay: DateTime(2035, 12, 31),
      focusedDay: _focusedDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      eventLoader: (day) => _eventsByDay[_dayOnly(day)] ?? const [],
      onDaySelected: (selectedDay, focusedDay) {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedDay = _dayOnly(selectedDay);
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _applyMonthFilter(focusedDay);
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: AppTokensV2.section,
        leftChevronIcon: const Icon(
          Icons.chevron_left_rounded,
          color: AppTokensV2.fgSoft,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right_rounded,
          color: AppTokensV2.fgSoft,
        ),
        decoration: const BoxDecoration(),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTokensV2.caption,
        weekendStyle: AppTokensV2.caption.copyWith(
          color: AppTokensV2.danger.withValues(alpha: 0.75),
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: AppTokensV2.body.copyWith(
          fontWeight: FontWeight.w500,
        ),
        weekendTextStyle: AppTokensV2.body.copyWith(
          fontWeight: FontWeight.w500,
          color: AppTokensV2.fgSoft,
        ),
        todayDecoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTokensV2.accent, width: 1.4),
        ),
        todayTextStyle: AppTokensV2.body.copyWith(
          color: AppTokensV2.accent,
          fontWeight: FontWeight.w700,
        ),
        selectedDecoration: const BoxDecoration(
          gradient: AppTokensV2.accentGradient,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        markerDecoration: const BoxDecoration(),
        markersMaxCount: 4,
        markerMargin: const EdgeInsets.only(top: 2),
        cellMargin: const EdgeInsets.all(4),
      ),
      calendarBuilders: CalendarBuilders<OnLeaveEntity>(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          final colors =
              events
                  .map(
                    (e) =>
                        OnLeaveListItemV2.statusColorFor(e.leaveStage?.id ?? 0),
                  )
                  .toSet()
                  .take(4)
                  .toList();
          return Positioned(
            bottom: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:
                  colors
                      .map(
                        (c) => Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1.2),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      .toList(),
            ),
          );
        },
      ),
    );
  }
}
