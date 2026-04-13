import 'package:another_flushbar/flushbar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/approve_ob_param.dart';
import 'package:pm_app/app/data/models/param/cancel_ob_param.dart';
import 'package:pm_app/app/features/ui/on_leave/widget/reject_reason_dialog.dart';
import 'package:pm_app/app/features/ui/work_trip/request_new_trip_page.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_cubit.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/custom_dash_view.dart';
import '../../widgets/custom_dialog.dart';

class WorkTripDetailPage extends StatefulWidget {
  int? workId;
  WorkTripEntity? workEntity;

  WorkTripDetailPage({super.key, this.workId, this.workEntity});

  @override
  State<WorkTripDetailPage> createState() => _WorkTripDetailPageState();
}

class _WorkTripDetailPageState extends State<WorkTripDetailPage> {
  final _cubit = GetIt.I.get<WorkTripCubit>();
  bool _handlingAction = false;

  @override
  void initState() {
    _cubit.getWorkTripDetail(widget.workId ?? 0);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool get _isDirector {
    final jobTitle = GlobalData.instance.userProfile?.jobTitle ?? "";
    return jobTitle.toLowerCase().contains('giám đốc');
  }

  bool get _isManagerApproveStage {
    final stageId = _cubit.state.detailWorkTrip?.stage?.id ?? 0;
    return stageId == 14 || stageId == 22 || stageId == 26 || stageId == 30;
  }

  // helper funcs
  Color getStatusColor(int id) {
    switch (id) {
      case 1:
      case 25:
      case 6:
      case 13:
      case 17:
      case 21:
        return AppColors.colorDraft;
      case 14:
      case 22:
      case 26:
      case 30:
        return AppColors.colorApproved;
      case 15:
      case 19:
      case 23:
      case 27:
      case 31:
        return AppColors.colorFinished;
      case 20:
      case 16:
      case 12:
      case 24:
      case 28:
      case 32:
        return AppColors.colorCancel;
      default:
        return Colors.transparent;
    }
  }

  Color getBgColor(int status) {
    switch (status) {
      case 1:
      case 25:
      case 6:
      case 13:
      case 17:
      case 21:
        return AppColors.colorDraft.withValues(alpha: 0.1);
      case 14:
      case 22:
      case 26:
      case 30:
        return AppColors.colorApproved.withValues(alpha: 0.1);
      case 15:
      case 19:
      case 23:
      case 27:
      case 31:
        return AppColors.colorFinished.withValues(alpha: 0.1);
      case 20:
      case 16:
      case 12:
      case 24:
      case 28:
      case 32:
        return AppColors.colorCancel.withValues(alpha: 0.1);
      default:
        return Colors.transparent;
    }
  }

  String getStatusTitle(int status) {
    switch (status) {
      case 1:
      case 25:
      case 6:
      case 13:
      case 17:
      case 21:
        return S.of(context).bt_status1;
      case 14:
      case 22:
      case 26:
      case 30:
        return S.of(context).bt_status2;
      case 15:
      case 19:
      case 23:
      case 27:
      case 31:
        return S.of(context).bt_status3;
      case 20:
      case 16:
      case 12:
      case 24:
      case 28:
      case 32:
        return S.of(context).cancel;
      default:
        return "";
    }
  }

  String mapScheduleDateType(String type) {
    final s = S.of(context);
    if (type == "before") {
      return s.morning;
    } else if (type == "after") {
      return s.afternoon;
    } else {
      return s.allday;
    }
  }

  Future<void> doUpdate(BuildContext context) async {
    final bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RequestNewTripPage(
              isEdit: true,
              detailEntity: _cubit.state.detailWorkTrip,
            ),
      ),
    );
    if (updated == true) {
      Navigator.pop(context, true);
    }
  }

  void showDeleteConfirmDialog() {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (_) => CustomDialog(
            iconPath: AppAssets.ic_delete,
            title: s.delete_confirm,
            content:
                "${s.delete_subtile} \n"
                "${s.delete_subtitle1}!",
            success: false,
            confirmText: s.day_off_btn_delete,
            cancelText: s.day_off_btn_delete,
            onConfirm: () {
              Navigator.pop(context);
              _cubit.onDeleteWorkTrip(_cubit.state.detailWorkTrip?.id ?? 0);
            },
          ),
    );
  }

  void _onSubmitWorkTrip() {
    _handlingAction = true;
    _cubit.onSubmitWorkTrip(_cubit.state.detailWorkTrip?.id ?? 0);
  }

  void _showApproveDialog() {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: s.confirm,
            content: s.bt_sub_approve,
            success: true,
            confirmText: s.confirm,
            cancelText: s.cancel,
            onConfirm: () {
              Navigator.pop(context);
              final id = _cubit.state.detailWorkTrip?.id ?? 0;

              final param = ApproveObParam(businessIds: [id]);
              _handlingAction = true;
              _cubit.onApproveWorkTrip(param);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
    );
  }

  void showRejectDialog(BuildContext context) {
    final s = S.of(context);

    final id = _cubit.state.detailWorkTrip?.id;
    if (id == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => RejectReasonDialog(
            title: s.bt_deny_title,
            description: s.bt_deny_sub,
            hintText: s.bt_deny_reason_type,
            onConfirm: (reason) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;

                final param = CancelObParam(note: reason);
                _handlingAction = true;
                _cubit.onRejectWorkTrip(id, param);
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      listenWhen:
          (prev, cur) =>
              prev.detailStatus != cur.detailStatus ||
              prev.deleteStatus != cur.deleteStatus ||
              prev.submitStatus != cur.submitStatus ||
              prev.approveStatus != cur.approveStatus ||
              prev.cancelStatus != cur.cancelStatus,
      listener: (context, state) {
        final hasMutationState =
            state.deleteStatus != LoadStatus.INITIAL ||
            state.submitStatus != LoadStatus.INITIAL ||
            state.approveStatus != LoadStatus.INITIAL ||
            state.cancelStatus != LoadStatus.INITIAL;

        if (hasMutationState && !_handlingAction) return;

        if (state.deleteStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);
          AppSnackBar.showInfo(title: s.success, message: s.delete_success);
          _handlingAction = false;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context).pop(true);
            _cubit.onResetStatus();
          });
          return;
        }

        if (state.submitStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);
          AppSnackBar.showInfo(
            title: s.success,
            message: s.send_approval_success,
          );
          _handlingAction = false;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context).pop(true);
            _cubit.onResetStatus();
          });
          return;
        }

        if (state.submitStatus == LoadStatus.FAILURE ||
            state.deleteStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);
          AppSnackBar.showError(
            title: s.warning,
            message: state.errMsg ?? s.to_do_failed,
          );
          _handlingAction = false;
          _cubit.onResetStatus();
          return;
        }

        if (state.approveStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);
          Flushbar(
            message: s.bt_confirm_susscess,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _handlingAction = false;
          _cubit.onResetStatus();
          _cubit.getWorkTripDetail(widget.workId ?? 0);
          return;
        }

        if (state.cancelStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);
          Flushbar(
            message: s.bt_cancel_success,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: const Color.fromARGB(255, 255, 0, 0),
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _handlingAction = false;
          _cubit.onResetStatus();
          _cubit.getWorkTripDetail(widget.workId ?? 0);
          return;
        }

        final isLoading =
            state.submitStatus == LoadStatus.LOADING ||
            state.deleteStatus == LoadStatus.LOADING ||
            state.approveStatus == LoadStatus.LOADING ||
            state.cancelStatus == LoadStatus.LOADING;

        if (isLoading) {
          LoadingOverlay.show(context);
        } else {
          LoadingOverlay.hide(context);
        }
      },
      builder: (context, state) {
        bool isDraft = false;
        if (state.detailWorkTrip?.stage?.id == 25 ||
            state.detailWorkTrip?.stage?.id == 1 ||
            state.detailWorkTrip?.stage?.id == 6 ||
            state.detailWorkTrip?.stage?.id == 13 ||
            state.detailWorkTrip?.stage?.id == 17 ||
            state.detailWorkTrip?.stage?.id == 21) {
          isDraft = true;
        }

        return Scaffold(
          backgroundColor: AppColors.bodyColor,
          appBar: MyAppBar(
            titleAppbar: S.of(context).bt_detailTitle,
            haveBackButton: true,
          ),
          body:
              (state.detailStatus == LoadStatus.LOADING)
                  ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.themePrimaryDefault,
                    ),
                  )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: BlocBuilder<WorkTripCubit, WorkTripState>(
                      bloc: _cubit,
                      buildWhen:
                          (prev, cur) =>
                              prev.detailWorkTrip != cur.detailWorkTrip ||
                              prev.detailStatus != cur.detailStatus,
                      builder: (context, state) {
                        final employees = (state.detailWorkTrip?.employees ??
                                [])
                            .map((u) => u.name)
                            .join(',\n');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildItem(
                                    S.of(context).bt_employee,
                                    employees,
                                  ).paddingOnly(bottom: 8),
                                  CustomDashView().paddingOnly(bottom: 8),
                                  _buildItem(
                                    S.of(context).bt_detail_total,
                                    (state.detailWorkTrip?.totalPeople ?? 0)
                                        .toString(),
                                  ).paddingOnly(bottom: 8),
                                  CustomDashView().paddingOnly(bottom: 8),
                                  _buildItem(
                                    S.of(context).bt_detail_createBy,
                                    (state.detailWorkTrip?.employeeName ?? ""),
                                  ).paddingOnly(bottom: 8),
                                  CustomDashView().paddingOnly(bottom: 8),
                                  _buildItem(
                                    S.of(context).bt_detail_form,
                                    (state.detailWorkTrip?.fromDate ?? ""),
                                  ).paddingOnly(bottom: 8),
                                  CustomDashView().paddingOnly(bottom: 8),
                                  _buildItem(
                                    S.of(context).bt_detail_to,
                                    (state.detailWorkTrip?.toDate ?? ""),
                                  ).paddingOnly(bottom: 8),
                                  CustomDashView().paddingOnly(bottom: 8),
                                  _buildItem(
                                    S.of(context).bt_detail_totalDay,
                                    "${state.detailWorkTrip?.numberOfDays ?? 0.0}",
                                  ).paddingOnly(bottom: 8),
                                  const SizedBox(height: 10),
                                  _buildListSchedules,
                                  const SizedBox(height: 4),
                                  _buildItem(
                                    S.of(context).bt_detail_notes,
                                    state.detailWorkTrip?.note ?? "",
                                  ).paddingOnly(bottom: 8),
                                  CustomDashView().paddingOnly(bottom: 8),
                                  _statusLine,
                                ],
                              ),
                            ).paddingOnly(bottom: 12),
                            // const SizedBox(height: 12,),
                            // _buildItem("Cần phòng khách sạn", "Có").paddingOnly(bottom: 6),
                            // CustomDashView().paddingOnly(bottom: 10),
                            // _buildItem("Qua đêm", "Có").paddingOnly(bottom: 6),
                            // CustomDashView().paddingOnly(bottom: 10),
                            // _buildItem(
                            //   S.of(context).bt_detail_notes,
                            //   state.detailWorkTrip?.note ?? "",
                            // ).paddingOnly(bottom: 6),
                            // CustomDashView().paddingOnly(bottom: 10),
                            // _statusLine,
                            // CustomDashView().paddingOnly(bottom: 20),

                            // (((state.detailWorkTrip?.createUid ?? 0) == GlobalData.instance.userProfile?.employeeId)
                            //   && isDraft) ? // trạng thái nháp
                            if (isDraft) ...[
                              _bottomSheetWidget,
                              const SizedBox(height: 30),
                            ] else if (_isDirector &&
                                _isManagerApproveStage) ...[
                              _directorApproveActions(state),
                              const SizedBox(height: 30),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
        );
      },
    );
  }

  // Widgets
  get _statusWidget {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: getBgColor(_cubit.state.detailWorkTrip?.stage?.id ?? 0),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: getStatusColor(
                _cubit.state.detailWorkTrip?.stage?.id ?? 0,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            getStatusTitle(_cubit.state.detailWorkTrip?.stage?.id ?? 0),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: getStatusColor(
                _cubit.state.detailWorkTrip?.stage?.id ?? 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  get _statusLine {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          S.of(context).bt_detail_status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.themeBlackDefault,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        _statusWidget,
      ],
    );
  }

  get _buildListSchedules {
    return Column(
      children:
          (_cubit.state.detailWorkTrip?.schedules ?? []).map((schedule) {
            return DottedBorder(
              color: AppColors.themePrimaryDefault,
              dashPattern: [4, 4],
              strokeWidth: 1,
              strokeCap: StrokeCap.round,
              borderType: BorderType.RRect,
              radius: Radius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Column(
                  children: [
                    _buildItem(
                      S.of(context).bt_detail_date,
                      (schedule.dateFrom ?? ""),
                    ).paddingOnly(bottom: 6),
                    CustomDashView().paddingOnly(bottom: 6),
                    _buildItem(
                      S.of(context).bt_detail_type,
                      mapScheduleDateType((schedule.type ?? "")),
                    ).paddingOnly(bottom: 6),
                  ],
                ),
              ),
            ).paddingOnly(bottom: 12);
          }).toList(),
    );
  }

  get _bottomSheetWidget {
    return BlocBuilder<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      buildWhen: (prev, cur) => prev.detailWorkTrip != cur.detailWorkTrip,
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  _onSubmitWorkTrip();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    border: Border.all(
                      width: 1,
                      color: AppColors.themeBlackDefault.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    S.of(context).bt_detail_sendApproval,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.themePrimaryDefault,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () {
                  showDeleteConfirmDialog();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    border: Border.all(
                      width: 1,
                      color: AppColors.themeBlackDefault.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    S.of(context).bt_detail_delete,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.themePrimaryDefault,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () {
                  doUpdate(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.themePrimaryDefault,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    border: Border.all(
                      width: 1,
                      color: AppColors.themeBlackDefault.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    S.of(context).bt_detail_update,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.whiteColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _directorApproveActions(WorkTripState state) {
    final s = S.of(context);
    final isLoading =
        state.submitStatus == LoadStatus.LOADING ||
        state.deleteStatus == LoadStatus.LOADING;

    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            mainText: s.deny,
            type: PrimaryButtonType.secondary,
            enable: !isLoading,
            isLoading: false,
            callback: () {
              showRejectDialog(context);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            mainText: s.authorize,
            type: PrimaryButtonType.primary,
            enable: !isLoading,
            isLoading: false,
            callback: () {
              _showApproveDialog();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 4,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.themeBlackDefault,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        Flexible(
          flex: 6,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.themeBlackDefault,
            ),
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.fade,
          ),
        ),
      ],
    );
  }
}
