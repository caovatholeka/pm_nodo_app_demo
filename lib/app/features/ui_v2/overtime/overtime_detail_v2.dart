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
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/on_leave/widget/reject_reason_dialog.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/create_overtime_cubit.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/overtime_detail_cubit.dart';
import 'package:pm_app/app/features/ui_v2/overtime/create_overtime_v2.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:pm_app/app/core/theme_v2/widgets/bottom_sheet_bar_theme_v2.dart';

/// Màn Chi tiết tăng ca — phiên bản giao diện tối (v2).
///
/// Hành vi/nghiệp vụ giữ NGUYÊN bản cũ [OvertimeDetail]: cùng
/// [OvertimeDetailCubit] (qua GetIt), cùng luật hiển thị nút hành động
/// (Nháp -> gửi duyệt/cập nhật; Trưởng phòng duyệt + Giám đốc -> từ chối/
/// duyệt), cùng dialog xác nhận, cùng thứ tự xử lý listener (kể cả các
/// nhánh trùng lặp/"chết" của bản cũ) để không đổi hành vi thực tế.
class OvertimeDetailV2 extends StatefulWidget {
  final int? id;
  const OvertimeDetailV2({super.key, this.id});

  @override
  State<OvertimeDetailV2> createState() => _OvertimeDetailV2State();
}

class _OvertimeDetailV2State extends State<OvertimeDetailV2> {
  final _cubit = GetIt.I<OvertimeDetailCubit>();

  bool get isDirector {
    final jobTitle =
        GlobalData.instance.userProfile?.jobTitle?.toLowerCase() ?? '';
    return jobTitle.contains('giám đốc');
  }

  bool _isManagerApprove(OvertimeDetailState state) {
    return state.detail?.stage?.name == 'Trưởng phòng duyệt';
  }

  bool _isDraft(OvertimeDetailState state) {
    return state.detail?.stage?.name == 'Nháp';
  }

  @override
  void initState() {
    super.initState();
    _cubit.resetApproveStatus();
    _cubit.resetSubmitState();
    _cubit.getDetailOT(widget.id ?? 0);
  }

  void _goNotification() {
    HapticFeedback.selectionClick();
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

  Color _getStatusColorByName(String? name) {
    switch (name) {
      case 'Nháp':
        return AppTokensV2.fgMuted;
      case 'Trưởng phòng duyệt':
        return AppTokensV2.accent;
      case 'Hoàn thành':
        return AppTokensV2.success;
      case 'Hủy':
        return AppTokensV2.danger;
      default:
        return AppTokensV2.fgMuted;
    }
  }

  String _getLocalizedStatusName(String? name) {
    final s = S.of(context);
    switch (name) {
      case 'Nháp':
        return s.bt_status1;
      case 'Trưởng phòng duyệt':
        return s.bt_status2;
      case 'Hoàn thành':
        return s.bt_status3;
      case 'Hủy':
        return s.cancel;
      default:
        return name ?? '';
    }
  }

  String _mapOTFormType(String? type) {
    final s = S.of(context);
    switch (type) {
      case 'pay':
        return s.ot_paid;
      case 'leave':
        return s.ot_timeOff;
      default:
        return '';
    }
  }

  void _onDirectorReject() {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => RejectReasonDialog(
            title: s.confirm,
            description: s.ot_sub_confirm_submit,
            hintText: s.reason,
            onConfirm: (reason) {
              final id = _cubit.state.detail?.id;
              if (id == null) return;
              _cubit.cancelOT(id, reason);
            },
          ),
    );
  }

  void _onDirectorApprove() {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: s.confirm,
            content: s.ot_sub_confirm_submit,
            confirmText: s.authorize,
            cancelText: s.cancel,
            success: true,
            onConfirm: () {
              Navigator.pop(context);
              _cubit.approveOT();
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  // Bỏ nền sáng mặc định của khung nút ở đáy (Scaffold.bottomSheet) → chỉ còn nút.
  @override
  Widget build(BuildContext context) =>
      BottomSheetBarThemeV2(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
    final s = S.of(context);
    return BlocListener<OvertimeDetailCubit, OvertimeDetailState>(
      bloc: _cubit,
      listener: (context, state) async {
        final isLoading =
            state.loadStatus == LoadStatus.LOADING ||
            state.isSubmitting ||
            state.approveStatus == LoadStatus.LOADING ||
            state.cancelStatus == LoadStatus.LOADING;

        if (isLoading) {
          LoadingOverlay.show(context);
        } else {
          LoadingOverlay.hide(context);
        }

        if (state.cancelStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
          return;
        }

        if (state.cancelStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          await Flushbar(
            message: "Từ chối đơn OT thành công!",
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetCancelStatus();
          Navigator.pop(context);
          return;
        }

        if (state.cancelStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);
          await Flushbar(
            message: "Từ chối đơn OT thất bại",
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.error, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetCancelStatus();
          return;
        }

        if (state.submitSuccess) {
          await Flushbar(
            message: s.send_approval_success,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetSubmitState();

          return;
        }

        if (state.approveStatus == LoadStatus.SUCCESS) {
          await Flushbar(
            message: s.send_approval_success,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetSubmitState();
          Navigator.pop(context);
          return;
        }

        if (state.approveStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
          return;
        }

        if (state.approveStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          await Flushbar(
            message: s.ot_approve_success,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ).show(context);

          _cubit.resetApproveStatus();
          _cubit.getDetailOT(widget.id!);
        }

        if (state.approveStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);

          await Flushbar(
            message: s.ot_approve_failed,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.error, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetApproveStatus();
          return;
        }

        if (state.error != null) {
          await Flushbar(
            message: state.error!,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ).show(context);

          _cubit.resetSubmitState();
        }
      },
      child: BlocBuilder<OvertimeDetailCubit, OvertimeDetailState>(
        bloc: _cubit,
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
              title: Text(s.ot_detail_title, style: AppTokensV2.title),
              centerTitle: false,
              actions: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _goNotification,
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: AppTokensV2.surfaceStrong,
                      border: Border.all(color: AppTokensV2.border),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: AppTokensV2.fgSoft,
                    ),
                  ),
                ),
              ],
            ),
            body: AmbientBackgroundV2(child: SafeArea(child: _buildBody(state))),
            bottomSheet: _bottomBar(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(OvertimeDetailState state) {
    final s = S.of(context);
    if (state.loadStatus == LoadStatus.LOADING) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTokensV2.accent,
          strokeWidth: 2.2,
        ),
      );
    }

    if (state.loadStatus == LoadStatus.FAILURE) {
      return Center(
        child: Text(
          state.error ?? s.to_do_failed,
          style: AppTokensV2.captionStrong,
        ),
      );
    }

    final e = state.detail;
    if (e == null) return const SizedBox();

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
          StaggerRevealV2(index: 0, child: _headerCard(state)),
          const SizedBox(height: 16),
          StaggerRevealV2(index: 1, child: _infoCard(state)),
          if ((e.overtimeDetail ?? []).isNotEmpty) ...[
            const SizedBox(height: 16),
            StaggerRevealV2(index: 2, child: _dayCards(state)),
          ],
        ],
      ),
    );
  }

  Widget _headerCard(OvertimeDetailState state) {
    final e = state.detail;
    final stageName = e?.stage?.name;
    final color = _getStatusColorByName(stageName);

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
                  e?.employeeName ?? "",
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
                      _getLocalizedStatusName(stageName),
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
                  "${e?.fromDate ?? ""} - ${e?.toDate ?? ""}",
                  style: AppTokensV2.body,
                ),
              ),
            ],
          ),
          if ((e?.overtimeDetail ?? []).isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: AppTokensV2.fgMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e!.overtimeDetail!
                        .map((d) => d.shift?.name)
                        .whereType<String>()
                        .toSet()
                        .join(', '),
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

  Widget _infoCard(OvertimeDetailState state) {
    final e = state.detail;
    final s = S.of(context);

    return GlassCardV2(
      radius: AppTokensV2.radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItem(s.ot_detail_department, e?.departmentName ?? ""),
          const SizedBox(height: 14),
          _buildItem(s.ot_detail_createDate, e?.dateCreate ?? ""),
          const SizedBox(height: 14),
          _buildItem(
            s.ot_detail_receive,
            e?.overtimeDetail
                    ?.map((d) => _mapOTFormType(d.formType))
                    .where((v) => v.isNotEmpty)
                    .toSet()
                    .join(', ') ??
                "",
          ),
          const SizedBox(height: 14),
          _buildItem(s.ot_detail_notes, e?.note ?? ""),
          const SizedBox(height: 14),
          _buildItem(s.ot_detail_creator, e?.employeeName ?? ""),
        ],
      ),
    );
  }

  Widget _dayCards(OvertimeDetailState state) {
    final s = S.of(context);
    final e = state.detail;
    final details = e?.overtimeDetail ?? [];

    return GlassCardV2(
      radius: AppTokensV2.radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < details.length; i++) ...[
            if (i != 0) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: AppTokensV2.border),
              const SizedBox(height: 12),
            ],
            _buildItem(s.ot_detail_date, details[i].date ?? ""),
            const SizedBox(height: 10),
            _buildItem(
              s.ot_detail_totalHour,
              details[i].overtime != null
                  ? details[i].overtime!.toStringAsFixed(2)
                  : "",
            ),
            const SizedBox(height: 10),
            _buildItem(
              s.ot_detail_receive,
              _mapOTFormType(details[i].formType),
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

  Widget _bottomBar(OvertimeDetailState state) {
    final s = S.of(context);

    if (_isDraft(state)) {
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
                label: s.ot_detail_send,
                loading: state.isSubmitting,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (_) => CustomDialog(
                          title: s.confirm_authorize,
                          content: s.confirm_sub_authorize,
                          confirmText: s.authorize,
                          cancelText: s.cancel,
                          success: true,
                          onConfirm: () {
                            Navigator.pop(context);
                            _cubit.submitApproval();
                          },
                          onCancel: () => Navigator.pop(context),
                        ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButtonV2(
                label: s.ot_detail_update,
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider(
                            create: (_) => CreateOvertimeCubit(),
                            child: CreateOTPageV2(initialData: state.detail),
                          ),
                    ),
                  );
                  if (res == true) {
                    _cubit.getDetailOT(widget.id!);
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

    if (_isManagerApprove(state) && isDirector) {
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

  Widget _secondaryButton({
    required String label,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading
          ? null
          : () {
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
        child:
            loading
                ? SizedBox(
                  height: 16,
                  width: 16,
                  child: Center(
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTokensV2.accent,
                      ),
                    ),
                  ),
                )
                : Text(
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
