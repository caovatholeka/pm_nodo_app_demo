import 'package:pm_app/app/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/explanation_tab/explanation_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../../../core/commons/app_assets.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../../data/models/entities/work_entry_entity.dart';


class SendInvalidPage extends StatefulWidget {
  WorkEntryEntity? workEntryEntity;

  SendInvalidPage({super.key, this.workEntryEntity});

  @override
  State<SendInvalidPage> createState() => _SendInvalidPageState();
}

class _SendInvalidPageState extends State<SendInvalidPage> {
  final _cubit = GetIt.I.get<ExplanationCubit>();
  final TextEditingController controller = TextEditingController();

  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //(widget.workEntryEntity?.note.toString() ?? "").isNotEmpty
    if ((widget.workEntryEntity?.state ?? "") == "hr_confirm") {
      _cubit.onChangeReason(widget.workEntryEntity?.note.toString() ?? "");
      _cubit.onChangeStartTime(
        Utils().floatToTimeString(
              widget.workEntryEntity?.dateStartCommit ?? 0.0,
            ) ??
            "",
      );
      _cubit.onChangeEndTime(
        Utils().floatToTimeString(
              (widget.workEntryEntity?.dateStopCommit ?? 0.0),
            ) ??
            "",
      );
    } else {
      _cubit.onChangeReason("");
      _cubit.onChangeStartTime("");
      _cubit.onChangeEndTime("");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cubit.resetData();
  }

  void _goNotification() {
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<ExplanationCubit, ExplanationState>(
      bloc: _cubit,
      listenWhen:
          (prev, cur) =>
              prev.sendInvalidStatus != cur.sendInvalidStatus ||
              prev.errorMsg != cur.errorMsg,
      listener: (context, state) {
        if (state.sendInvalidStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        } else if (state.sendInvalidStatus == LoadStatus.SUCCESS) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showInfo(
            title: s.attention,
            message: s.attendance_sendSuccess,
          );
          Navigator.pop(context, true);
        } else if (state.sendInvalidStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showWarning(title: s.warning, message: state.errorMsg);
        } else {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bodyColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: MyAppBar(
                  titleAppbar: s.attendance_title,
                  haveBackButton: true,
                  haveActionButton: true,
                  iconPathAsset: AppAssets.icNotificationBell,
                  actionCallBack: () async {
                    _goNotification();
                  },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      InputTextField(
                        title: s.attendance_employee,
                        hintText: "",
                        isRequiredField: false,
                        readOnly: true,
                        enable: false,
                        controller: TextEditingController(
                          text:
                              "${GlobalData.instance.userProfile?.name ?? ""} (NV"
                              "${GlobalData.instance.userProfile?.employeeCode ?? ""})",
                        ),
                      ),
                      const SizedBox(height: 12),
                      InputTextField(
                        title: s.attendance_department,
                        hintText: "",
                        isRequiredField: false,
                        readOnly: true,
                        enable: false,
                        controller: TextEditingController(
                          text:
                              GlobalData
                                  .instance
                                  .userProfile
                                  ?.department
                                  ?.name ??
                              "",
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child:
                                BlocBuilder<ExplanationCubit, ExplanationState>(
                                  bloc: _cubit,
                                  buildWhen:
                                      (prev, cur) =>
                                          prev.startTime != cur.startTime,
                                  builder: (context, state) {
                                    return InputTextField(
                                      title: s.attendance_timeCome,
                                      hintText: "00:00",
                                      isRequiredField: false,
                                      enable: true,
                                      controller:
                                          startTimeController
                                            ..text = state.startTime ?? "",
                                      onChange: (val) {
                                        _cubit.onChangeStartTime(val);
                                      },
                                    );
                                  },
                                ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child:
                                BlocBuilder<ExplanationCubit, ExplanationState>(
                                  bloc: _cubit,
                                  buildWhen:
                                      (prev, cur) =>
                                          prev.endTime != cur.endTime,
                                  builder: (context, state) {
                                    return InputTextField(
                                      title: s.attendance_timeLeave,
                                      hintText: "00:00",
                                      isRequiredField: false,
                                      enable: true,
                                      controller:
                                          endTimeController
                                            ..text = state.endTime ?? "",
                                      onChange: (val) {
                                        _cubit.onChangeEndTime(val);
                                      },
                                    );
                                  },
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InputTextField(
                        title: s.attendance_time,
                        hintText: "",
                        isRequiredField: false,
                        readOnly: true,
                        enable: false,
                        controller: TextEditingController(
                          text:
                              AppDateUtils.changeIso8601StringToDateTimeString(
                                widget.workEntryEntity?.date ?? "",
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InputTextField(
                        title: s.attendance_reason,
                        hintText: "",
                        isRequiredField: true,
                        enable: true,
                        controller: controller..text = state.reason ?? "",
                        maxLine: 5,
                        validator: (val) => Validator.validateExplanation(val),
                        onChange: (value) {
                          _cubit.onChangeReason(value);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _bottomSheet,
              ],
            ),
          ),
          // bottomSheet: _bottomSheet,
        );
      },
    );
  }

  get _bottomSheet {
    return BlocBuilder<ExplanationCubit, ExplanationState>(
      bloc: _cubit,
      buildWhen: (prev, cur) => prev.reason != cur.reason,
      builder: (context, state) {
        // bool isEnable = true;
        // if((state.reason ?? "").isEmpty ||
        //   widget.workEntryEntity?.state == "hr_confirm"){
        //   isEnable = false;
        // }
        return InkWell(
          onTap: () {
            if (Validator.isBlank(state.reason)) {
              AppSnackBar.showError(
                title: "Cảnh báo",
                message: "Vui lòng nhập giải trình",
              );
              return;
            }
            _cubit.sendInvalidReason(widget.workEntryEntity?.date ?? "");
          }, //: (){},
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            width: double.infinity,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.themePrimaryDefault,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Center(
              child: Text(
                S.of(context).confirm,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
