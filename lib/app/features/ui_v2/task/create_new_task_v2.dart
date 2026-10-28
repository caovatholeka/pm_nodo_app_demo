import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/widgets/input_counter_v2.dart';
import 'package:pm_app/app/core/commons/input_limits.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/core/utils/validators.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/entities/user_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';
import 'package:pm_app/app/features/ui/task/bottomsheet/select_user_bottom_sheet.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Tạo/Sửa công việc — phiên bản giao diện tối (v2).
///
/// Hành vi/nghiệp vụ giữ NGUYÊN bản cũ [CreateNewTask]: cùng [TaskCubit]
/// (qua GetIt), cùng gọi `getListUsers` + `initUpdateState`/prefill khi sửa,
/// cùng 4 [Form] con (tiêu đề/người thực hiện/hạn chót/mô tả) với
/// `Validator.validateEmpty`, cùng cách đồng bộ controller<->state qua
/// `BlocListener` (giữ nguyên con trỏ cuối chuỗi), cùng loại công việc cố
/// định "Thông thường" (readOnly, không đổi được — y hệt bản cũ), cùng người
/// giao việc luôn là user hiện tại (readOnly), cùng dialog xác nhận khi sửa,
/// cùng xử lý createStatus/updateStatus/resetStatus khi dispose.
///
/// Bản gốc dùng [SelectUserBottomSheet] (bottomsheet chọn nhân sự dùng
/// chung nhiều màn, không phải widget hàng/list dưới thư mục `widget/`) —
/// tái dùng trực tiếp, không tạo bản v2 riêng, đúng quy ước đã áp dụng ở
/// `RequestNewTripPageV2`.
class CreateNewTaskV2 extends StatefulWidget {
  bool? isEdit;
  TaskEntity? detailEntity;

  CreateNewTaskV2({super.key, this.isEdit, this.detailEntity});

  @override
  State<CreateNewTaskV2> createState() => _CreateNewTaskV2State();
}

class _CreateNewTaskV2State extends State<CreateNewTaskV2> {
  final _cubit = GetIt.I.get<TaskCubit>();

  final _titleKey = GlobalKey<FormState>();
  TextEditingController taskNameController = TextEditingController();

  TextEditingController taskTypeController = TextEditingController();
  TextEditingController assignerController = TextEditingController();

  final _userKey = GlobalKey<FormState>();
  TextEditingController userController = TextEditingController();

  final _dateLineKey = GlobalKey<FormState>();
  TextEditingController dateLineController = TextEditingController();

  final _descriptionKey = GlobalKey<FormState>();
  TextEditingController descriptionController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    _cubit.getListUsers();
    if (widget.isEdit ?? false) {
      _cubit.initUpdateState(widget.detailEntity ?? TaskEntity());
      _initUpdateData();
    }
    super.initState();
  }

  @override
  void dispose() {
    _cubit.resetStatus();
    _cubit.resetData();
    taskNameController.dispose();
    taskTypeController.dispose();
    assignerController.dispose();
    userController.dispose();
    dateLineController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  _initUpdateData() {
    taskNameController.text = _cubit.state.taskName ?? "";
    dateLineController.text = _cubit.state.deadlineTime ?? "";
    userController.text = _cubit.state.strUsers ?? "";
    descriptionController.text = _cubit.state.description ?? "";
  }

  _openUsersBottomSheet(List<UserEntity> list) async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (BuildContext context) => SelectUserBottomSheet(
        listUsers: _cubit.state.listUsers ?? [],
        listCurrentUsers: _cubit.state.currentUsers ?? [],
        onUsersSelected: (users) {
          String user = users.map((sc) => sc.name).toList().join(",");
          if (user != _cubit.state.strUsers) {
            _cubit.onChangeUser(user);
            _cubit.onChangeCurrentUsers(users);
            if ((user).isNotEmpty) {
              _userKey.currentState?.validate();
            }
          }
        },
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

  void _goNotification() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
          child: const NotificationPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit, TaskState>(
      bloc: _cubit,
      listenWhen: (prev, cur) =>
          prev.createStatus != cur.createStatus ||
          prev.updateStatus != cur.updateStatus,
      listener: (context, state) {
        if (state.createStatus == LoadStatus.LOADING ||
            state.updateStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        } else if (state.createStatus == LoadStatus.SUCCESS ||
            state.updateStatus == LoadStatus.SUCCESS) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showInfo(
            title: "Thành công",
            message: (widget.isEdit ?? false)
                ? "Cập nhật công việc thành công!!!"
                : "Tạo mới công việc thành công!!!",
          );

          if (widget.isEdit ?? false) {
            Navigator.pop(context);
            Navigator.pop(context, true);
          } else {
            Navigator.pop(context, true);
          }
        } else if (state.createStatus == LoadStatus.FAILURE ||
            state.updateStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);
          _cubit.resetStatus();
          AppSnackBar.showWarning(
            title: "Cảnh báo",
            message: "Có lỗi xảy ra vui lòng thử lại sau!!!",
          );
        } else {
          LoadingOverlay.hide(context);
        }
      },
      builder: (context, state) {
        final s = S.of(context);
        return Scaffold(
          backgroundColor: AppTokensV2.bgDeep,
          body: AmbientBackgroundV2(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: StaggerRevealV2(
                      index: 0,
                      child: _topBar(s, widget.isEdit ?? false),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                      child: StaggerRevealV2(
                        index: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlassCardV2(
                              radius: AppTokensV2.radius,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _titleField(s),
                                  const SizedBox(height: 16),
                                  _priorityWidget(),
                                  const SizedBox(height: 16),
                                  _readOnlyField(
                                    title: s.to_jobtype,
                                    controller: taskTypeController
                                      ..text = "Thông thường",
                                  ),
                                  const SizedBox(height: 16),
                                  _readOnlyField(
                                    title: s.to_do_card_taskmaster,
                                    controller: assignerController
                                      ..text = GlobalData
                                              .instance.userProfile?.name ??
                                          "",
                                  ),
                                  const SizedBox(height: 16),
                                  _userField(s),
                                  const SizedBox(height: 16),
                                  _dateField(s),
                                  const SizedBox(height: 16),
                                  _descriptionField(s),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _bottomButtons(s),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(S s, bool isEdit) {
    return Row(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          isEdit ? s.to_edit_title : s.to_create_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
          child: Icon(Icons.notifications_none_rounded,
              size: 20, color: AppTokensV2.fgSoft),
        ),
      ),
    ]);
  }

  Widget _fieldLabel(String title, {bool required = false}) {
    return Row(children: [
      Text(title, style: AppTokensV2.caption),
      if (required) ...[
        const SizedBox(width: 4),
        Text("*",
            style: TextStyle(color: AppTokensV2.danger, fontSize: 12)),
      ],
    ]);
  }

  Widget _titleField(S s) {
    return Form(
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel(s.to_task_title, required: true),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppTokensV2.surfaceStrong,
                    borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
                    border: Border.all(color: AppTokensV2.border),
                  ),
                  child: TextFormField(
                    controller: taskNameController,
                    maxLength: InputLimits.taskTitle,
                    buildCounter: inputCounterV2(always: false),
                    style: AppTokensV2.body,
                    cursorColor: AppTokensV2.accent,
                    onChanged: (value) {
                      _titleKey.currentState!.validate();
                      _cubit.onChangeTaskName(value);
                    },
                    validator: (value) =>
                        Validator.validateEmpty(value, "Tiêu đề"),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      errorStyle: TextStyle(height: 0, fontSize: 0),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _priorityWidget() {
    return BlocBuilder<TaskCubit, TaskState>(
      bloc: _cubit,
      buildWhen: (prev, cur) => prev.taskPriority != cur.taskPriority,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).to_priority_level, style: AppTokensV2.caption),
            const SizedBox(height: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                _cubit.onChangeTakPriority();
              },
              child: Icon(
                state.taskPriority
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 26,
                color: state.taskPriority
                    ? AppTokensV2.warn
                    : AppTokensV2.fgMuted,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _readOnlyField({
    required String title,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(title),
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

  Widget _userField(S s) {
    return Form(
      key: _userKey,
      child: BlocListener<TaskCubit, TaskState>(
        bloc: _cubit,
        listenWhen: (prev, cur) =>
            prev.currentUsers != cur.currentUsers ||
            prev.strUsers != cur.strUsers,
        listener: (context, state) {
          final text = state.strUsers ?? "";
          userController.value = userController.value.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
            composing: TextRange.empty,
          );

          if (text.isNotEmpty) {
            _userKey.currentState?.validate();
          }
        },
        child: BlocBuilder<TaskCubit, TaskState>(
          bloc: _cubit,
          buildWhen: (prev, cur) =>
              prev.strUsers != cur.strUsers ||
              prev.currentUsers != cur.currentUsers ||
              prev.listUsers != cur.listUsers,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel(s.to_do_card_employee, required: true),
                const SizedBox(height: 6),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openUsersBottomSheet(state.listUsers ?? []),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 46),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTokensV2.surfaceStrong,
                      borderRadius:
                          BorderRadius.circular(AppTokensV2.radiusSm),
                      border: Border.all(color: AppTokensV2.border),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          userController.text,
                          style: userController.text.isNotEmpty
                              ? AppTokensV2.body
                              : AppTokensV2.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20, color: AppTokensV2.fgMuted),
                    ]),
                  ),
                ),
                // Form ẩn để giữ nguyên hành vi validate của bản cũ.
                Offstage(
                  child: TextFormField(
                    controller: userController,
                    validator: (value) =>
                        Validator.validateEmpty(value, "Người được phân công "),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _dateField(S s) {
    return Form(
      key: _dateLineKey,
      child: BlocListener<TaskCubit, TaskState>(
        bloc: _cubit,
        listenWhen: (prev, cur) =>
            prev.deadlineDateTime != cur.deadlineDateTime ||
            prev.deadlineTime != cur.deadlineTime,
        listener: (context, state) {
          final text = state.deadlineTime ?? "";
          dateLineController.value = dateLineController.value.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
            composing: TextRange.empty,
          );

          if (text.isNotEmpty) {
            _dateLineKey.currentState?.validate();
          }
        },
        child: BlocBuilder<TaskCubit, TaskState>(
          bloc: _cubit,
          buildWhen: (prev, cur) =>
              prev.deadlineDateTime != cur.deadlineDateTime ||
              prev.deadlineTime != cur.deadlineTime,
          builder: (context, state) {
            dateLineController.text = state.deadlineTime ?? "";
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel(s.to_do_card_deadline, required: true),
                const SizedBox(height: 6),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showDatePicker(
                      defaultValue: state.deadlineDateTime,
                      onConfirm: (selectedDate) {
                        _selectedDate = selectedDate;
                        logger.d(
                            "selectedDate :: ${selectedDate.toIso8601String()}");
                        _cubit.setDeadlineDate(selectedDate);
                      },
                    );
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 46),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTokensV2.surfaceStrong,
                      borderRadius:
                          BorderRadius.circular(AppTokensV2.radiusSm),
                      border: Border.all(color: AppTokensV2.border),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          dateLineController.text,
                          style: dateLineController.text.isNotEmpty
                              ? AppTokensV2.body
                              : AppTokensV2.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.calendar_today_rounded,
                          size: 16, color: AppTokensV2.fgMuted),
                    ]),
                  ),
                ),
                Offstage(
                  child: TextFormField(
                    controller: dateLineController,
                    validator: (value) =>
                        Validator.validateEmpty(value, "Hạn chót"),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _descriptionField(S s) {
    return Form(
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel(s.to_description, required: true),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppTokensV2.surfaceStrong,
                    borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
                    border: Border.all(color: AppTokensV2.border),
                  ),
                  child: TextFormField(
                    controller: descriptionController,
                    maxLength: InputLimits.taskDescription,
                    buildCounter: inputCounterV2(),
                    maxLines: 5,
                    style: AppTokensV2.body,
                    cursorColor: AppTokensV2.accent,
                    onChanged: (value) {
                      _descriptionKey.currentState!.validate();
                      _cubit.onChangeDescription(value);
                    },
                    validator: (value) =>
                        Validator.validateEmpty(value, "Mô tả"),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      errorStyle: TextStyle(height: 0, fontSize: 0),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _bottomButtons(S s) {
    return Row(children: [
      Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              border: Border.all(color: AppTokensV2.border),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              s.cancel,
              textAlign: TextAlign.center,
              style: AppTokensV2.body,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: PrimaryButtonV2(
          label: (widget.isEdit ?? false) ? s.confirm : s.save,
          onTap: () {
            (widget.isEdit ?? false) ? doUpdateTask() : createNewTask();
          },
        ),
      ),
    ]);
  }

  // funcs
  createNewTask() async {
    final taskNameValid = _titleKey.currentState?.validate() ?? false;
    final userValid = _userKey.currentState?.validate() ?? false;
    final deadlineValid = _dateLineKey.currentState?.validate() ?? false;
    final descValid = _descriptionKey.currentState?.validate() ?? false;
    if (taskNameValid && userValid && deadlineValid && descValid) {
      _cubit.createNewTask();
    }
  }

  doUpdateTask() async {
    final taskNameValid = _titleKey.currentState?.validate() ?? false;
    final userValid = _userKey.currentState?.validate() ?? false;
    final deadlineValid = _dateLineKey.currentState?.validate() ?? false;
    final descValid = _descriptionKey.currentState?.validate() ?? false;
    if (taskNameValid && userValid && deadlineValid && descValid) {
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
        content:
            "Thông tin sẽ được thay đổi. Bạn chắc chắn muốn thay đổi thông tin này?",
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
