import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/schedule_entity.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_cubit.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

import '../../../../generated/l10n.dart';
import '../../../core/commons/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/entities/leave_day_entity.dart';
import '../../../data/models/entities/user_entity.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/attach_file_bottom_sheet.dart';
import '../../widgets/check_box_icon.dart';
import '../../widgets/check_box_selection.dart';
import '../../widgets/custom_dialog.dart';
import '../on_leave/widget/onleave_day_item_widget.dart';
import '../task/bottomsheet/select_user_bottom_sheet.dart';

class RequestNewTripPage extends StatefulWidget {
  bool? isEdit;
  WorkTripEntity? detailEntity;

  RequestNewTripPage({super.key, this.isEdit, this.detailEntity});

  @override
  State<RequestNewTripPage> createState() => _RequestNewTripPageState();
}

class _RequestNewTripPageState extends State<RequestNewTripPage> {
  final _cubit = GetIt.I.get<WorkTripCubit>();

  final _staffsKey = GlobalKey<FormState>();
  final _fromDateKey = GlobalKey<FormState>();
  final _toDateKey = GlobalKey<FormState>();
  final _noteKey = GlobalKey<FormState>();

  TextEditingController staffsController = TextEditingController();

  TextEditingController totalStaffsController = TextEditingController();

  TextEditingController createdByController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController totalDaysController = TextEditingController(text: '0');
  TextEditingController addressController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  List<ScheduleEntity> listDays = [];
  late var totalSchedulesDays = 0;

  DateTime? _initFromDate;
  DateTime? _initToDate;
  DateTime? _selectedDate;

  @override
  void initState() {
    if((_cubit.state.listUsers ??[]).isEmpty){
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
            out.add(ScheduleEntity(dateFrom: _formatYyyyMmDd(d),
                dateTo: _formatYyyyMmDd(d),
                type: t));
          }
        }
      }
      if (out.isNotEmpty) return out;
    }

    final allDays = AppDateUtils.daysBetween(from, to);
    for (final d in allDays) {
      out.add(ScheduleEntity(dateFrom:_formatYyyyMmDd(d),dateTo: _formatYyyyMmDd(d), type: 'full'));
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

    //lý do
    noteController.text = note;
    _cubit.onChangeNote(note);

    // nhan vien
    List<UserEntity> users = detail.employees ?? [];
    if(users.isNotEmpty){
      _cubit.onChangeCurrentUsers(users);
      _cubit.onChangeUser((detail.employees ??[]).map((u) => u.name).join(','));
    }

    // danh sach ngay cong tac
    if (from != null && to != null) {
      listDays = _buildDaysForEdit(from: from, to: to, lineSchedules: schedules);
      _cubit.onChangeListSchedulesDays(listDays);

      // leave days
      // final total = _sumDaysByType(listDays);
      // totalDaysController.text = _fmtTotal(total);
      // totalSchedulesDays = int.parse(_fmtTotal(total));
    } else {
      listDays = [];
      _cubit.onChangeListSchedulesDays(listDays);
      // totalDaysController.text = '0';
      // totalSchedulesDays = 0;
    }


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

  _openAttachFiles(){
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (BuildContext context) =>
            AttachFileBottomSheet(
              cubit: _cubit,
            )
    );
  }

  _openUsersBottomSheet(List<UserEntity> list) async {
    await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (BuildContext context) =>
            SelectUserBottomSheet(
              listUsers: _cubit.state.listUsers ?? [],
              listCurrentUsers: _cubit.state.currentUsers ?? [],
              onUsersSelected:(users){
                String user =  users.map((sc) => sc.name).toList().join(",");
                if(user != _cubit.state.strUsers){
                  _cubit.onChangeUser(user);
                  _cubit.onChangeCurrentUsers(users);
                }
              },
            )
    );
  }

  // Helper func
  String _formatYyyyMmDd(DateTime d) {
    return AppDateUtils().formatIsoToYyyyMmDd(d.toIso8601String());
  }

  double _sumDaysByType(List<ScheduleEntity> days) {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkTripCubit,WorkTripState>(
        bloc: _cubit,
        listener: (context, state) async {
          // helper: chạy sau frame để tránh !_debugLocked
          Future<void> postFrame(VoidCallback fn) async {
            if (!context.mounted) return;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              fn();
            });
          }

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
            _cubit.onResetStatus();
            return;
          }

          if (state.updateStatus == LoadStatus.SUCCESS) {
            AppSnackBar.showInfo(
              title: "Thành công",
              message: state.errMsg ?? "",
            );

            await postFrame(() {
              // Navigator.of(context).pop(true);
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
            _cubit.onResetStatus();
            return;
          }
        },
        builder: (context,state){
          return Scaffold(
            backgroundColor: AppColors.bodyColor,
            appBar: MyAppBar(titleAppbar: "Tạo mới phiếu công tác",
              haveBackButton: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.all(Radius.circular(6))
                    ),
                    child: Column(
                      children: [
                        BlocBuilder<WorkTripCubit,WorkTripState>(
                            bloc: _cubit,
                            buildWhen: (prev,cur) => prev.strUsers != cur.strUsers ||
                              prev.currentUsers != cur.currentUsers,
                            builder: (context,state){
                              return Column(
                                children: [
                                  Form(
                                    key: _staffsKey,
                                    child: BlocListener<WorkTripCubit,WorkTripState>(
                                      bloc: _cubit,
                                      listenWhen: (prev, cur) => prev.currentUsers != cur.currentUsers ||
                                          prev.strUsers != cur.strUsers,
                                      listener: (context, state) {
                                        final text = state.strUsers ?? "";
                                        staffsController.value = staffsController.value.copyWith(
                                          text: text,
                                          selection: TextSelection.collapsed(offset: text.length),
                                          composing: TextRange.empty,
                                        );

                                        if(text.isNotEmpty){
                                          _staffsKey.currentState?.validate();
                                        }
                                      },
                                      child: BlocBuilder<WorkTripCubit,WorkTripState>(
                                          bloc: _cubit,
                                          buildWhen: (prev,cur) => prev.strUsers != cur.strUsers ||
                                              prev.currentUsers != cur.currentUsers ||
                                              prev.listUsers != cur.listUsers,
                                          builder: (context,state){
                                            return InputTextField(
                                              title: "Nhân viên",
                                              hintText: "",
                                              isRequiredField: true,
                                              controller: staffsController,
                                              enable: true,
                                              readOnly: true,
                                              suffixIcon: AppAssets.icArrowDown,
                                              callback: (){
                                                _openUsersBottomSheet(state.listUsers ?? []);
                                              },
                                              validator: (value) =>
                                                  Validator.validateEmpty(value, "Nhân viên "),
                                            ).paddingOnly(bottom: 20);
                                          }),
                                    ),
                                  ),
                                  // Tổng số người
                                  InputTextField(
                                    title: "Tổng số người",
                                    hintText: "",
                                    isRequiredField: false,
                                    readOnly: true,
                                    enable: false,
                                    controller: totalStaffsController..text =
                                    (state.currentUsers ?? []).isNotEmpty ? (state.currentUsers ?? []).length.toString() : "" ,
                                  ).paddingOnly(bottom: 20),
                                ],
                              );
                            }),

                        InputTextField(
                          title: "Nhân viên tạo",
                          hintText: "",
                          isRequiredField: false,
                          readOnly: true,
                          enable: false,
                          controller: createdByController..text = GlobalData.instance.userProfile?.name ?? "",
                        ).paddingOnly(bottom: 20),

                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: BlocBuilder<WorkTripCubit,WorkTripState>(
                                  bloc: _cubit,
                                  buildWhen: (prev,cur) => prev.fromDate != cur.fromDate ||
                                      prev.fromDateTime != cur.fromDateTime,
                                  builder: (context,state){
                                    return InputTextField(
                                      title: "Từ ngày",
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
                                            if (_cubit.state.toDateTime != null) {
                                              if (_cubit.state.toDateTime!
                                                  .difference(selectedDate)
                                                  .inDays <
                                                  0) {
                                                AppSnackBar.showError(
                                                  title: "Cảnh báo",
                                                  message:
                                                  "Từ ngày không được lớn hơn đến ngày",
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
                                                      keepLunchAllowance: false
                                                    ),
                                                  );
                                                }
                                                _cubit.onChangeListSchedulesDays(
                                                  listDays,
                                                );

                                                // Tổng số ngày
                                                // final total = _sumDaysByType(listDays);
                                                // totalDaysController.text = _fmtTotal(total);
                                              }
                                            } else {
                                              if(selectedDate.difference(DateTime.now()).inDays < 0) {
                                                AppSnackBar.showError(
                                                  title: "Cảnh báo",
                                                  message:
                                                  "Từ ngày không được nhỏ hơn hôm nay",
                                                );
                                              }else{
                                                _cubit.setFromDate(selectedDate);
                                                listDays.clear();
                                                _cubit.onChangeListSchedulesDays(listDays);
                                                // totalDaysController.text = '0';
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
                              child: BlocBuilder<WorkTripCubit,WorkTripState>(
                                  bloc: _cubit,
                                  buildWhen: (prev,cur) => prev.toDate != cur.toDate ||
                                      prev.toDateTime != cur.toDateTime,
                                  builder: (context,state){
                                    return InputTextField(
                                      title: "Đến ngày",
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
                                            if (_cubit.state.fromDateTime != null) {
                                              if (selectedDate
                                                  .difference(
                                                _cubit.state.fromDateTime!,
                                              ).inDays < 0) {
                                                AppSnackBar.showError(
                                                  title: "Cảnh báo",
                                                  message:
                                                  "Từ ngày không được lớn hơn đến ngày",
                                                );

                                                // AppSnackBar.showError(title: S.current.warning, message: S.current.from_time_to_time_validate);
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
                                                        keepLunchAllowance: false
                                                    ));
                                                }
                                                _cubit.onChangeListSchedulesDays(
                                                  listDays,
                                                );

                                                // Tổng số ngày
                                                // final total = _sumDaysByType(listDays);
                                                // totalDaysController.text = _fmtTotal(total);
                                              }
                                            } else {

                                              if(selectedDate.difference(DateTime.now()).inDays < 0) {
                                                AppSnackBar.showError(
                                                  title: "Cảnh báo",
                                                  message:
                                                  "Đến ngày không được nhỏ hơn hôm nay",
                                                );
                                              }else{
                                                _cubit.setToDate(selectedDate);

                                                listDays.clear();
                                                _cubit.onChangeListSchedulesDays(listDays);
                                                // totalDaysController.text = '0';
                                              }
                                            }
                                          },
                                        );
                                      },
                                    );
                                  }),),
                          ],
                        ).paddingOnly(bottom: 20),
                        // list danh sach ngay nghi
                        BlocBuilder<WorkTripCubit, WorkTripState>(
                          bloc: _cubit,
                          buildWhen: (prev, cur) => prev.listScheduleDays != cur.listScheduleDays,
                          builder: (context, state) {
                            return SizedBox(
                              height:
                              (state.listScheduleDays ?? []).isEmpty
                                  ? 0
                                  : (((state.listScheduleDays ?? []).length > 3)
                                  ? 300
                                  : (state.listScheduleDays ?? []).length * 100),
                              child: SingleChildScrollView(
                                child: Column(
                                  children:
                                  (state.listScheduleDays ?? []).map((entity) {
                                    return OnleaveDayItemWidget(
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

                                          // final total = _sumDaysByType(listDays);
                                          // totalDaysController.text = _fmtTotal(total);
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),

                        // const SizedBox(height: 20,),
                        // _utilsWidget,

                        // địa chỉ
                        InputTextField(
                          title: "Địa chỉ",
                          hintText: "",
                          isRequiredField: false,
                          controller: addressController,
                          onChange: (value) {
                            _cubit.onChangeAddress(value);
                          },
                        ).paddingOnly(bottom: 20),

                        // note
                        Form(
                          key: _noteKey,
                          child: InputTextField(
                            title: "Ghi chú",
                            hintText: "Thêm ghi chú",
                            isRequiredField: true,
                            enable: true,
                            controller: noteController,
                            maxLine: 5,
                            onChange: (value) {
                              _cubit.onChangeNote(value);
                            },
                          ),
                        ).paddingOnly(bottom: 20),
                        // _attachFile,
                        // const SizedBox(height: 20,)
                      ],
                    ),
                  ),
                  const SizedBox(height: 40,),
                  _bottomSheet
                ],
              ),
            ),
          );
        });
  }

  // utils widget
  get _utilsWidget {
    return BlocBuilder<WorkTripCubit,WorkTripState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.isOvernight != cur.isOvernight ||
          prev.needRoom != cur.needRoom ||
          prev.needTicket != cur.needTicket,
        builder: (context,state){
          return Column(
            children: [
              Row(
                children: [
                  // phòng khách sạn
                  Expanded(
                    flex: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Cần phòng khách sạn",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.neutral400
                          ),).paddingOnly(right: 6),
                        InkWell(
                          onTap: (){
                            _cubit.onChangeNeedRoom(!state.needRoom);
                          },
                          child: state.needRoom ? CheckBoxSelection() :
                            CheckBoxIcon(),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16,),
                  // vé máy bay
                  BlocBuilder<WorkTripCubit,WorkTripState>(
                      bloc: _cubit,
                      buildWhen: (prev,cur) => prev.needTicket != cur.needTicket,
                      builder: (context,state){
                        return Expanded(
                          flex: 4,
                          child: InkWell(
                            onTap: (){
                              _cubit.onChangeNeedTicket(!state.needTicket);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Vé máy bay",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.neutral400
                                  ),).paddingOnly(right: 6),
                                InkWell(
                                  onTap: (){
                                    _cubit.onChangeNeedTicket(!state.needTicket);
                                  },
                                  child: state.needTicket ? CheckBoxSelection() :
                                  CheckBoxIcon(),
                                )
                              ],
                            ),
                          ),
                        );
                      })

                ],
              ).paddingOnly(bottom: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Qua đêm",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral400
                    ),).paddingOnly(right: 6),
                  InkWell(
                    onTap: (){
                      _cubit.onchangeIsOverNight(!state.isOvernight);
                    },
                    child: state.isOvernight? CheckBoxSelection() : CheckBoxIcon(),
                  )
                ],
              )
            ],
          ).paddingOnly(bottom: 20);
        });

  }

  get _attachFile{
   return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                "Tệp đính kèm",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(AppAssets.starRating),
          ],
        ),
        const SizedBox(height: 8,),
        GestureDetector(
          onTap: () {
            _openAttachFiles();
          },
          child: DottedBorder(
            color: AppColors.themePrimaryDefault,
            dashPattern: [4, 4],
            strokeWidth: 1,
            strokeCap: StrokeCap.round,
            borderType: BorderType.RRect,
            radius: Radius.circular(8),
            child: Container(
              height: 120,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppAssets.icCloud,width: 32,height: 28,color: AppColors.themePrimaryDefault,),
                  const SizedBox(height: 4,),
                  Container(
                      margin: EdgeInsets.only(left: 4),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "Drag your file(s) or ",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.themeBlackDefault,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: "browses",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.themePrimaryDefault,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = (){
                                   _openAttachFiles();
                                  }),
                          ],
                        ),
                      ),),
                  const SizedBox(height: 4,),
                  Text("Max 1MB files are allowed",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGray600
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  get _bottomSheet {
    return BlocBuilder<WorkTripCubit,WorkTripState>(
        bloc: _cubit,
        buildWhen: (prev,cur) =>
          prev.strUsers != cur.strUsers ||
            prev.fromDate != cur.fromDate ||
            prev.toDate != cur.toDate ||
          prev.note != cur.note,

        builder: (context,state){
          bool isEnable = false;
          if((state.strUsers ?? "").isNotEmpty &&
              (state.fromDate ?? "").isNotEmpty &&
              (state.toDate ?? "").isNotEmpty &&
              (state.note ?? "").isNotEmpty
          ){
            isEnable = true;
          }
          return InkWell(
            onTap:isEnable ? (){
              (widget.isEdit ?? false) ?
              _showUpdate()
              : _cubit.createNewWorkTrip();
            } : (){},
            child: Container(
              margin: const EdgeInsets.only(bottom: 36),
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                  color: isEnable ?
                  AppColors.themePrimaryDefault
                      : Color(0xFFDFDFDF),
                  borderRadius: BorderRadius.all(Radius.circular(6))
              ),
              child: Center(
                child: Text("Lưu",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor
                  ),
                ),
              ),
            ),
          );
        });

  }
  _showUpdate(){
    _showDialog(
      title: S.of(context).confirm,
      message:"Thông tin sẽ được thay đổi. Bạn chắc chắn "
          "muốn thay đổi thông tin này?",
      success: true,
      onConfirm: () {
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
