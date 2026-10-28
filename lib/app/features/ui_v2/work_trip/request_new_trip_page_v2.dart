import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/widgets/input_counter_v2.dart';
import 'package:pm_app/app/core/commons/input_limits.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/keyboard_done_bar_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/schedule_entity.dart';
import 'package:pm_app/app/data/models/entities/user_entity.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/task/bottomsheet/select_user_bottom_sheet.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_cubit.dart';
import 'package:pm_app/app/features/ui_v2/on_leave/widget/onleave_day_item_widget_v2.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_assets.dart';
import 'package:pm_app/app/core/theme_v2/widgets/bottom_sheet_bar_theme_v2.dart';

/// Màn Tạo/Sửa đơn công tác — phiên bản giao diện tối (v2).
///
/// Hành vi/nghiệp vụ giữ NGUYÊN bản cũ [RequestNewTripPage]: tái dùng
/// [WorkTripCubit] qua GetIt (không tạo mới), cùng thứ tự khởi tạo
/// (getListUsers nếu rỗng, prefill khi sửa), cùng luật chọn ngày (chặn từ
/// ngày > đến ngày, chặn ngày trong quá khứ khi tạo mới), cùng luật bật/khoá
/// nút lưu (cần strUsers/fromDate/toDate/note), cùng cách xử lý
/// createStatus/updateStatus. Chỉ đổi trình bày sang hệ thiết kế v2.
///
/// Bản gốc dùng [SelectUserBottomSheet] (bottomsheet chọn nhân sự, không
/// phải widget hàng/list dưới thư mục `widget/`) — tái dùng trực tiếp, không
/// tạo bản v2 riêng, đúng quy ước dùng chung cho dialog/bottomsheet.
class RequestNewTripPageV2 extends StatefulWidget {
  bool? isEdit;
  WorkTripEntity? detailEntity;

  RequestNewTripPageV2({super.key, this.isEdit, this.detailEntity});

  @override
  State<RequestNewTripPageV2> createState() => _RequestNewTripPageV2State();
}

class _RequestNewTripPageV2State extends State<RequestNewTripPageV2> {
  final _cubit = GetIt.I.get<WorkTripCubit>();

  TextEditingController staffsController = TextEditingController();
  TextEditingController totalStaffsController = TextEditingController();
  TextEditingController createdByController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  List<ScheduleEntity> listDays = [];

  DateTime? _initFromDate;
  DateTime? _initToDate;
  DateTime? _selectedDate;

  @override
  void initState() {
    if ((_cubit.state.listUsers ?? []).isEmpty) {
      _cubit.getListUsers();
    }

    if (widget.isEdit ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillForEdit();
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _cubit.onResetStatus();
    _cubit.onResetData();
    super.dispose();
  }

  List<ScheduleEntity> _buildDaysForEdit({
    required DateTime from,
    required DateTime to,
    required List<dynamic>? lineSchedules,
  }) {
    final List<ScheduleEntity> out = [];

    if (lineSchedules != null && lineSchedules.isNotEmpty) {
      for (final e in lineSchedules) {
        if (e is ScheduleEntity) {
          final d = _tryParseIso(e.dateFrom);
          if (d != null) {
            out.add(
              ScheduleEntity(
                dateFrom: _formatYyyyMmDd(d),
                dateTo: _formatYyyyMmDd(d),
                type: (e.type ?? 'full'),
              ),
            );
          }
        } else if (e is Map) {
          final d = _tryParseIso(e['date_from'] as String?);
          final t = (e['type'] as String?) ?? 'full';
          if (d != null) {
            out.add(
              ScheduleEntity(
                dateFrom: _formatYyyyMmDd(d),
                dateTo: _formatYyyyMmDd(d),
                type: t,
              ),
            );
          }
        }
      }
      if (out.isNotEmpty) return out;
    }

    final allDays = AppDateUtils.daysBetween(from, to);
    for (final d in allDays) {
      out.add(
        ScheduleEntity(
          dateFrom: _formatYyyyMmDd(d),
          dateTo: _formatYyyyMmDd(d),
          type: 'full',
        ),
      );
    }
    return out;
  }

  Future<void> _prefillForEdit() async {
    final detail = widget.detailEntity;
    if (!(widget.isEdit ?? false) || detail == null) return;

    final from = _tryParseIso(detail.fromDate ?? "");
    final to = _tryParseIso(detail.toDate);

    final note = detail.note ?? "";

    final schedules = detail.schedules ?? [];
    if (from != null) {
      _cubit.setFromDate(from);
      fromDateController
          .text = AppDateUtils.changeIso8601StringToDateTimeString(
        from.toIso8601String(),
      );
    }
    if (to != null) {
      _cubit.setToDate(to);
      toDateController.text = AppDateUtils.changeIso8601StringToDateTimeString(
        to.toIso8601String(),
      );
    }

    noteController.text = note;
    _cubit.onChangeNote(note);

    List<UserEntity> users = detail.employees ?? [];
    if (users.isNotEmpty) {
      _cubit.onChangeCurrentUsers(users);
      _cubit.onChangeUser(
        (detail.employees ?? []).map((u) => u.name).join(','),
      );
    }

    if (from != null && to != null) {
      listDays = _buildDaysForEdit(
        from: from,
        to: to,
        lineSchedules: schedules,
      );
      _cubit.onChangeListSchedulesDays(listDays);
    } else {
      listDays = [];
      _cubit.onChangeListSchedulesDays(listDays);
    }
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

  Future<void> _openUsersBottomSheet(List<UserEntity> list) async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
      builder:
          (BuildContext context) => SelectUserBottomSheet(
            listUsers: _cubit.state.listUsers ?? [],
            listCurrentUsers: _cubit.state.currentUsers ?? [],
            onUsersSelected: (users) {
              String user = users.map((sc) => sc.name).toList().join(",");
              if (user != _cubit.state.strUsers) {
                _cubit.onChangeUser(user);
                _cubit.onChangeCurrentUsers(users);
              }
            },
          ),
    );
  }

  String _formatYyyyMmDd(DateTime d) {
    return AppDateUtils().formatIsoToYyyyMmDd(d.toIso8601String());
  }

  DateTime _dateOnly(DateTime value) => DateUtils.dateOnly(value);

  bool _isBeforeDay(DateTime left, DateTime right) {
    return _dateOnly(left).isBefore(_dateOnly(right));
  }

  bool _isBeforeToday(DateTime value) {
    return _dateOnly(value).isBefore(_dateOnly(DateTime.now()));
  }

  DateTime? _tryParseIso(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }

  // Bỏ nền sáng mặc định của khung nút ở đáy (Scaffold.bottomSheet) → chỉ còn nút.
  @override
  Widget build(BuildContext context) =>
      BottomSheetBarThemeV2(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      listener: (context, state) async {
        Future<void> postFrame(VoidCallback fn) async {
          if (!context.mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            fn();
          });
        }

        final hasMutationState =
            state.createStatus != LoadStatus.INITIAL ||
            state.updateStatus != LoadStatus.INITIAL;

        if (hasMutationState && !_handlingAction) return;

        final isLoading =
            state.createStatus == LoadStatus.LOADING ||
            state.updateStatus == LoadStatus.LOADING;

        if (isLoading) {
          LoadingOverlay.show(context);
          return;
        }

        LoadingOverlay.hide(context);

        if (state.createStatus == LoadStatus.SUCCESS) {
          AppSnackBar.showInfo(
            title: "Thành công",
            message: state.errMsg ?? "Phiếu công tác được tạo thành công!",
          );
          _handlingAction = false;

          await postFrame(() {
            Navigator.of(context).pop(true);
            _cubit.onResetStatus();
          });
          return;
        }

        if (state.createStatus == LoadStatus.FAILURE) {
          AppSnackBar.showError(
            title: "Cảnh báo",
            message: state.errMsg ?? "Có lỗi xảy ra, vui lòng thử lại sau",
          );
          _handlingAction = false;
          _cubit.onResetStatus();
          return;
        }

        if (state.updateStatus == LoadStatus.SUCCESS) {
          AppSnackBar.showInfo(
            title: "Thành công",
            message: state.errMsg ?? "",
          );
          _handlingAction = false;

          await postFrame(() {
            int count = 0;
            Navigator.of(context).popUntil((route) {
              count++;
              return count >= 2;
            });
            _cubit.onResetStatus();
          });

          return;
        }

        if (state.updateStatus == LoadStatus.FAILURE) {
          AppSnackBar.showError(
            title: "Cảnh báo",
            message: state.errMsg ?? "Có lỗi xảy ra, vui lòng thử lại sau",
          );
          _handlingAction = false;
          _cubit.onResetStatus();
          return;
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
              (widget.isEdit ?? false) ? s.bt_updateTitle : s.bt_createTitle,
              style: AppTokensV2.title,
            ),
            centerTitle: false,
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
                        _staffsField,
                        const SizedBox(height: 16),
                        _totalStaffsField,
                        const SizedBox(height: 16),
                        _createdByField,
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _fromDateField),
                            const SizedBox(width: 12),
                            Expanded(child: _toDateField),
                          ],
                        ),
                        _scheduleDaysList,
                        const SizedBox(height: 16),
                        _addressField,
                        const SizedBox(height: 16),
                        _noteField,
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

  bool _handlingAction = false;

  Widget get _staffsField {
    return BlocBuilder<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      buildWhen:
          (prev, cur) =>
              prev.strUsers != cur.strUsers ||
              prev.currentUsers != cur.currentUsers ||
              prev.listUsers != cur.listUsers,
      builder: (context, state) {
        staffsController.text = state.strUsers ?? "";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(S.of(context).bt_titleEmployee, style: AppTokensV2.caption),
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
              onTap: () => _openUsersBottomSheet(state.listUsers ?? []),
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
                        staffsController.text,
                        style:
                            staffsController.text.isNotEmpty
                                ? AppTokensV2.body
                                : AppTokensV2.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

  Widget get _totalStaffsField {
    return BlocBuilder<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      buildWhen: (prev, cur) => prev.currentUsers != cur.currentUsers,
      builder: (context, state) {
        totalStaffsController.text =
            (state.currentUsers ?? []).isNotEmpty
                ? (state.currentUsers ?? []).length.toString()
                : "";
        return _readOnlyField(
          title: S.of(context).bt_totalEmployee,
          value: totalStaffsController.text,
        );
      },
    );
  }

  Widget get _createdByField {
    createdByController.text = GlobalData.instance.userProfile?.name ?? "";
    return _readOnlyField(
      title: S.of(context).bt_createEmployee,
      value: createdByController.text,
    );
  }

  Widget get _fromDateField {
    return BlocBuilder<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      buildWhen:
          (prev, cur) =>
              prev.fromDate != cur.fromDate || prev.fromDateTime != cur.fromDateTime,
      builder: (context, state) {
        fromDateController.text = state.fromDate ?? "";
        return _dateBox(
          title: S.of(context).bt_formDate,
          value: state.fromDate ?? "",
          onTap: () {
            HapticFeedback.selectionClick();
            _showDatePicker(
              defaultValue: state.fromDateTime ?? _initFromDate,
              onConfirm: (selectedDate) {
                _selectedDate = selectedDate;
                if (_cubit.state.toDateTime != null) {
                  if (_isBeforeDay(
                    _cubit.state.toDateTime!,
                    selectedDate,
                  )) {
                    AppSnackBar.showError(
                      title: "Cảnh báo",
                      message: "Từ ngày không được lớn hơn đến ngày",
                    );
                  } else {
                    _cubit.setFromDate(selectedDate);
                    final allDays = AppDateUtils.daysBetween(
                      selectedDate,
                      _cubit.state.toDateTime!,
                    );
                    listDays.clear();
                    for (final e in allDays) {
                      listDays.add(
                        ScheduleEntity(
                          dateFrom: _formatYyyyMmDd(e),
                          dateTo: _formatYyyyMmDd(e),
                          type: 'full',
                          address: _cubit.state.address ?? "",
                          isOvernight: _cubit.state.isOvernight,
                          keepLunchAllowance: false,
                        ),
                      );
                    }
                    _cubit.onChangeListSchedulesDays(listDays);
                  }
                } else {
                  if (_isBeforeToday(selectedDate)) {
                    AppSnackBar.showError(
                      title: "Cảnh báo",
                      message: "Từ ngày không được nhỏ hơn hôm nay",
                    );
                  } else {
                    _cubit.setFromDate(selectedDate);
                    listDays.clear();
                    _cubit.onChangeListSchedulesDays(listDays);
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
    return BlocBuilder<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      buildWhen:
          (prev, cur) => prev.toDate != cur.toDate || prev.toDateTime != cur.toDateTime,
      builder: (context, state) {
        toDateController.text = state.toDate ?? "";
        return _dateBox(
          title: S.of(context).bt_toDate,
          value: state.toDate ?? "",
          onTap: () {
            HapticFeedback.selectionClick();
            _showDatePicker(
              defaultValue: state.toDateTime ?? _initToDate,
              onConfirm: (selectedDate) {
                _selectedDate = selectedDate;
                if (_cubit.state.fromDateTime != null) {
                  if (_isBeforeDay(
                    selectedDate,
                    _cubit.state.fromDateTime!,
                  )) {
                    AppSnackBar.showError(
                      title: "Cảnh báo",
                      message: "Từ ngày không được lớn hơn đến ngày",
                    );
                  } else {
                    _cubit.setToDate(selectedDate);
                    final allDays = AppDateUtils.daysBetween(
                      _cubit.state.fromDateTime!,
                      selectedDate,
                    );
                    listDays.clear();
                    for (final e in allDays) {
                      listDays.add(
                        ScheduleEntity(
                          dateFrom: _formatYyyyMmDd(e),
                          dateTo: _formatYyyyMmDd(e),
                          type: 'full',
                          address: _cubit.state.address ?? "",
                          isOvernight: _cubit.state.isOvernight,
                          keepLunchAllowance: false,
                        ),
                      );
                    }
                    _cubit.onChangeListSchedulesDays(listDays);
                  }
                } else {
                  if (_isBeforeToday(selectedDate)) {
                    AppSnackBar.showError(
                      title: "Cảnh báo",
                      message: "Đến ngày không được nhỏ hơn hôm nay",
                    );
                  } else {
                    _cubit.setToDate(selectedDate);
                    listDays.clear();
                    _cubit.onChangeListSchedulesDays(listDays);
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  Widget get _scheduleDaysList {
    return BlocBuilder<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      buildWhen: (prev, cur) => prev.listScheduleDays != cur.listScheduleDays,
      builder: (context, state) {
        final days = state.listScheduleDays ?? [];
        if (days.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children:
                days.map((entity) {
                  return OnleaveDayItemWidgetV2(
                    date: entity.dateFrom ?? "",
                    type:
                        (entity.type?.isNotEmpty ?? false)
                            ? (entity.type ?? 'full')
                            : 'full',
                    onTypeChanged: (newType) {
                      final idx = listDays.indexWhere(
                        (e) => e.dateFrom == entity.dateFrom,
                      );
                      if (idx != -1) {
                        listDays[idx] = ScheduleEntity(
                          dateFrom: listDays[idx].dateFrom,
                          dateTo: listDays[idx].dateTo,
                          type: newType,
                        );
                        _cubit.onChangeListSchedulesDays(
                          List<ScheduleEntity>.from(listDays),
                        );
                      }
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  Widget get _addressField {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).bt_address, style: AppTokensV2.caption),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
            border: Border.all(color: AppTokensV2.border),
          ),
          child: TextField(
            scrollPadding: kFormFieldScrollPaddingV2,
            controller: addressController,
            maxLength: InputLimits.address,
            buildCounter: inputCounterV2(always: false),
            style: AppTokensV2.body,
            cursorColor: AppTokensV2.accent,
            onChanged: (value) => _cubit.onChangeAddress(value),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget get _noteField {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(S.of(context).bt_notes, style: AppTokensV2.caption),
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
            controller: noteController,
            maxLength: InputLimits.requestNote,
            buildCounter: inputCounterV2(),
            maxLines: 5,
            style: AppTokensV2.body,
            cursorColor: AppTokensV2.accent,
            onChanged: (value) => _cubit.onChangeNote(value),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              hintText: S.of(context).bt_hintNotes,
              hintStyle: AppTokensV2.caption,
            ),
          ),
        ),
      ],
    );
  }

  Widget _readOnlyField({required String title, required String value}) {
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
          child: Text(value, style: AppTokensV2.body),
        ),
      ],
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

  Widget get _bottomSheet {
    return BlocBuilder<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      buildWhen:
          (prev, cur) =>
              prev.strUsers != cur.strUsers ||
              prev.fromDate != cur.fromDate ||
              prev.toDate != cur.toDate ||
              prev.note != cur.note,
      builder: (context, state) {
        bool isEnable = false;
        if ((state.strUsers ?? "").isNotEmpty &&
            (state.fromDate ?? "").isNotEmpty &&
            (state.toDate ?? "").isNotEmpty &&
            (state.note ?? "").isNotEmpty) {
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
                    label: S.of(context).bt_btnSave,
                    onTap: () {
                      (widget.isEdit ?? false) ? _showUpdate() : _doCreate();
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
                      S.of(context).bt_btnSave,
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

  void _doCreate() {
    _handlingAction = true;
    _cubit.createNewWorkTrip();
  }

  void _showUpdate() {
    _showDialog(
      title: S.of(context).confirm,
      message:
          "Thông tin sẽ được thay đổi. Bạn chắc chắn "
          "muốn thay đổi thông tin này?",
      success: true,
      onConfirm: () {
        _handlingAction = true;
        _cubit.updateWorkTrip(widget.detailEntity?.id ?? 0);
        Navigator.of(context).maybePop();
      },
    );
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
}
