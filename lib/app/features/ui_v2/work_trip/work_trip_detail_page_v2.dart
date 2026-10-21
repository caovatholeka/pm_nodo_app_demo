import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/approve_ob_param.dart';
import 'package:pm_app/app/data/models/param/cancel_ob_param.dart';
import 'package:pm_app/app/features/ui/on_leave/widget/reject_reason_dialog.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_cubit.dart';
import 'package:pm_app/app/features/ui_v2/work_trip/request_new_trip_page_v2.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Chi tiết công tác — phiên bản giao diện tối (v2).
///
/// Hành vi/nghiệp vụ giữ NGUYÊN bản cũ [WorkTripDetailPage]: cùng
/// [WorkTripCubit] (qua GetIt, dùng chung — không đóng khi dispose), cùng
/// luật hiển thị nút hành động (Nháp -> gửi duyệt/xoá/cập nhật; các bước
/// duyệt của Giám đốc -> từ chối/duyệt), cùng dialog xác nhận, cùng cờ
/// [_handlingAction] điều khiển listener y hệt bản cũ (kể cả việc xoá đơn
/// KHÔNG bật cờ này — bản cũ cũng vậy).
class WorkTripDetailPageV2 extends StatefulWidget {
  int? workId;
  WorkTripEntity? workEntity;

  WorkTripDetailPageV2({super.key, this.workId, this.workEntity});

  @override
  State<WorkTripDetailPageV2> createState() => _WorkTripDetailPageV2State();
}

class _WorkTripDetailPageV2State extends State<WorkTripDetailPageV2> {
  final _cubit = GetIt.I.get<WorkTripCubit>();
  bool _handlingAction = false;

  @override
  void initState() {
    _cubit.getWorkTripDetail(widget.workId ?? 0);
    super.initState();
  }

  bool get _isDirector {
    final jobTitle = GlobalData.instance.userProfile?.jobTitle ?? "";
    return jobTitle.toLowerCase().contains('giám đốc');
  }

  bool get _isManagerApproveStage {
    final stageId = _cubit.state.detailWorkTrip?.stage?.id ?? 0;
    return stageId == 14 || stageId == 22 || stageId == 26 || stageId == 30;
  }

  Color _getStatusColor(int id) {
    switch (id) {
      case 1:
      case 25:
      case 6:
      case 13:
      case 17:
      case 21:
        return AppTokensV2.fgMuted;
      case 14:
      case 22:
      case 26:
      case 30:
        return AppTokensV2.accent;
      case 15:
      case 19:
      case 23:
      case 27:
      case 31:
        return AppTokensV2.success;
      case 20:
      case 16:
      case 12:
      case 24:
      case 28:
      case 32:
        return AppTokensV2.danger;
      default:
        return AppTokensV2.fgMuted;
    }
  }

  String _getStatusTitle(int status) {
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

  String _mapScheduleDateType(String type) {
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
            (context) => RequestNewTripPageV2(
              isEdit: true,
              detailEntity: _cubit.state.detailWorkTrip,
            ),
      ),
    );
    if (updated == true) {
      if (!mounted) return;
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
          (dialogContext) => CustomDialog(
            iconPath: AppAssets.ic_delete,
            title: s.delete_confirm,
            content: "${s.delete_subtile} \n${s.delete_subtitle1}!",
            success: false,
            confirmText: s.day_off_btn_delete,
            cancelText: s.cancel,
            onConfirm: () {
              Navigator.pop(dialogContext);
              // Thiếu dòng này nên listener bỏ qua kết quả xóa: không loading, không báo,
              // không quay về danh sách.
              _handlingAction = true;
              _cubit.onDeleteWorkTrip(_cubit.state.detailWorkTrip?.id ?? 0);
            },
            onCancel: () => Navigator.pop(dialogContext),
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
            title: Text(s.bt_detailTitle, style: AppTokensV2.title),
            centerTitle: false,
          ),
          body: AmbientBackgroundV2(
            child: SafeArea(
              child:
                  (state.detailStatus == LoadStatus.LOADING)
                      ? Center(
                        child: CircularProgressIndicator(
                          color: AppTokensV2.accent,
                          strokeWidth: 2.2,
                        ),
                      )
                      : _buildBody(state),
            ),
          ),
          bottomSheet: _bottomBar(state),
        );
      },
    );
  }

  Widget _buildBody(WorkTripState state) {
    final entity = state.detailWorkTrip;
    if (entity == null) return const SizedBox();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top > 0 ? 8 : 18,
        18,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaggerRevealV2(index: 0, child: _headerCard(entity)),
          const SizedBox(height: 16),
          StaggerRevealV2(index: 1, child: _infoCard(entity)),
          if ((entity.schedules ?? []).isNotEmpty) ...[
            const SizedBox(height: 16),
            StaggerRevealV2(index: 2, child: _scheduleCard(entity)),
          ],
        ],
      ),
    );
  }

  Widget _headerCard(WorkTripEntity entity) {
    final id = entity.stage?.id ?? 0;
    final color = _getStatusColor(id);
    final employees = (entity.employees ?? []).map((u) => u.name).join(', ');

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
                  employees,
                  style: AppTokensV2.section,
                  maxLines: 2,
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
                      _getStatusTitle(id),
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
                  "${entity.fromDate ?? ""} - ${entity.toDate ?? ""}",
                  style: AppTokensV2.body,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(WorkTripEntity entity) {
    final s = S.of(context);
    return GlassCardV2(
      radius: AppTokensV2.radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItem(
            s.bt_detail_total,
            (entity.totalPeople ?? 0).toString(),
          ),
          const SizedBox(height: 14),
          _buildItem(s.bt_detail_createBy, entity.employeeName ?? ""),
          const SizedBox(height: 14),
          _buildItem(s.bt_detail_totalDay, "${entity.numberOfDays ?? 0.0}"),
          const SizedBox(height: 14),
          _buildItem(s.bt_detail_notes, entity.note ?? ""),
        ],
      ),
    );
  }

  Widget _scheduleCard(WorkTripEntity entity) {
    final s = S.of(context);
    final schedules = entity.schedules ?? [];

    return GlassCardV2(
      radius: AppTokensV2.radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < schedules.length; i++) ...[
            if (i != 0) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: AppTokensV2.border),
              const SizedBox(height: 12),
            ],
            _buildItem(s.bt_detail_date, schedules[i].dateFrom ?? ""),
            const SizedBox(height: 10),
            _buildItem(
              s.bt_detail_type,
              _mapScheduleDateType(schedules[i].type ?? ""),
            ),
          ],
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

  Widget _bottomBar(WorkTripState state) {
    final s = S.of(context);
    final entity = state.detailWorkTrip;
    if (entity == null) return const SizedBox.shrink();

    bool isDraft = false;
    if (entity.stage?.id == 25 ||
        entity.stage?.id == 1 ||
        entity.stage?.id == 6 ||
        entity.stage?.id == 13 ||
        entity.stage?.id == 17 ||
        entity.stage?.id == 21) {
      isDraft = true;
    }

    if (isDraft) {
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
              child: _secondaryButton(
                label: s.bt_detail_sendApproval,
                onTap: _onSubmitWorkTrip,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dangerButton(
                label: s.bt_detail_delete,
                onTap: showDeleteConfirmDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButtonV2(
                label: s.bt_detail_update,
                onTap: () => doUpdate(context),
              ),
            ),
          ],
        ),
      );
    }

    if (_isDirector && _isManagerApproveStage) {
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
                label: s.deny,
                onTap: () => showRejectDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButtonV2(
                label: s.authorize,
                onTap: _showApproveDialog,
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
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
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
