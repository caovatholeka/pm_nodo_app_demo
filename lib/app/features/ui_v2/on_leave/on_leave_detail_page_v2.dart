import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/detail_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/widget/reject_reason_dialog.dart';
import 'package:pm_app/app/features/ui_v2/on_leave/create_new_leave_page_v2.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_assets.dart';
import '../../../data/models/entities/on_leave_entity.dart';
import 'package:pm_app/app/core/theme_v2/widgets/bottom_sheet_bar_theme_v2.dart';

/// Màn Chi tiết đơn nghỉ — phiên bản giao diện tối (v2).
/// Hành vi/nghiệp vụ giữ NGUYÊN bản cũ [OnLeaveDetailPage]: cùng
/// [DetailOnLeaveCubit] (qua GetIt), cùng luật hiển thị nút hành động
/// (theo stageId/isDirector), cùng dialog xác nhận, cùng cách xử lý
/// kết quả (pop/snackbar). Chỉ đổi trình bày sang hệ thiết kế v2.
class OnLeaveDetailPageV2 extends StatefulWidget {
  final int? detailId;
  final OnLeaveEntity? detailEntity;

  const OnLeaveDetailPageV2({super.key, this.detailId, this.detailEntity});

  @override
  State<OnLeaveDetailPageV2> createState() => _OnLeaveDetailPageV2State();
}

class _OnLeaveDetailPageV2State extends State<OnLeaveDetailPageV2> {
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
        return AppTokensV2.fgMuted;
      case 14:
        return AppTokensV2.accent;
      case 11:
      case 15:
      case 9:
        return AppTokensV2.success;
      case 20:
      case 16:
      case 12:
        return AppTokensV2.danger;
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
            (context) => CreateNewLeavePageV2(
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

  // Bỏ nền sáng mặc định của khung nút ở đáy (Scaffold.bottomSheet) → chỉ còn nút.
  @override
  Widget build(BuildContext context) =>
      BottomSheetBarThemeV2(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
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
        } else if (state.confirmStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showError(
            title: s.warning,
            message: s.send_aprroval_failed,
          );
        } else if (state.deleteStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showError(
            title: s.warning,
            message: s.delete_approval_failed,
          );
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
            title: Text(s.day_off_detail_title, style: AppTokensV2.title),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StaggerRevealV2(index: 0, child: _headerCard(context)),
                    const SizedBox(height: 16),
                    StaggerRevealV2(index: 1, child: _infoCard(context)),
                  ],
                ),
              ),
            ),
          ),
          bottomSheet: _bottomBar(context),
        );
      },
    );
  }

  Widget _headerCard(BuildContext context) {
    final entity = _cubit.state.detailEntity;
    final id = entity?.leaveStage?.id ?? 0;
    final color = getStatusColor(id);

    return GlassCardV2(
      radius: AppTokensV2.radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entity?.employeeName ?? "",
                  style: AppTokensV2.section,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      getStatusTitle(id),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 15,
                color: AppTokensV2.fgMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${AppDateUtils.changeIso8601StringToDateTimeString(entity?.dateFrom)} - "
                  "${AppDateUtils.changeIso8601StringToDateTimeString(entity?.dateTo)}",
                  style: AppTokensV2.body,
                ),
              ),
            ],
          ),
          if ((entity?.holidayStatus ?? "").isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event_note_rounded,
                  size: 15,
                  color: AppTokensV2.fgMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entity?.holidayStatus ?? "",
                    style: AppTokensV2.captionStrong,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    final entity = _cubit.state.detailEntity;

    return GlassCardV2(
      radius: AppTokensV2.radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItem(
            S.of(context).day_off_card_department,
            entity?.departmentName ?? "",
          ),
          const SizedBox(height: 14),
          _buildItem(
            S.of(context).day_off_card_reason,
            entity?.description ?? "",
          ),
          const SizedBox(height: 14),
          _buildItem(
            S.of(context).day_off_left,
            GlobalData.instance.userProfile?.remainLeave
                    .toString()
                    .replaceAll(".0", "") ??
                "",
          ),
          const SizedBox(height: 14),
          _buildItem(
            S.of(context).day_off_card_cancel_reason,
            entity?.reasonCancel ?? "",
          ),
          const SizedBox(height: 14),
          _buildItem(
            S.of(context).day_off_approver,
            entity?.userApprove?.name ?? "",
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 4,
          child: Text(
            title,
            style: AppTokensV2.caption,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 6,
          child: Text(
            value,
            style: AppTokensV2.captionStrong,
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.fade,
          ),
        ),
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

  Widget _bottomBar(BuildContext context) {
    final s = S.of(context);
    final stageId = _cubit.state.detailEntity?.leaveStage?.id;

    if (stageId == 13) {
      return Container(
        margin: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: MediaQuery.of(context).padding.bottom + 18,
          top: 0,
        ),
        child: Row(
          children: [
            Expanded(
              child: _dangerButton(
                label: s.day_off_btn_delete,
                onTap: showDeleteConfirmDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _secondaryButton(
                label: s.day_off_btn_send_approval,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _cubit.confirmHrLeave(_cubit.state.detailEntity?.id ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButtonV2(
                label: s.day_off_btn_edit,
                onTap: () => doUpdate(context),
              ),
            ),
          ],
        ),
      );
    }

    if (stageId == 14 && isDirector) {
      return Container(
        margin: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: MediaQuery.of(context).padding.bottom + 18,
          top: 0,
        ),
        child: Row(
          children: [
            Expanded(
              child: _dangerButton(label: s.deny, onTap: _onDirectorReject),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButtonV2(
                label: s.authorize,
                onTap: _onDirectorApprove,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _secondaryButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppTokensV2.surfaceStrong,
          border: Border.all(color: AppTokensV2.border),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTokensV2.body,
        ),
      ),
    );
  }

  Widget _dangerButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppTokensV2.danger.withValues(alpha: 0.14),
          border: Border.all(color: AppTokensV2.danger.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTokensV2.danger,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
