import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/create_on_leave_cubit.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:pm_app/app/features/ui/on_leave/data/leave_day_entity.dart';
import 'package:pm_app/app/features/widgets/common_bottom_sheet.dart';
import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/entities/on_leave_entity.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/input_text_field.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/primary_button.dart';


class CreateNewLeavePage extends StatefulWidget {
  bool? isEdit;
  OnLeaveEntity? detailEntity;

  CreateNewLeavePage({
    super.key,
    this.isEdit,
    this.detailEntity
  });


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

  final _createCubit = GetIt.I.get<CreateOnLeaveCubit>();
  DateTime? _initFromDate;
  DateTime? _initToDate;
  DateTime? _selectedDate;

  final ScrollController _scrollController = ScrollController();
  List<LeaveDayEntity> listDays = [];
  @override
  void initState() {
    _createCubit.getListDateTypeLeaves();
    _createCubit.getListTypeLeaves();
    super.initState();
  }

  @override
  void dispose() {
    // _createCubit.close();
    super.dispose();
  }

  _showDatePicker({DateTime? defaultValue, DateChangedCallback? onConfirm}){
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      onConfirm: onConfirm,
      currentTime: defaultValue ?? DateTime.now(),
      locale: LocaleType.vi
    );
  }

  _openDateTypeLeaveBottomSheet(List<MasterDataItem> list) async{
    final item = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (BuildContext context) =>
            CommonBottomSheet(
              listValues: list,
              currentValue: _createCubit.state.currentDateLeaveType ,
              title: "Loại ngày nghỉ",
            )
    );

    if(item != null ){
      _createCubit.onChangeDateTypeLeaves(item);
    }
  }

  _openTypeLeaveBottomSheet(List<MasterDataItem> list, MasterDataItem currentType) async{
    final item = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (BuildContext context) =>
            CommonBottomSheet(
              listValues: list,
              currentValue: currentType,//_createCubit.state.currentLeaveType,
              title: "Loại nghỉ",
            )
    );

    // if(item != null ){
    //   _createCubit.onChangeLeaveType(item);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateOnLeaveCubit,CreateOnLeaveState>(
      bloc: _createCubit,
      buildWhen: (prev,cur) => prev.createStatus != cur.createStatus,
      listener: (state,context){

      },
      builder: (context,state){
        return Scaffold(
          appBar: MyAppBar(titleAppbar: "Tạo yêu cầu nghỉ phép",
            haveBackButton: true,
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.appBg),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 120,),
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                    decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),)
                    ),
                    child: _contentBody,
                  ),
                ))
              ],
            ),
          ),
        );
      },
    );
  }

  get _contentBody {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InputTextField(
            title: "Số phép còn lại",
            hintText: "",
            isRequiredField: false,
            controller: leavesDaysController..text = '0.0', //(_cubit.state.leaveEntity?.soNgayPhepConLai ?? 0).toString() ?? "",
            readOnly: true,
          ).paddingOnly(bottom: 20),
          BlocListener<CreateOnLeaveCubit,CreateOnLeaveState>(
            bloc: _createCubit,
            listenWhen: (prev, cur) => prev.leaveDateType != cur.leaveDateType,
            listener: (context, state) {
              final text = state.leaveDateType ?? "";
              dateTypeController.value = dateTypeController.value.copyWith(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
                composing: TextRange.empty,
              );

              if(text.isNotEmpty){
                _dateTypeKey.currentState?.validate();
              }
            },
            child: BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
                buildWhen: (prev,cur) => prev.leaveDateType != cur.leaveDateType ||
                  prev.listDateTypeLeaves != cur.listDateTypeLeaves,
                builder: (context,state){
                  return InputTextField(
                    title: "Loại ngày nghỉ",
                    hintText: "",
                    isRequiredField: true,
                    controller: dateTypeController,
                    enable: true,
                    readOnly: true,
                    suffixIcon: AppAssets.icArrowDown,
                    callback: (){
                      _openDateTypeLeaveBottomSheet(state.listDateTypeLeaves ?? [],);
                    },
                    validator: (value) =>
                        Validator.validateEmpty(value, "Loại ngày nghỉ"),
                  ).paddingOnly(bottom: 20);
                }),
          ),
          InputTextField(
            title: "Số ngày nghỉ",
            hintText: "",
            isRequiredField: false,
            controller:TextEditingController(text: '0.0'), //(_cubit.state.leaveEntity?.soNgayPhepConLai ?? 0).toString() ?? "",
            readOnly: true,
          ).paddingOnly(bottom: 20),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: BlocListener<CreateOnLeaveCubit,CreateOnLeaveState>(
                    bloc: _createCubit,
                    listenWhen: (prev,cur) => prev.fromDate != cur.fromDate
                        || prev.fromDateTime != cur.fromDateTime,
                    listener: (context,state){
                      String text = state.fromDate ?? "";
                      fromDateController.value = fromDateController.value.copyWith(
                        text: text,
                      );
                      if(text.isNotEmpty){
                        _fromDateKey.currentState?.validate();
                      }
                    },
                    child: BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
                        bloc:_createCubit,
                        buildWhen: (prev,cur) => prev.fromDate != cur.fromDate ||
                            prev.fromDateTime != cur.fromDateTime,
                        builder: (context, state) {
                          return Form(
                            key: _fromDateKey,
                            child: InputTextField(
                              title: "Từ ngày",
                              hintText: "",
                              isRequiredField: true,
                              enable: true,
                              readOnly: true,
                              controller: fromDateController,
                              suffixIcon: AppAssets.icCalendar,
                              callback: (){
                                _showDatePicker(
                                    defaultValue: state.fromDateTime ?? _initFromDate,
                                    onConfirm: (selectedDate) {
                                      _selectedDate = selectedDate;
                                      if(_createCubit.state.toDateTime != null){
                                        if (_createCubit.state.toDateTime!.difference(selectedDate).inDays < 0) {
                                          AppSnackBar.showError(title: "Cảnh báo",message: "Từ ngày không được lớn hơn đến ngày");
                                          // AppSnackBar.showError(title: S.current.warning, message: S.current.from_time_to_time_validate);
                                        }else{
                                          // _createCubit.onChangeLeaveDays(_createCubit.state.toDateTime!.difference(selectedDate).inDays);
                                          _createCubit.setFromDate(selectedDate);
                                        }
                                      }else{
                                        _createCubit.setFromDate(selectedDate);
                                      }

                                    }
                                );
                              },
                              validator: (value)
                              => Validator.validateEmpty(value, "Từ ngày"),
                            ),
                          );
                        }),
                  )),
              const SizedBox(width: 8,),
              Expanded(
                  flex: 1,
                  child: BlocListener<CreateOnLeaveCubit,CreateOnLeaveState>(
                    bloc: _createCubit,
                    listenWhen: (prev,cur) => prev.toDate != cur.toDate
                        || prev.toDateTime != cur.toDateTime,
                    listener: (context,state){
                      String text = state.toDate ?? "";
                      toDateController.value = toDateController.value.copyWith(
                        text: text,
                      );
                      if(text.isNotEmpty){
                        _toDateKey.currentState?.validate();
                      }
                    },
                    child: BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
                        bloc:_createCubit,
                        buildWhen: (prev,cur) => prev.toDate != cur.toDate ||
                            prev.toDateTime != cur.toDateTime,
                        builder: (context, state) {
                          return Form(
                            key: _toDateKey,
                            child: InputTextField(
                              title: "Đến ngày",
                              hintText: "",
                              isRequiredField: true,
                              enable: true,
                              readOnly: true,
                              controller: toDateController,
                              suffixIcon: AppAssets.icCalendar,
                              callback: (){
                                _showDatePicker(
                                    defaultValue: state.toDateTime ?? _initToDate,
                                    onConfirm: (selectedDate) {
                                      _selectedDate = selectedDate;
                                      if(_createCubit.state.fromDateTime != null){
                                        if (selectedDate.difference(_createCubit.state.fromDateTime!).inDays < 0) {
                                          AppSnackBar.showError(title: "Cảnh báo",message: "Từ ngày không được lớn hơn đến ngày");
                                          // AppSnackBar.showError(title: S.current.warning, message: S.current.from_time_to_time_validate);
                                        }else{
                                          _createCubit.setToDate(selectedDate);
                                          final allDays = AppDateUtils.daysBetween(_createCubit.state.fromDateTime!, selectedDate);
                                          listDays.clear();
                                          for (var e in allDays) {
                                            listDays.add(LeaveDayEntity(date: e.toIso8601String()));
                                          }
                                          _createCubit.onChangeListLeaveDays(listDays);
                                        }
                                      }else{
                                        _createCubit.setToDate(selectedDate);
                                      }

                                    }
                                );
                              },
                              validator: (value)
                              => Validator.validateEmpty(value, "Tới ngày"),
                            ),
                          );
                        }),
                  ))
            ],
          ).paddingOnly(bottom: 20),

          // list danh sach ngay nghi
          BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
              bloc: _createCubit,
              buildWhen: (prev,cur) => prev.listLeaveDays != cur.listLeaveDays,
              builder: (context,state){
                return SizedBox(
                  height: (state.listLeaveDays ?? []).isEmpty ? 0 :
                    (((state.listLeaveDays ?? []).length >=5) ? 200 : (state.listLeaveDays ?? []).length*80),
                  child: SingleChildScrollView(
                    child: Column(
                      children: (state.listLeaveDays ?? []).map((e) {
                        return Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: InputTextField(
                                  title: "Ngày",
                                  hintText: "",
                                  isRequiredField: true,
                                  readOnly: true,
                                  controller: TextEditingController(text: AppDateUtils.changeIso8601StringToDateTimeString(e.date??"")),
                                )),
                            const SizedBox(width: 10,),
                            Expanded(
                                flex: 1,
                                child: InputTextField(
                                  title: "Loại nghỉ",
                                  hintText: "",
                                  isRequiredField: true,
                                  controller:TextEditingController(text:e.type.text),
                                  enable: true,
                                  readOnly: true,
                                  suffixIcon: AppAssets.icArrowDown,
                                  callback: (){
                                    _openTypeLeaveBottomSheet(state.listTypeLeaves ?? [],e.type);
                                  },

                                ))
                          ],
                        ).paddingOnly(bottom: 16);
                      }).toList(),
                    ),
                  ),
                );
              }),

          const SizedBox(height: 20,),
          Form(
              key: _reasonKey,
              child: BlocListener<CreateOnLeaveCubit,CreateOnLeaveState>(
                bloc: _createCubit,
                listenWhen: (prev, cur) => prev.reason != cur.reason,
                listener: (context, state) {
                  final text = state.reason ?? "";
                  reasonController.value = reasonController.value.copyWith(
                    text: text,
                    selection: TextSelection.collapsed(offset: text.length),
                    composing: TextRange.empty,
                  );

                  if(text.isNotEmpty){
                    _reasonKey.currentState?.validate();
                  }
                },
                child: BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
                  bloc: _createCubit,
                  buildWhen: (prev,cur) => prev.reason != cur.reason,
                  builder: (context,state){
                    return InputTextField(
                      title: "Lý do nghỉ",
                      hintText: "",
                      isRequiredField: true,
                      enable: true,
                      controller: reasonController,
                      maxLine: 5,
                      onChange: (value){
                        _reasonKey.currentState!.validate();
                        _createCubit.onChangeReason(value);
                      },
                      validator:  (value) =>
                          Validator.validateEmpty(value, "Lý do nghỉ"),
                    );
                  },
                ),
              )),
          const SizedBox(height: 36,),
          PrimaryButton(
            mainText: "Lưu",//S.current.save,
            buttonWidth: double.infinity,
            borderRadius: 8,
            callback: (){
              // requestCreateNew();
            },),

        ],
      ),
    );
  }
}
