import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/entities/user_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';
import 'package:pm_app/app/features/ui/task/bottomsheet/select_user_bottom_sheet.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/input_text_field.dart';

class CreateNewTask extends StatefulWidget {
  bool? isEdit;
  TaskEntity? detailEntity;

  CreateNewTask({super.key, this.isEdit, this.detailEntity});

  @override
  State<CreateNewTask> createState() => _CreateNewTaskState();
}

class _CreateNewTaskState extends State<CreateNewTask> {
  final _cubit = GetIt.I.get<TaskCubit>();

  final _titleKey = GlobalKey<FormState>();
  TextEditingController taskNameController = TextEditingController();


  final _taskType = GlobalKey<FormState>();
  TextEditingController taskTypeController = TextEditingController();

  TextEditingController assignerController = TextEditingController();

  final _userKey = GlobalKey<FormState>();
  TextEditingController userController = TextEditingController();

  final _dateLineKey = GlobalKey<FormState>();
  TextEditingController dateLineController = TextEditingController();

  final _descriptionKey = GlobalKey<FormState>();
  TextEditingController descriptionController = TextEditingController();

  DateTime? _selectedDate;

  final List<MasterDataItem> listTaskTypes = [
    MasterDataItem(text: "Thông thường", code :"normal"),
    MasterDataItem(text: "Tuyển dụng", code :"recruitment")
  ];

  @override
  void initState() {
    _cubit.getListUsers();
    if(widget.isEdit ?? false){
      _cubit.initUpdateState(widget.detailEntity ?? TaskEntity());
      _initUpdateData();
    }
    super.initState();
  }

  @override
  void dispose() {
    _cubit.resetStatus();
    _cubit.resetData();
    super.dispose();
  }

  _initUpdateData(){
    taskNameController.text = _cubit.state.taskName ?? "";
    dateLineController.text = _cubit.state.deadlineTime ?? "";
    userController.text = _cubit.state.strUsers ?? "";
    descriptionController.text = _cubit.state.description ?? "";
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
                  if((user).isNotEmpty){
                    _userKey.currentState?.validate();
                  }
                }
              },
            )
    );
  }

  _showDatePicker({DateTime? defaultValue, DateChangedCallback? onConfirm}){
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      onConfirm: onConfirm,
      currentTime: defaultValue ?? DateTime.now(),
      locale: LocaleType.vi,
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit,TaskState>(
        bloc: _cubit,
        listener: (context,state){
          if(state.createStatus == LoadStatus.LOADING ||
            state.updateStatus == LoadStatus.LOADING){
            LoadingOverlay.show(context);
          }
          else if(state.createStatus == LoadStatus.SUCCESS ||
            state.updateStatus == LoadStatus.SUCCESS){
            _cubit.resetStatus();
            LoadingOverlay.hide(context);
            AppSnackBar.showInfo(title: "Thành công",message:
            (widget.isEdit ?? false) ?
            "Cập nhật công việc thành công!!!":
            "Tạo mới công việc thành công!!!");

            if(widget.isEdit ?? false){
              Navigator.pop(context);
              Navigator.pop(context,true);
            }else{
              Navigator.pop(context,true);
            }

          }
          else if(state.createStatus == LoadStatus.FAILURE ||
            state.updateStatus == LoadStatus.FAILURE){
            LoadingOverlay.hide(context);
            _cubit.resetStatus();
            AppSnackBar.showWarning(title: "Cảnh báo",message: "Có lỗi xảy ra vui lòng thử lại sau!!!");
          }
          else{
            LoadingOverlay.hide(context);
          }
        },
        builder: (context,state){
          return Scaffold(
            backgroundColor: AppColors.bodyColor,
            appBar: AppBar(
              title: (widget.isEdit ?? false) ? Text("Cập nhật việc cần làm") :
                Text("Tạo việc cần làm"),
              flexibleSpace: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.appbarBg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                icon: Image.asset(
                  AppAssets.ic_arrowB,
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            body: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.all(Radius.circular(6))
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Form(
                                key: _titleKey,
                                child: BlocListener<TaskCubit, TaskState>(
                                  bloc: _cubit,
                                  listenWhen: (prev, cur) => prev.taskName != cur.taskName,
                                  listener: (context, state) {
                                    final text = state.taskName ?? "";
                                    taskNameController.value = taskNameController.value.copyWith(
                                      text: text,
                                      selection: TextSelection.collapsed(offset: text.length),
                                      composing: TextRange.empty,
                                    );

                                    if (text.isNotEmpty) {
                                      _titleKey.currentState?.validate();
                                    }
                                  },
                                  child: BlocBuilder<TaskCubit, TaskState>(
                                    bloc: _cubit,
                                    buildWhen: (prev, cur) => prev.taskName != cur.taskName,
                                    builder: (context, state) {
                                      return InputTextField(
                                        title: "Tiêu đề",
                                        hintText: "",
                                        isRequiredField: true,
                                        enable: true,
                                        controller: taskNameController,
                                        onChange: (value) {
                                          _titleKey.currentState!.validate();
                                          _cubit.onChangeTaskName(value);
                                        },
                                        validator:
                                            (value) => Validator.validateEmpty(value, "Tiêu đề"),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16,),
                              _priorityWidget,
                              const SizedBox(height: 16,),
                              InputTextField(
                                title: "Loại công việc",
                                hintText: "",
                                isRequiredField: false,
                                controller:
                                taskTypeController
                                  ..text = "Thông thường",
                                readOnly: true,
                              ).paddingOnly(bottom: 16),

                              InputTextField(
                                title: "Người giao việc",
                                hintText: "",
                                isRequiredField: false,
                                controller:
                                assignerController
                                  ..text = GlobalData.instance.userProfile?.name ?? "",
                                readOnly: true,
                              ).paddingOnly(bottom: 16),

                              Form(
                                key: _userKey,
                                child: BlocListener<TaskCubit,TaskState>(
                                  bloc: _cubit,
                                  listenWhen: (prev, cur) => prev.currentUsers != cur.currentUsers ||
                                      prev.strUsers != cur.strUsers,
                                  listener: (context, state) {
                                    final text = state.strUsers ?? "";
                                    userController.value = userController.value.copyWith(
                                      text: text,
                                      selection: TextSelection.collapsed(offset: text.length),
                                      composing: TextRange.empty,
                                    );

                                    if(text.isNotEmpty){
                                      _userKey.currentState?.validate();
                                    }
                                  },
                                  child: BlocBuilder<TaskCubit,TaskState>(
                                      bloc: _cubit,
                                      buildWhen: (prev,cur) => prev.strUsers != cur.strUsers ||
                                          prev.currentUsers != cur.currentUsers ||
                                          prev.listUsers != cur.listUsers,
                                      builder: (context,state){
                                        return InputTextField(
                                          title: "Người được phân công",
                                          hintText: "",
                                          isRequiredField: true,
                                          controller: userController,
                                          enable: true,
                                          readOnly: true,
                                          suffixIcon: AppAssets.icArrowDown,
                                          callback: (){
                                            _openUsersBottomSheet(state.listUsers ?? []);
                                          },
                                          validator: (value) =>
                                              Validator.validateEmpty(value, "Người được phân công "),
                                        ).paddingOnly(bottom: 20);
                                      }),
                                ),
                              ),

                              Form(
                                key: _dateLineKey,
                                child: BlocListener<TaskCubit,TaskState>(
                                  bloc: _cubit,
                                  listenWhen: (prev, cur) => prev.deadlineDateTime != cur.deadlineDateTime ||
                                      prev.deadlineTime != cur.deadlineTime,
                                  listener: (context, state) {
                                    final text = state.deadlineTime ?? "";
                                    dateLineController.value = dateLineController.value.copyWith(
                                      text: text,
                                      selection: TextSelection.collapsed(offset: text.length),
                                      composing: TextRange.empty,
                                    );

                                    if(text.isNotEmpty){
                                      _dateLineKey.currentState?.validate();
                                    }
                                  },
                                  child: BlocBuilder<TaskCubit,TaskState>(
                                      bloc: _cubit,
                                      buildWhen: (prev,cur) => prev.deadlineDateTime != cur.deadlineDateTime ||
                                          prev.deadlineTime != cur.deadlineTime,
                                      builder: (context,state){
                                        return InputTextField(
                                          title: "Hạn chót",
                                          hintText: "",
                                          isRequiredField: true,
                                          controller: dateLineController,
                                          enable: true,
                                          readOnly: true,
                                          suffixIcon: AppAssets.icCalendar,
                                          callback: (){
                                            _showDatePicker(
                                                defaultValue:  state.deadlineDateTime,
                                                onConfirm: (selectedDate) {
                                                  _selectedDate = selectedDate;
                                                  // validate to date so với hôm nay , nếu có
                                                  _cubit.setDeadlineDate(selectedDate);
                                                }
                                            );
                                          },
                                          validator: (value) =>
                                              Validator.validateEmpty(value, "Hạn chót"),
                                        ).paddingOnly(bottom: 20);
                                      }),
                                ),
                              ),

                              Form(
                                key: _descriptionKey,
                                child: BlocListener<TaskCubit, TaskState>(
                                  bloc: _cubit,
                                  listenWhen: (prev, cur) => prev.description != cur.description,
                                  listener: (context, state) {
                                    final text = state.description ?? "";
                                    descriptionController.value = descriptionController.value.copyWith(
                                      text: text,
                                      selection: TextSelection.collapsed(offset: text.length),
                                      composing: TextRange.empty,
                                    );

                                    if (text.isNotEmpty) {
                                      _descriptionKey.currentState?.validate();
                                    }
                                  },
                                  child: BlocBuilder<TaskCubit, TaskState>(
                                    bloc: _cubit,
                                    buildWhen: (prev, cur) => prev.description != cur.description,
                                    builder: (context, state) {
                                      return InputTextField(
                                        title: "mô tả",
                                        hintText: "",
                                        isRequiredField: true,
                                        enable: true,
                                        controller: descriptionController,
                                        maxLine: 5,
                                        onChange: (value) {
                                          _descriptionKey.currentState!.validate();
                                          _cubit.onChangeDescription(value);
                                        },
                                        validator:
                                            (value) => Validator.validateEmpty(value, "Mô tả"),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24,),
                        _bottomSheet,
                        const SizedBox(height: 24,),
                      ],
                    ),
                  ),
                  // Positioned(
                  //     bottom: 40,
                  //     left: 16,
                  //     right: 16,
                  //     child: SizedBox(
                  //         width: double.infinity,
                  //         child: _bottomSheet
                  //     ))
                ],
              ),
            ),
          );
        }, );
  }

  get _priorityWidget {
    return BlocBuilder<TaskCubit,TaskState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.taskPriority != cur.taskPriority,
        builder: (context,state){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mức độ ưu tiên",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.themeDarkLight
                ),
              ),
              const SizedBox(height: 6,),
              InkWell(
                onTap: (){
                  _cubit.onChangeTakPriority();
                },
                child: SvgPicture.asset(AppAssets.icStar,width: 24,height: 24,
                  color: state.taskPriority ? Color(0xFFFFCB45) : Colors.grey,
                ),
              )
            ],
          );
        });
  }

  get _bottomSheet {
    return Padding(
      padding: const EdgeInsets.only(left: 12,right: 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  border: Border.all(
                    width: 1,
                    color: AppColors.themeBlackDefault.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  "Huỷ",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.themePrimaryDefault
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: (){
                (widget.isEdit ?? false) ?
                 doUpdateTask() : createNewTask();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.themePrimaryDefault,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  border: Border.all(
                    width: 1,
                    color: AppColors.themeBlackDefault.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  (widget.isEdit ?? false) ? "Xác Nhận" : "Lưu",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.whiteColor
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // funcs
  createNewTask() async{
    // validate
    final taskNameValid = _titleKey.currentState?.validate() ?? false;
    final userValid = _userKey.currentState?.validate() ?? false;
    final deadlineValid = _dateLineKey.currentState?.validate() ?? false;
    final descValid = _descriptionKey.currentState?.validate() ?? false;
    if(taskNameValid && userValid &&
        deadlineValid && descValid){
      _cubit.createNewTask();
    }

  }

  doUpdateTask() async{
    // validate
    final taskNameValid = _titleKey.currentState?.validate() ?? false;
    final userValid = _userKey.currentState?.validate() ?? false;
    final deadlineValid = _dateLineKey.currentState?.validate() ?? false;
    final descValid = _descriptionKey.currentState?.validate() ?? false;
    if(taskNameValid && userValid &&
        deadlineValid && descValid){
      showUpdateConfirmDialog();
    }

  }

  void showUpdateConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => CustomDialog(
        iconPath: AppAssets.ic_done,
        title: "Xác nhận",
        content: "Thông tin sẽ được thay. Bạn chắc chắn muốn thay đổi thông tin này?",
        success: true,
        confirmText: "Cập Nhật",
        cancelText: "Huỷ bỏ",
        onConfirm: () {
          Navigator.pop(context);
          _cubit.updateTask((widget.detailEntity?.id ?? 0).toString());
        },
      ),
    );
  }
}
