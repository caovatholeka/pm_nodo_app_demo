import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/detail_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/create_new_leave_page.dart';
import 'package:pm_app/app/features/ui/on_leave/widget/reject_reason_dialog.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../data/models/entities/on_leave_entity.dart';
import '../../widgets/custom_dash_view.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/primary_button.dart';

class OnLeaveDetailPage extends StatefulWidget {
  final int? detailId;
  final OnLeaveEntity? detailEntity;

  const OnLeaveDetailPage({super.key, this.detailId, this.detailEntity});

  @override
  State<OnLeaveDetailPage> createState() => _OnLeaveDetailPageState();
}

class _OnLeaveDetailPageState extends State<OnLeaveDetailPage> {
  final _cubit = GetIt.I.get<DetailOnLeaveCubit>();

  bool get isDirector {
    final jobTitle =
        GlobalData.instance.userProfile?.jobTitle?.toLowerCase() ?? "";
    return jobTitle.contains("giám đốc");
  }

  @override
  void initState() {
    _cubit.getDetailOnLeave(widget.detailId ?? 0);
    super.initState();
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

  void _showRejectReasonDialog() {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) {
        return RejectReasonDialog(
          title: s.on_leave_deny_reason,
          description: s.on_leave_deny_sub,
          hintText: s.on_leave_deny_reason_type,
          onConfirm: (reason) {
            final id = _cubit.state.detailEntity?.id ?? 0;
            if (id != 0) {
              _cubit.rejectLeave(id, reason);
            }
          },
        );
      },
    );
  }

  Color getStatusColor(int id) {
    switch (id) {
      case 1:
      case 6:
      case 13:
      case 17:
        return AppColors.colorDraft;
      case 14:
        return AppColors.colorApproved;
      case 11:
      case 15:
      case 9:
        return AppColors.colorFinished;
      case 20:
      case 16:
      case 12:
        return AppColors.colorCancel;
      default:
        return Colors.transparent;
    }
  }

  Color getBgColor(int status) {
    switch (status) {
      case 1:
      case 6:
      case 13:
      case 17:
        return AppColors.colorDraft.withValues(alpha: 0.1);
      case 14:
        return AppColors.colorApproved.withValues(alpha: 0.1);
      case 11:
      case 15:
      case 9:
        return AppColors.colorFinished.withValues(alpha: 0.1);
      case 20:
      case 16:
      case 12:
        return AppColors.colorCancel.withValues(alpha: 0.1);
      default:
        return Colors.transparent;
    }
  }

  String getStatusTitle(int status) {
    final s = S.of(context);
    switch (status) {
      case 1:
      case 6:
      case 13:
      case 17:
        return s.bt_status1;
      case 14:
        return s.bt_status2;
      case 11:
      case 15:
      case 9:
        return s.bt_status3;
      case 20:
      case 16:
      case 12:
        return s.cancel;
      default:
        return "";
    }
  }

  Future<void> doUpdate(BuildContext context) async {
    final navigator = Navigator.of(context);
    final bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateNewLeavePage(
              isEdit: true,
              detailEntity: _cubit.state.detailEntity,
            ),
      ),
    );
    if (updated == true) {
      if (!mounted) return;
      navigator.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<DetailOnLeaveCubit, DetailOnLeaveState>(
      bloc: _cubit,
      listenWhen: (previous, current) =>
          previous.loadStatus != current.loadStatus ||
          previous.deleteStatus != current.deleteStatus ||
          previous.confirmStatus != current.confirmStatus ||
          previous.approveStatus != current.approveStatus ||
          previous.rejectStatus != current.rejectStatus,
      listener: (context, state) {
        if (state.loadStatus == LoadStatus.LOADING ||
            state.deleteStatus == LoadStatus.LOADING ||
            state.confirmStatus == LoadStatus.LOADING ||
            state.approveStatus == LoadStatus.LOADING ||
            state.rejectStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        } else if (state.deleteStatus == LoadStatus.SUCCESS) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          Navigator.pop(context, true);
          AppSnackBar.showInfo(title: s.success, message: s.delete_success);

          // _showDialog(
          //   title: "Thành công",
          //   message: "Xoá bản ghi thành công!",
          //   success: true,
          //   onConfirm: () => Navigator.pop(context, true),
          // );
        } else if (state.approveStatus == LoadStatus.SUCCESS) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          Navigator.pop(context, true);

          Flushbar(
            message: s.on_leave_success,
            backgroundColor: Colors.green,
            flushbarPosition: FlushbarPosition.TOP,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        } else if (state.approveStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);

          Flushbar(
            message: s.on_leave_failed,
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        } else if (state.confirmStatus == LoadStatus.SUCCESS) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          Navigator.pop(context, true);
          AppSnackBar.showInfo(
            title: s.success,
            message: s.send_approval_success,
          );
          // _showDialog(
          //   title: "Thành công",
          //   message: "Đã gửi duyệt thành công!",
          //   success: true,
          //   onConfirm: () => Navigator.pop(context, true),
          // );
        } else if (state.confirmStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showError(
            title: s.warning,
            message: s.send_aprroval_failed,
          );
          // _showDialog(title: "Lỗi", message: "Gửi duyệt lỗi!", success: false);
        } else if (state.deleteStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showError(
            title: s.warning,
            message: s.delete_approval_failed,
          );
          // _showDialog(
          //   title: "Lỗi",
          //   message: "Không xóa được bản ghi khác nháp!",
          //   success: false,
          // );
        } else if (state.rejectStatus == LoadStatus.SUCCESS) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          Navigator.pop(context, true);

          Flushbar(
            message: s.on_leave_deny_success,
            backgroundColor: Colors.green,
            flushbarPosition: FlushbarPosition.TOP,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        } else if (state.rejectStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);

          Flushbar(
            message: s.on_leave_deny_failed,
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.warning, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        } else {
          LoadingOverlay.hide(context);
        }
      },

      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bodyColor,
          appBar: MyAppBar(
            titleAppbar: s.day_off_detail_title,
            haveBackButton: true,
          ),
          // extendBodyBehindAppBar: true,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: _contentBody,
                ),
              ],
            ),
          ),
          bottomSheet: _bottomSheet,
        );
      },
    );
  }

  get _contentBody {
    final entity = _cubit.state.detailEntity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItem(
          S.of(context).day_off_card_employee,
          entity?.employeeName ?? "",
        ).paddingOnly(bottom: 12),
        CustomDashView(),

        _buildItem(
          S.of(context).day_off_card_department,
          entity?.departmentName ?? "",
        ).paddingOnly(top: 12, bottom: 12),
        CustomDashView(),

        // _buildItem("Số phép còn lại",
        //         (entity?.remainLeave ?? 0).toString())
        //     .paddingOnly(top: 12, bottom: 12),
        // CustomDashView(),
        _buildItem(
          S.of(context).day_off_card_type,
          entity?.holidayStatus ?? "",
        ).paddingOnly(top: 12, bottom: 12),
        CustomDashView(),

        _buildItem(
          S.of(context).day_off_card_from,
          AppDateUtils.changeIso8601StringToDateTimeString(entity?.dateFrom),
        ).paddingOnly(top: 12, bottom: 12),
        CustomDashView(),

        _buildItem(
          S.of(context).day_off_card_to,
          AppDateUtils.changeIso8601StringToDateTimeString(entity?.dateTo),
        ).paddingOnly(top: 12, bottom: 12),
        CustomDashView(),

        _buildItem(
          S.of(context).day_off_card_reason,
          entity?.description ?? "",
        ).paddingOnly(top: 12, bottom: 12),
        CustomDashView(),

        _buildItem(
          S.of(context).day_off_left,
          GlobalData.instance.userProfile?.remainLeave.toString().replaceAll(
                ".0",
                "",
              ) ??
              "",
        ).paddingOnly(top: 12, bottom: 12),
        CustomDashView(),

        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 10),
          child: _buildStatusRow,
        ),
        CustomDashView(),

        _buildItem(
          S.of(context).day_off_card_cancel_reason,
          entity?.reasonCancel ?? "",
        ).paddingOnly(top: 12, bottom: 12),
        CustomDashView(),

        _buildItem(
          S.of(context).day_off_approver,
          entity?.userApprove?.name ?? "",
        ).paddingOnly(top: 12, bottom: 12),

        const SizedBox(height: 10),
      ],
    );
  }

  void _onDirectorApprove() {
    final s = S.of(context);
    _showDialog(
      title: s.on_leave_confirm_approveLeave,
      message: s.on_leave_sub_confirm_approveLeave,
      success: true,
      onConfirm: () {
        final id = _cubit.state.detailEntity?.id ?? 0;
        if (id != 0) {
          _cubit.approveLeave(id);
        }
      },
    );
  }

  void _onDirectorReject() {
    _showRejectReasonDialog();
  }

  Widget get _bottomSheet {
    final s = S.of(context);
    final stageId = _cubit.state.detailEntity?.leaveStage?.id;

    if (stageId == 13) {
      return Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 36),
        width: double.infinity,
        height: 46,
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                mainText: S.of(context).day_off_btn_delete,
                type: PrimaryButtonType.secondary,
                callback: showDeleteConfirmDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                mainText: S.of(context).day_off_btn_send_approval,
                type: PrimaryButtonType.primary,
                callback: () {
                  _cubit.confirmHrLeave(_cubit.state.detailEntity?.id ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                mainText: S.of(context).day_off_btn_edit,
                type: PrimaryButtonType.primary,
                callback: () => doUpdate(context),
              ),
            ),
          ],
        ),
      );
    }

    if (stageId == 14 && isDirector) {
      return Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 36),
        width: double.infinity,
        height: 46,
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                mainText: s.deny,
                type: PrimaryButtonType.secondary,
                callback: _onDirectorReject,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                mainText: s.authorize,
                type: PrimaryButtonType.primary,
                callback: _onDirectorApprove,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void showDeleteConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (_) => CustomDialog(
            iconPath: AppAssets.ic_delete,
            title: S.of(context).confirm_delete,
            content: S.of(context).day_off_confirm_dialog_delete,
            success: false,
            confirmText: S.of(context).day_off_btn_delete,
            cancelText: S.of(context).cancel,
            onConfirm: () {
              Navigator.pop(context);
              _cubit.deleteOnLeave(_cubit.state.detailEntity?.id ?? 0);
            },
          ),
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

  get _buildStatusRow {
    final id = _cubit.state.detailEntity?.leaveStage?.id ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          S.of(context).day_off_card_status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.themeBlackDefault,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: getBgColor(id),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: getStatusColor(id),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                getStatusTitle(id),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: getStatusColor(id),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
