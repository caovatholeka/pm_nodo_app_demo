import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/create_on_leave_cubit.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:pm_app/app/data/models/entities/leave_day_entity.dart';
import 'package:pm_app/app/features/ui/on_leave/widget/onleave_day_item_widget.dart';
import 'package:pm_app/app/features/widgets/common_bottom_sheet.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/generated/l10n.dart';
import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/entities/on_leave_entity.dart';
import '../../../data/models/enums/load_status.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/input_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/primary_button.dart';

class CreateNewLeavePage extends StatefulWidget {
  bool? isEdit;
  OnLeaveEntity? detailEntity;

  CreateNewLeavePage({super.key, this.isEdit, this.detailEntity});

  @override
  State<CreateNewLeavePage> createState() => _CreateNewLeavePageState();
}

class _CreateNewLeavePageState extends State<CreateNewLeavePage> {
  final _dateTypeKey = GlobalKey<FormState>();
  final _fromDateKey = GlobalKey<FormState>();
  final _toDateKey = GlobalKey<FormState>();
  final _leaveDatesKey = GlobalKey<FormState>();
  final _typeKey = GlobalKey<FormState>();
  final _reasonKey = GlobalKey<FormState>();

  TextEditingController leavesDaysController = TextEditingController();
  TextEditingController dateTypeController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController leaveDatesController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController totalDaysController = TextEditingController(text: '0');

  final _createCubit = GetIt.I.get<CreateOnLeaveCubit>();
  DateTime? _initFromDate;
  DateTime? _initToDate;
  DateTime? _selectedDate;

  final ScrollController _scrollController = ScrollController();
  List<LeaveDayEntity> listDays = [];
  late var totalLeaveDays = 0;

  @override
  void initState() {
    // _createCubit.initData(widget.detailEntity ?? OnLeaveEntity());
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
              LeaveDayEntity(
                date: _formatYyyyMmDd(d), //d.toIso8601String(),
                type: (e.type ?? 'full'),
              ),
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
      out.add(LeaveDayEntity(date:_formatYyyyMmDd(d), type: 'full'));
    }
    return out;
  }

  Future<void> _prefillForEdit() async {
    final detail = widget.detailEntity;
    if (!(widget.isEdit ?? false) || detail == null) return;

    String holidayStatus = detail.holidayStatus ?? "";
    final holidayStatusId = detail.holidayStatusId ?? 0;

    final from = _tryParseIso(detail.dateFrom ?? "");
    final to = _tryParseIso(detail.dateTo);

    final description = detail.description ?? "";
    // // final remainLeave = detail.remainLeave ?? 0;
    //
    // // final lineIds =
    // //     (detail as dynamic).lineIds as List<dynamic>? ?? (detail as dynamic).line_ids as List<dynamic>?;
    final lineIds = detail.lineIds ?? [];
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

    // danh sach ngay nghi
    if (from != null && to != null) {
      listDays = _buildDaysForEdit(from: from, to: to, lineIds: lineIds);
      _createCubit.onChangeListLeaveDays(listDays);

      // leave type
      final total = _sumDaysByType(listDays);
      totalDaysController.text = _fmtTotal(total);
      totalLeaveDays = int.parse(_fmtTotal(total));
    } else {
      listDays = [];
      _createCubit.onChangeListLeaveDays(listDays);
      totalDaysController.text = '0';
      totalLeaveDays = 0;
    }

    //lý do
    reasonController.text = description;
    _createCubit.onChangeReason(description);

    // Loại ngày nghỉ
    if (holidayStatus.isNotEmpty) {
      dateTypeController.text = holidayStatus;
      try {
        _createCubit.onChangeDateTypeLeaves(
          MasterDataItem(text: holidayStatus, code: holidayStatusId.toString(),id: holidayStatusId),
        );
      } catch (e) {
        logger.d(e);
      }
    }
  }

  _goNotification() {
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

  _showDatePicker({DateTime? defaultValue, DateChangedCallback? onConfirm}) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      onConfirm: onConfirm,
      currentTime: defaultValue ?? DateTime.now(),
      locale: LocaleType.vi,
    );
  }

  _openDateTypeLeaveBottomSheet(List<MasterDataItem> list) async {
    final item = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
      builder:
          (BuildContext context) => CommonBottomSheet(
            listValues: list,
            currentValue: _createCubit.state.currentDateLeaveType,
            title: S.of(context).day_off_type,
          ),
    );
    _createCubit.onChangeDateTypeLeaves(item);

  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<CreateOnLeaveCubit, CreateOnLeaveState>(
      bloc: _createCubit,
      buildWhen: (prev, cur) => prev.createStatus != cur.createStatus ||
        prev.updateStatus != cur.updateStatus,
      listener: (context, state) {
        if (state.createStatus == LoadStatus.LOADING ||
          state.getTypeStatus == LoadStatus.LOADING
        || state.updateStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        }
        else if(state.getTypeStatus == LoadStatus.SUCCESS){
          LoadingOverlay.hide(context);
        }
        else if (state.createStatus == LoadStatus.SUCCESS ||
            state.updateStatus == LoadStatus.SUCCESS
        ) {
          _createCubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showInfo(
            title: s.success,
            message:
                widget.isEdit ?? false
                    ? "Cập nhật đơn xin nghỉ thành công"
                    : "Tạo mới đơn nghỉ thành công!",
          );

          if (widget.isEdit ?? false) {
            // Navigator.of(context)..pop()..pop();
            Navigator.pop(context);
            Navigator.pop(context, true);
          } else {
            Navigator.pop(context, true);
          }
        } else if (state.createStatus == LoadStatus.FAILURE ||
          state.updateStatus == LoadStatus.FAILURE) {
          _createCubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showError(
            title: s.warning,
            message: state.errMsg,
          );
        } else {
          // hide progress
          LoadingOverlay.hide(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bodyColor,
          appBar: MyAppBar(
            titleAppbar:  widget.isEdit == true
              ? s.day_off_edit_title
              : s.day_off_create_title
            ,
            haveBackButton: true,
            haveActionButton: true,
            iconPathAsset: AppAssets.icNotificationBell,
            actionCallBack: () {
              _goNotification();
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16,right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                  decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.all(Radius.circular(16))
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12,),
                      BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
                          bloc: _createCubit,
                          buildWhen: (prev,cur) => prev.leaveDateType != cur.leaveDateType ||
                            prev.listDateTypeLeaves != cur.listDateTypeLeaves,
                          builder: (context,state){
                            return InputTextField(
                              title: s.day_off_type,
                              hintText: s.day_off_type_hint,
                              isRequiredField: true,
                              controller: dateTypeController..text = state.leaveDateType ?? "",
                              enable: true,
                              readOnly: true,
                              suffixIcon: AppAssets.icArrowDown,
                              callback: () {
                                _openDateTypeLeaveBottomSheet(
                                  state.listDateTypeLeaves ?? [],
                                );
                              },
                            ).paddingOnly(bottom: 20);
                          }),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
                                  bloc: _createCubit,
                                  buildWhen: (prev,cur) => prev.fromDate != cur.fromDate ||
                                    prev.fromDateTime != cur.fromDateTime,
                                  builder: (context,state){
                                    return InputTextField(
                                      title: s.day_off_from,
                                      hintText: "",
                                      isRequiredField: true,
                                      enable: true,
                                      readOnly: true,
                                      controller: fromDateController..text = state.fromDate ?? "",
                                      suffixIcon: AppAssets.icCalendar,
                                      callback: () {
                                        _showDatePicker(
                                          defaultValue: state.fromDateTime ?? _initFromDate,
                                          onConfirm: (selectedDate) {
                                            _selectedDate = selectedDate;
                                            if (_createCubit.state.toDateTime != null) {
                                              if (_createCubit.state.toDateTime!
                                                  .difference(selectedDate)
                                                  .inDays <
                                                  0) {
                                                AppSnackBar.showError(
                                                  title: s.warning,
                                                  message:
                                                  "Từ ngày không được lớn hơn đến ngày",
                                                );
                                              } else {
                                                // _createCubit.onChangeLeaveDays(_createCubit.state.toDateTime!.difference(selectedDate).inDays);
                                                _createCubit.setFromDate(selectedDate);
                                                final allDays = AppDateUtils.daysBetween(
                                                  selectedDate,
                                                  _createCubit.state.toDateTime!,
                                                );
                                                listDays.clear();
                                                for (final e in allDays) {
                                                  listDays.add(
                                                    LeaveDayEntity(
                                                      date: _formatYyyyMmDd(e),
                                                      type: 'full',
                                                    ),
                                                  );
                                                }
                                                _createCubit.onChangeListLeaveDays(
                                                  listDays,
                                                );

                                                // Tổng số ngày
                                                final total = _sumDaysByType(listDays);
                                                totalDaysController.text = _fmtTotal(total);
                                              }
                                            } else {
                                              if(selectedDate.difference(DateTime.now()).inDays < 0) {
                                                AppSnackBar.showError(
                                                  title: s.warning,
                                                  message:
                                                  "Từ ngày không được nhỏ hơn hôm nay",
                                                );
                                              }else{
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
                                  }),),
                          const SizedBox(width: 12,),
                          Expanded(
                              flex: 1,
                              child: BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
                                  bloc: _createCubit,
                                  buildWhen: (prev,cur) => prev.toDate != cur.toDate ||
                                    prev.toDateTime != cur.toDateTime,
                                  builder: (context,state){
                                    return InputTextField(
                                      title: s.day_off_to,
                                      hintText: "",
                                      isRequiredField: true,
                                      enable: true,
                                      readOnly: true,
                                      controller: toDateController..text = state.toDate ?? "",
                                      suffixIcon: AppAssets.icCalendar,
                                      callback: () {
                                        _showDatePicker(
                                          defaultValue: state.toDateTime ?? _initToDate,
                                          onConfirm: (selectedDate) {
                                            _selectedDate = selectedDate;
                                            if (_createCubit.state.fromDateTime != null) {
                                              if (selectedDate
                                                  .difference(
                                                _createCubit.state.fromDateTime!,
                                              ).inDays < 0) {
                                                AppSnackBar.showError(
                                                  title: s.warning,
                                                  message:
                                                  "Từ ngày không được lớn hơn đến ngày",
                                                );

                                                // AppSnackBar.showError(title: S.current.warning, message: S.current.from_time_to_time_validate);
                                              } else {
                                                _createCubit.setToDate(selectedDate);
                                                final allDays = AppDateUtils.daysBetween(
                                                  _createCubit.state.fromDateTime!,
                                                  selectedDate,
                                                );
                                                listDays.clear();
                                                for (final e in allDays) {
                                                  listDays.add(
                                                    LeaveDayEntity(
                                                      date:_formatYyyyMmDd(e),
                                                      type: 'full',
                                                    ),
                                                  );
                                                }
                                                _createCubit.onChangeListLeaveDays(
                                                  listDays,
                                                );

                                                // Tổng số ngày
                                                final total = _sumDaysByType(listDays);
                                                totalDaysController.text = _fmtTotal(total);
                                              }
                                            } else {

                                              if(selectedDate.difference(DateTime.now()).inDays < 0) {
                                                AppSnackBar.showError(
                                                  title: s.warning,
                                                  message:
                                                  "Đến ngày không được nhỏ hơn hôm nay",
                                                );
                                              }else{
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
                                  }),),
                        ],
                      ),
                      // list danh sach ngay nghi
                      BlocBuilder<CreateOnLeaveCubit, CreateOnLeaveState>(
                        bloc: _createCubit,
                        buildWhen: (prev, cur) => prev.listLeaveDays != cur.listLeaveDays,
                        builder: (context, state) {
                          return SizedBox(
                            height:
                            (state.listLeaveDays ?? []).isEmpty
                                ? 0
                                : (((state.listLeaveDays ?? []).length > 3)
                                ? 300
                                : (state.listLeaveDays ?? []).length * 100),
                            child: SingleChildScrollView(
                              child: Column(
                                children:
                                (state.listLeaveDays ?? []).map((entity) {
                                  return OnleaveDayItemWidget(
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
                      ),

                      const SizedBox(height: 20,),
                      BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
                          bloc: _createCubit,
                          buildWhen: (prev,cur) => prev.leaveDays != cur.leaveDays ||
                            prev.fromDateTime != cur.fromDateTime ||
                            prev.toDateTime != cur.toDateTime,
                          builder: (context,state){
                            return InputTextField(
                              title: s.day_off_total,
                              hintText: "",
                              isRequiredField: false,
                              enable: false,
                              controller: totalDaysController,
                              readOnly: true,
                            ).paddingOnly(bottom: 20);
                          }),

                      InputTextField(
                        title: s.day_off_left,
                        hintText: "",
                        isRequiredField: false,
                        enable: false,
                        controller:
                        leavesDaysController
                          ..text =
                              GlobalData.instance.userProfile?.remainLeave
                                  .toString()
                                  .replaceAll(".0", "") ??
                                  "",
                        readOnly: true,
                      ).paddingOnly(bottom: 20),

                      InputTextField(
                        title: s.day_off_reason,
                        hintText: s.day_off_reason_hint,
                        isRequiredField: true,
                        enable: true,
                        controller: reasonController..text = state.reason ?? "",
                        maxLine: 5,
                        onChange: (value) {
                          _createCubit.onChangeReason(value);
                        },
                      ),
                      const SizedBox(height: 20,)
                    ],
                  ),
                ),
                const SizedBox(height: 40,)
              ],
            ),
          ),
          bottomSheet: _bottomSheet,
        );
      },
    );
  }

  get _bottomSheet {
    return BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
        bloc: _createCubit,
        buildWhen: (prev,cur) => prev.reason != cur.reason ||
          prev.leaveDateType != cur.leaveDateType ||
          prev.fromDate != cur.fromDate ||
          prev.toDate != cur.toDate,
        builder: (context,state){
          bool isEnable = false;
          if((state.reason ?? "").isNotEmpty &&
              (state.leaveDateType ?? "").isNotEmpty &&
              (state.fromDate ?? "").isNotEmpty &&
              (state.toDate ?? "").isNotEmpty
          ){
            isEnable = true;
          }
          return InkWell(
            onTap:isEnable ? (){
              (widget.isEdit ?? false) ?
                  _doUpdate(): _doCreate();

            } : (){},
            child: Container(
              margin: const EdgeInsets.only(left: 16,right: 16,bottom: 36),
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                  color: isEnable ?
                  AppColors.themePrimaryDefault
                      : Color(0xFFDFDFDF),
                  borderRadius: BorderRadius.all(Radius.circular(6))
              ),
              child: Center(
                child: Text(S.of(context).save,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:isEnable ?
                      AppColors.whiteColor : AppColors.textGray600
                  ),
                ),
              ),
            ),
          );
        });

  }

  _doUpdate(){
    if(_createCubit.state.currentDateLeaveType?.id == 7){
      if ((GlobalData.instance.userProfile?.remainLeave ?? 0) <= 0 ||
          (GlobalData.instance.userProfile?.remainLeave ?? 0) <
              double.parse(totalDaysController.text)
      ) {
        AppSnackBar.showWarning(
          title: S.of(context).warning,
          message: "Quỹ phép của nhân viên không còn đủ!",
        );
      } else {
        _showUpdate();
      }
    }else{
      _showUpdate();
    }

  }

  _showUpdate(){
    _showDialog(
      title: S.of(context).confirm,
      message:"Thông tin sẽ được thay đổi. Bạn chắc chắn "
          "muốn thay đổi thông tin này?",
      success: true,
      onConfirm: () {
        _createCubit.updateLeaveDay(widget.detailEntity?.id ?? 0);
        Navigator.of(context).maybePop();
      },
    );
  }

  _doCreate(){
    if(_createCubit.state.currentDateLeaveType?.id == 7){
      if ((GlobalData.instance.userProfile?.remainLeave ?? 0) <= 0 ||
          (GlobalData.instance.userProfile?.remainLeave ?? 0) <
              double.parse(totalDaysController.text)
      ) {
        AppSnackBar.showWarning(
          title: S.of(context).warning,
          message: "Quỹ phép của nhân viên không còn đủ!",
        );
      } else {
        _createCubit.createLeaveDay();
      }
    }else{
      _createCubit.createLeaveDay();
    }
  }
}
