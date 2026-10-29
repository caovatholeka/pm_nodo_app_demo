import 'package:flutter/material.dart';
import 'package:pm_app/app/core/utils/validators.dart';
import 'package:pm_app/app/core/theme_v2/widgets/blank_only_hint_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/input_counter_v2.dart';
import 'package:pm_app/app/core/commons/input_limits.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/keyboard_done_bar_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/leave_day_entity.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/create_on_leave_cubit.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_assets.dart';
import 'widget/onleave_day_item_widget_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/bottom_sheet_bar_theme_v2.dart';

/// Màn Tạo/Sửa đơn nghỉ phép — phiên bản giao diện tối (v2).
///
/// Hành vi/nghiệp vụ giữ NGUYÊN bản cũ [CreateNewLeavePage]: cùng
/// [CreateOnLeaveCubit] (qua GetIt), cùng thứ tự gọi lifecycle
/// (getListDateTypeLeaves/getListTypeLeaves/initData/prefill khi sửa), cùng
/// luật bật/khoá nút lưu, cùng cách xử lý ngày (DatePicker.showDatePicker),
/// cùng validate backdate cho loại nghỉ có lương (id == 7), cùng xử lý
/// createStatus/updateStatus/errMsg. Chỉ đổi trình bày sang hệ thiết kế v2.
class CreateNewLeavePageV2 extends StatefulWidget {
  bool? isEdit;
  OnLeaveEntity? detailEntity;

  CreateNewLeavePageV2({super.key, this.isEdit, this.detailEntity});

  @override
  State<CreateNewLeavePageV2> createState() => _CreateNewLeavePageV2State();
}

class _CreateNewLeavePageV2State extends State<CreateNewLeavePageV2> {
  TextEditingController leavesDaysController = TextEditingController();
  TextEditingController dateTypeController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController totalDaysController = TextEditingController(
    text: '0',
  );

  final _createCubit = GetIt.I.get<CreateOnLeaveCubit>();

  /// Đã tạo/sửa thành công, đang chờ đóng màn → bỏ qua bấm Lưu thêm.
  bool _saved = false;
  DateTime? _initFromDate;
  DateTime? _initToDate;
  DateTime? _selectedDate;

  List<LeaveDayEntity> listDays = [];
  late var totalLeaveDays = 0;

  @override
  void initState() {
    _createCubit.getListDateTypeLeaves();
    _createCubit.getListTypeLeaves();

    if (widget.isEdit ?? false) {
      _createCubit.initData(widget.detailEntity ?? OnLeaveEntity());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillForEdit();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _createCubit.resetStatus();
    _createCubit.resetData();
    super.dispose();
  }

  void _showDialog({
    required String title,
    required String message,
    bool success = true,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (_) => CustomDialog(
            iconPath: success ? AppAssets.ic_done : AppAssets.ic_delete,
            title: title,
            content: message,
            success: success,
            onConfirm: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  // Helper funcs
  String _formatYyyyMmDd(DateTime d) {
    return AppDateUtils().formatIsoToYyyyMmDd(d.toIso8601String());
  }

  double _sumDaysByType(List<LeaveDayEntity> days) {
    double sum = 0;
    for (final d in days) {
      final t = (d.type ?? 'full').toLowerCase();
      if (t == 'after' || t == 'before') {
        sum += 0.5;
      } else {
        sum += 1.0; // full
      }
    }
    return sum;
  }

  String _fmtTotal(double v) {
    return (v == v.roundToDouble())
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);
  }

  // Edit
  DateTime? _tryParseIso(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }

  List<LeaveDayEntity> _buildDaysForEdit({
    required DateTime from,
    required DateTime to,
    required List<dynamic>? lineIds,
  }) {
    final List<LeaveDayEntity> out = [];

    if (lineIds != null && lineIds.isNotEmpty) {
      for (final e in lineIds) {
        if (e is LeaveDayEntity) {
          final d = _tryParseIso(e.date);
          if (d != null) {
            out.add(
              LeaveDayEntity(date: _formatYyyyMmDd(d), type: (e.type ?? 'full')),
            );
          }
        } else if (e is Map) {
          final d = _tryParseIso(e['date'] as String?);
          final t = (e['type'] as String?) ?? 'full';
          if (d != null) {
            out.add(LeaveDayEntity(date: _formatYyyyMmDd(d), type: t));
          }
        }
      }
      if (out.isNotEmpty) return out;
    }

    final allDays = AppDateUtils.daysBetween(from, to);
    for (final d in allDays) {
      out.add(LeaveDayEntity(date: _formatYyyyMmDd(d), type: 'full'));
    }
    return out;
  }

  Future<void> _prefillForEdit() async {
    final detail = widget.detailEntity;
    if (!(widget.isEdit ?? false) || detail == null) return;

    final from = _tryParseIso(detail.dateFrom);
    final to = _tryParseIso(detail.dateTo);

    if (from != null) {
      _createCubit.setFromDate(from);
      fromDateController
          .text = AppDateUtils.changeIso8601StringToDateTimeString(
        from.toIso8601String(),
      );
    }

    if (to != null) {
      _createCubit.setToDate(to);
      toDateController.text = AppDateUtils.changeIso8601StringToDateTimeString(
        to.toIso8601String(),
      );
    }

    final lineIds = detail.lineIds ?? [];

    if (from != null && to != null) {
      listDays = _buildDaysForEdit(from: from, to: to, lineIds: lineIds);

      _createCubit.onChangeListLeaveDays(listDays);

      final total = _sumDaysByType(listDays);
      totalDaysController.text = _fmtTotal(total);
      totalLeaveDays = int.tryParse(_fmtTotal(total)) ?? 0;
    } else {
      listDays = [];
      _createCubit.onChangeListLeaveDays(listDays);
      totalDaysController.text = '0';
      totalLeaveDays = 0;
    }

    if (listDays.isNotEmpty) {
      final firstType = listDays.first.type ?? 'full';

      final typeItem = _createCubit.state.listTypeLeaves?.firstWhere(
        (e) => e.code == firstType,
        orElse: () => MasterDataItem(text: 'Cả ngày', code: 'full'),
      );

      if (typeItem != null) {
        _createCubit.onChangeLeaveType(typeItem);
      }
    }
    final holidayStatus = detail.holidayStatus ?? '';
    final holidayStatusId = detail.holidayStatusId;

    if (holidayStatus.isNotEmpty && holidayStatusId != null) {
      dateTypeController.text = holidayStatus;

      _createCubit.onChangeDateTypeLeaves(
        MasterDataItem(
          id: holidayStatusId,
          code: holidayStatusId.toString(),
          text: holidayStatus,
        ),
      );
    }

    final description = detail.description ?? '';
    reasonController.text = description;
    _createCubit.onChangeReason(description);
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

  void _showDatePicker({DateTime? defaultValue, DateChangedCallback? onConfirm}) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      onConfirm: onConfirm,
      currentTime: defaultValue ?? DateTime.now(),
      locale: LocaleType.vi,
    );
  }

  Future<void> _openDateTypeLeaveBottomSheet(List<MasterDataItem> list) async {
    HapticFeedback.selectionClick();
    final MasterDataItem? item = await showModalBottomSheet<MasterDataItem>(
      context: context,
      backgroundColor: AppTokensV2.bgTop,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (BuildContext context) => _MasterDataPickerSheetV2(
            listValues: list,
            currentValue: _createCubit.state.currentDateLeaveType,
            title: S.of(context).day_off_type,
          ),
    );
    if (item == null) return;
    logger.d("Item selectedddd :::: ${item.code}");
    if (item.code.toString() == "7") {
      // nghỉ có lương , tối đa backdate 3 ngày
      // nghỉ ko lương , ko required
      if ((DateTime.now()
                  .difference(_createCubit.state.fromDateTime ?? DateTime.now())
                  .inDays >
              3) ||
          (DateTime.now()
                  .difference(_createCubit.state.toDateTime ?? DateTime.now())
                  .inDays >
              3)) {
        AppSnackBar.showError(
          title: "Cảnh báo",
          message: "Nghỉ phép có lương xin phép tối đa trước 3 ngày",
        );
      } else {
        _createCubit.onChangeDateTypeLeaves(item);
      }
    } else {
      _createCubit.onChangeDateTypeLeaves(item);
    }
  }

  // Bỏ nền sáng mặc định của khung nút ở đáy (Scaffold.bottomSheet) → chỉ còn nút.
  @override
  Widget build(BuildContext context) =>
      BottomSheetBarThemeV2(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<CreateOnLeaveCubit, CreateOnLeaveState>(
      bloc: _createCubit,
      listenWhen: (prev, cur) =>
          prev.createStatus != cur.createStatus ||
          prev.updateStatus != cur.updateStatus,
      buildWhen:
          (prev, cur) =>
              prev.createStatus != cur.createStatus ||
              prev.updateStatus != cur.updateStatus,
      listener: (context, state) {
        if (state.createStatus == LoadStatus.LOADING ||
            state.updateStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        } else if (state.createStatus == LoadStatus.SUCCESS ||
            state.updateStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          AppSnackBar.showInfo(
            title: s.success,
            message:
                widget.isEdit == true
                    ? s.day_off_update_success
                    : s.day_off_create_success,
          );

          _createCubit.resetStatus();
          _saved = true; // chặn bấm Lưu lần nữa trong lúc chờ đóng màn (300 ms)
          final navigator = Navigator.of(context);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            navigator.pop(true);
          });
        } else if (state.createStatus == LoadStatus.FAILURE ||
            state.updateStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);

          AppSnackBar.showError(title: s.warning, message: state.errMsg);
          _createCubit.resetStatus();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTokensV2.bgDeep,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.maybePop(context),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTokensV2.fg,
                size: 20,
              ),
            ),
            title: Text(
              widget.isEdit == true
                  ? s.day_off_edit_title
                  : s.day_off_create_title,
              style: AppTokensV2.title,
            ),
            centerTitle: false,
            actions: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _goNotification,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: AppTokensV2.surfaceStrong,
                    border: Border.all(color: AppTokensV2.border),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 20,
                    color: AppTokensV2.fgSoft,
                  ),
                ),
              ),
            ],
          ),
          body: AmbientBackgroundV2(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  18,
                  MediaQuery.of(context).padding.top > 0 ? 8 : 18,
                  18,
                  120,
                ),
                child: StaggerRevealV2(
                  index: 0,
                  child: GlassCardV2(
                    radius: AppTokensV2.radius,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _dateTypeField,
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _fromDateField),
                            const SizedBox(width: 12),
                            Expanded(child: _toDateField),
                          ],
                        ),
                        _leaveDaysList,
                        const SizedBox(height: 16),
                        _totalDaysField,
                        const SizedBox(height: 16),
                        _remainLeaveField,
                        const SizedBox(height: 16),
                        _reasonField,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomSheet: KeyboardDoneBarV2(child: _bottomSheet),
        );
      },
    );
  }

  Widget get _dateTypeField {
    return BlocBuilder<CreateOnLeaveCubit, CreateOnLeaveState>(
      bloc: _createCubit,
      buildWhen:
          (prev, cur) =>
              prev.leaveDateType != cur.leaveDateType ||
              prev.listDateTypeLeaves != cur.listDateTypeLeaves ||
              prev.getTypeStatus != cur.getTypeStatus,
      builder: (context, state) {
        final value = state.leaveDateType ?? "";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(S.of(context).day_off_type, style: AppTokensV2.caption),
                const SizedBox(width: 4),
                Text(
                  "*",
                  style: TextStyle(color: AppTokensV2.danger, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if ((state.listDateTypeLeaves ?? []).isEmpty &&
                    state.getTypeStatus == LoadStatus.FAILURE) {
                  _createCubit.getListDateTypeLeaves();
                  return;
                }
                _openDateTypeLeaveBottomSheet(state.listDateTypeLeaves ?? []);
              },
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTokensV2.surfaceStrong,
                  borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
                  border: Border.all(color: AppTokensV2.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value.isNotEmpty ? value : S.of(context).day_off_type_hint,
                        style: value.isNotEmpty
                            ? AppTokensV2.body
                            : AppTokensV2.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (state.getTypeStatus == LoadStatus.LOADING)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTokensV2.accent,
                        ),
                      )
                    else if (state.getTypeStatus == LoadStatus.FAILURE)
                      GestureDetector(
                        onTap: () => _createCubit.getListDateTypeLeaves(),
                        child: Icon(
                          Icons.refresh,
                          size: 18,
                          color: AppTokensV2.accent,
                        ),
                      )
                    else
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppTokensV2.fgMuted,
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget get _fromDateField {
    return BlocBuilder<CreateOnLeaveCubit, CreateOnLeaveState>(
      bloc: _createCubit,
      buildWhen:
          (prev, cur) =>
              prev.fromDate != cur.fromDate || prev.fromDateTime != cur.fromDateTime,
      builder: (context, state) {
        fromDateController.text = state.fromDate ?? "";
        return _dateBox(
          title: S.of(context).day_off_from,
          value: state.fromDate ?? "",
          onTap: () {
            HapticFeedback.selectionClick();
            _showDatePicker(
              defaultValue: state.fromDateTime ?? _initFromDate,
              onConfirm: (selectedDate) {
                _selectedDate = selectedDate;
                final s = S.of(context);
                if (_createCubit.state.toDateTime != null) {
                  if (_createCubit.state.toDateTime!
                          .difference(selectedDate)
                          .inDays <
                      0) {
                    AppSnackBar.showError(
                      title: s.warning,
                      message: s.day_off_warning_smaller,
                    );
                  } else {
                    _createCubit.setFromDate(selectedDate);
                    final allDays = AppDateUtils.daysBetween(
                      selectedDate,
                      _createCubit.state.toDateTime!,
                    );

                    final newList =
                        allDays
                            .map(
                              (e) => LeaveDayEntity(
                                date: _formatYyyyMmDd(e),
                                type: 'full',
                              ),
                            )
                            .toList();

                    listDays = List.from(newList);

                    _createCubit.onChangeListLeaveDays(
                      List<LeaveDayEntity>.from(newList),
                    );

                    final total = _sumDaysByType(listDays);
                    totalDaysController.text = _fmtTotal(total);
                  }
                } else {
                  // nghỉ có lương , tối đa backdate 3 ngày
                  // nghỉ ko lương , ko required
                  if (_createCubit.state.currentDateLeaveType?.id == 7) {
                    if (DateTime.now().difference(selectedDate).inDays > 3) {
                      AppSnackBar.showError(
                        title: s.warning,
                        message: "Nghỉ phép có lương xin phép tối đa trước 3 ngày",
                      );
                    } else {
                      _createCubit.setFromDate(selectedDate);
                      listDays.clear();
                      _createCubit.onChangeListLeaveDays(listDays);
                      totalDaysController.text = '0';
                    }
                  } else {
                    _createCubit.setFromDate(selectedDate);
                    listDays.clear();
                    _createCubit.onChangeListLeaveDays(listDays);
                    totalDaysController.text = '0';
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  Widget get _toDateField {
    return BlocBuilder<CreateOnLeaveCubit, CreateOnLeaveState>(
      bloc: _createCubit,
      buildWhen:
          (prev, cur) => prev.toDate != cur.toDate || prev.toDateTime != cur.toDateTime,
      builder: (context, state) {
        toDateController.text = state.toDate ?? "";
        return _dateBox(
          title: S.of(context).day_off_to,
          value: state.toDate ?? "",
          onTap: () {
            HapticFeedback.selectionClick();
            _showDatePicker(
              defaultValue: state.toDateTime ?? _initToDate,
              onConfirm: (selectedDate) {
                _selectedDate = selectedDate;
                final s = S.of(context);
                if (_createCubit.state.fromDateTime != null) {
                  if (selectedDate
                          .difference(_createCubit.state.fromDateTime!)
                          .inDays <
                      0) {
                    AppSnackBar.showError(
                      title: s.warning,
                      message: s.day_off_warning_greater,
                    );
                  } else {
                    _createCubit.setToDate(selectedDate);
                    final allDays = AppDateUtils.daysBetween(
                      _createCubit.state.fromDateTime!,
                      selectedDate,
                    );

                    final newList =
                        allDays
                            .map(
                              (e) => LeaveDayEntity(
                                date: _formatYyyyMmDd(e),
                                type: 'full',
                              ),
                            )
                            .toList();

                    listDays = List.from(newList);

                    _createCubit.onChangeListLeaveDays(
                      List<LeaveDayEntity>.from(newList),
                    );

                    final total = _sumDaysByType(listDays);
                    totalDaysController.text = _fmtTotal(total);
                  }
                } else {
                  // nghỉ có lương , tối đa backdate 3 ngày
                  // nghỉ ko lương , ko required
                  if (_createCubit.state.currentDateLeaveType?.id == 7) {
                    if (DateTime.now().difference(selectedDate).inDays > 3) {
                      AppSnackBar.showError(
                        title: s.warning,
                        message: "Nghỉ phép có lương xin phép tối đa trước 3 ngày",
                      );
                    } else {
                      _createCubit.setToDate(selectedDate);
                      listDays.clear();
                      _createCubit.onChangeListLeaveDays(listDays);
                      totalDaysController.text = '0';
                    }
                  } else {
                    _createCubit.setToDate(selectedDate);
                    listDays.clear();
                    _createCubit.onChangeListLeaveDays(listDays);
                    totalDaysController.text = '0';
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _dateBox({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTokensV2.caption),
            const SizedBox(width: 4),
            Text(
              "*",
              style: TextStyle(color: AppTokensV2.danger, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
              border: Border.all(color: AppTokensV2.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: value.isNotEmpty ? AppTokensV2.body : AppTokensV2.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppTokensV2.fgMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget get _leaveDaysList {
    return BlocBuilder<CreateOnLeaveCubit, CreateOnLeaveState>(
      bloc: _createCubit,
      buildWhen: (prev, cur) => prev.listLeaveDays != cur.listLeaveDays,
      builder: (context, state) {
        final days = state.listLeaveDays;
        if (days.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: days.length > 3 ? 300 : days.length * 90,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children:
                  days.map((entity) {
                    return OnleaveDayItemWidgetV2(
                      date: entity.date ?? "",
                      type:
                          (entity.type?.isNotEmpty ?? false)
                              ? (entity.type ?? 'full')
                              : 'full',
                      onTypeChanged: (newType) {
                        final idx = listDays.indexWhere(
                          (e) => e.date == entity.date,
                        );
                        if (idx != -1) {
                          listDays[idx] = LeaveDayEntity(
                            date: listDays[idx].date,
                            type: newType,
                          );
                          _createCubit.onChangeListLeaveDays(
                            List<LeaveDayEntity>.from(listDays),
                          );

                          final total = _sumDaysByType(listDays);
                          totalDaysController.text = _fmtTotal(total);
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget get _totalDaysField {
    return BlocBuilder<CreateOnLeaveCubit, CreateOnLeaveState>(
      bloc: _createCubit,
      buildWhen:
          (prev, cur) =>
              prev.leaveDays != cur.leaveDays ||
              prev.fromDateTime != cur.fromDateTime ||
              prev.toDateTime != cur.toDateTime,
      builder: (context, state) {
        return _readOnlyField(
          title: S.of(context).day_off_total,
          controller: totalDaysController,
        );
      },
    );
  }

  Widget get _remainLeaveField {
    leavesDaysController.text =
        GlobalData.instance.userProfile?.remainLeave
            .toString()
            .replaceAll(".0", "") ??
        "";
    return _readOnlyField(
      title: S.of(context).day_off_left,
      controller: leavesDaysController,
    );
  }

  Widget _readOnlyField({
    required String title,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTokensV2.caption),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 46),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTokensV2.surface,
            borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
            border: Border.all(color: AppTokensV2.border),
          ),
          child: Text(controller.text, style: AppTokensV2.body),
        ),
      ],
    );
  }

  Widget get _reasonField {
    return BlocBuilder<CreateOnLeaveCubit, CreateOnLeaveState>(
      bloc: _createCubit,
      buildWhen: (prev, cur) => prev.reason != cur.reason,
      builder: (context, state) {
        reasonController.text = state.reason ?? "";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(S.of(context).day_off_reason, style: AppTokensV2.caption),
                const SizedBox(width: 4),
                Text(
                  "*",
                  style: TextStyle(color: AppTokensV2.danger, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppTokensV2.surfaceStrong,
                borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
                border: Border.all(color: AppTokensV2.border),
              ),
              child: TextField(
                scrollPadding: kFormFieldScrollPaddingV2,
                controller: reasonController,
                maxLength: InputLimits.requestNote,
                buildCounter: inputCounterV2(),
                maxLines: 5,
                style: AppTokensV2.body,
                cursorColor: AppTokensV2.accent,
                onChanged: (value) => _createCubit.onChangeReason(value),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  hintText: S.of(context).day_off_reason_hint,
                  hintStyle: AppTokensV2.caption,
                ),
              ),
            ),
            BlankOnlyHintV2(
              controller: reasonController,
              fieldName: S.of(context).day_off_reason,
            ),
          ],
        );
      },
    );
  }

  Widget get _bottomSheet {
    return BlocBuilder<CreateOnLeaveCubit, CreateOnLeaveState>(
      bloc: _createCubit,
      buildWhen:
          (prev, cur) =>
              prev.reason != cur.reason ||
              prev.leaveDateType != cur.leaveDateType ||
              prev.fromDate != cur.fromDate ||
              prev.toDate != cur.toDate,
      builder: (context, state) {
        bool isEnable = false;
        // Lý do chỉ toàn khoảng trắng tính là chưa nhập (trước đây gửi lên → lỗi SQL).
        if (!Validator.isBlank(state.reason) &&
            (state.leaveDateType ?? "").isNotEmpty &&
            (state.fromDate ?? "").isNotEmpty &&
            (state.toDate ?? "").isNotEmpty) {
          isEnable = true;
        }
        return Container(
          margin: EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: MediaQuery.of(context).padding.bottom + 18,
            top: 0,
          ),
          child:
              isEnable
                  ? PrimaryButtonV2(
                    label: S.of(context).save,
                    onTap: () {
                      if (_saved) return; // đã lưu xong, đang đóng màn
                      (widget.isEdit ?? false) ? _doUpdate() : _doCreate();
                    },
                  )
                  : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppTokensV2.surfaceStrong,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppTokensV2.border),
                    ),
                    child: Text(
                      S.of(context).save,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTokensV2.fgMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
        );
      },
    );
  }

  void _doUpdate() {
    if (_createCubit.state.currentDateLeaveType?.id == 7) {
      if ((GlobalData.instance.userProfile?.remainLeave ?? 0) <= 0 ||
          (GlobalData.instance.userProfile?.remainLeave ?? 0) <
              double.parse(totalDaysController.text)) {
        AppSnackBar.showWarning(
          title: S.of(context).warning,
          message: S.of(context).day_off_notEnough,
        );
      } else {
        _showUpdate();
      }
    } else {
      _showUpdate();
    }
  }

  void _showUpdate() {
    _showDialog(
      title: S.of(context).confirm,
      message:
          "${S.of(context).day_off_confirm_update_sub1} ${S.of(context).day_off_confirm_update_sub2}",
      success: true,
      onConfirm: () {
        _createCubit.updateLeaveDay(widget.detailEntity?.id ?? 0);
        Navigator.of(context).maybePop();
      },
    );
  }

  void _doCreate() {
    if (_createCubit.state.currentDateLeaveType?.id == 7) {
      if ((GlobalData.instance.userProfile?.remainLeave ?? 0) <= 0 ||
          (GlobalData.instance.userProfile?.remainLeave ?? 0) <
              double.parse(totalDaysController.text)) {
        AppSnackBar.showWarning(
          title: S.of(context).warning,
          message: S.of(context).day_off_notEnough,
        );
      } else {
        _createCubit.createLeaveDay();
      }
    } else {
      _createCubit.createLeaveDay();
    }
  }
}

/// Bottom sheet tối để chọn 1 [MasterDataItem] (loại ngày nghỉ). Tương đương
/// [CommonBottomSheet] bản cũ nhưng theo hệ thiết kế v2 — cùng trả về giá trị
/// đã chọn (hoặc `currentValue` khi bấm đóng) qua `Navigator.pop`.
class _MasterDataPickerSheetV2 extends StatelessWidget {
  final List<MasterDataItem>? listValues;
  final MasterDataItem? currentValue;
  final String? title;

  const _MasterDataPickerSheetV2({
    this.listValues,
    this.currentValue,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final items = listValues ?? [];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 44),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    title ?? "",
                    textAlign: TextAlign.center,
                    style: AppTokensV2.section,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 10),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context, currentValue),
                  child: Icon(
                    Icons.close,
                    size: 22,
                    color: AppTokensV2.fgSoft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, thickness: 1, color: AppTokensV2.border),
          Flexible(
            child:
                items.isEmpty
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          S.of(context).bt_empty,
                          style: AppTokensV2.captionStrong,
                        ),
                      ),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: items.length,
                      separatorBuilder:
                          (_, __) => Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTokensV2.border,
                          ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = currentValue?.code == item.code;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 2,
                          ),
                          title: Text(
                            item.text ?? "",
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  isSelected
                                      ? AppTokensV2.accent
                                      : AppTokensV2.fg,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                            ),
                          ),
                          trailing:
                              isSelected
                                  ? Icon(
                                    Icons.check_rounded,
                                    color: AppTokensV2.accent,
                                    size: 20,
                                  )
                                  : null,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(context, item);
                          },
                        );
                      },
                    ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
