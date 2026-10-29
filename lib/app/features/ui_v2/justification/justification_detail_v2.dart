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
import 'package:pm_app/app/data/models/entities/exception_line_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/justification_approve_param.dart';
import 'package:pm_app/app/data/models/param/justification_cancel_param.dart';
import 'package:pm_app/app/features/ui/justification/bloc/justification_detail_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/on_leave/widget/reject_reason_dialog.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

import 'create_justification_page_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/bottom_sheet_bar_theme_v2.dart';
import 'package:pm_app/app/core/theme_v2/label_v2.dart';

/// Trạng thái hiển thị (chữ + màu) dùng chung cho badge trạng thái đơn.
class _StatusUIV2 {
  final String text;
  final Color color;

  const _StatusUIV2({required this.text, required this.color});
}

/// Màn Chi tiết đơn muộn/sớm — phiên bản giao diện tối (v2).
///
/// Hành vi/nghiệp vụ giữ NGUYÊN bản cũ [JustificationDetailPage]: cùng
/// [JustificationDetailCubit] (qua GetIt), cùng luật hiển thị nút hành động
/// (Nháp → gửi duyệt/sửa; Trưởng phòng duyệt + Giám đốc → duyệt/từ chối),
/// cùng dialog xác nhận, cùng cách xử lý kết quả (flushbar/pop/refresh).
/// Chỉ đổi trình bày sang hệ thiết kế v2.
class JustificationDetailV2 extends StatefulWidget {
  final int? id;
  const JustificationDetailV2({super.key, this.id});

  @override
  State<JustificationDetailV2> createState() => _JustificationDetailV2State();
}

class _JustificationDetailV2State extends State<JustificationDetailV2> {
  final _cubit = GetIt.I<JustificationDetailCubit>();

  bool get isDirector {
    final jobTitle =
        GlobalData.instance.userProfile?.jobTitle?.toLowerCase() ?? '';
    return jobTitle.contains('giám đốc');
  }

  @override
  void initState() {
    super.initState();
    // Cubit dùng chung cả app: xoá trạng thái của lần mở trước.
    _cubit.resetSubmitState();
    _cubit.resetApproveCancelStatus();
    _cubit.getDetail(widget.id ?? 0);
  }

  bool _isDraft(String? name) => name == 'Nháp';

  void _showSuccess(String message) {
    Flushbar(
      message: message,
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  bool _isManagerApprove(String? name) => name == 'Trưởng phòng duyệt';

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

  void _showDialog({
    required String title,
    required String message,
    required bool success,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: title,
            content: message,
            confirmText: S.of(context).confirm,
            cancelText: S.of(context).cancel,
            success: success,
            onConfirm: () {
              Navigator.pop(context);
              onConfirm();
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  void _onDirectorApprove() {
    final s = S.of(context);
    _showDialog(
      title: s.justification_detail_submit_title,
      message: s.justification_detail_submit_sub,
      success: true,
      onConfirm: () async {
        final id = widget.id;
        if (id == null) return;

        await _cubit.approveJustification(
          JustificationApproveParam(exceptionIds: [id]),
        );
      },
    );
  }

  void _onDirectorReject() {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => RejectReasonDialog(
            title: s.justification_detail_deny_title,
            description: s.justification_detail_deny_sub,
            hintText: s.justification_detail_deny_reason_type,
            onConfirm: (reason) async {
              final id = widget.id;
              if (id == null) return;

              await _cubit.cancelJustification(
                id,
                JustificationCancelParam(note: reason),
              );
            },
          ),
    );
  }

  _StatusUIV2 _getStatusUI(BuildContext context, String? name) {
    final s = S.of(context);

    switch (name) {
      case 'Nháp':
        return _StatusUIV2(text: s.bt_status1, color: AppTokensV2.fgMuted);
      case 'Trưởng phòng duyệt':
        return _StatusUIV2(text: s.bt_status2, color: AppTokensV2.accent);
      case 'Hoàn thành':
        return _StatusUIV2(text: s.bt_status3, color: AppTokensV2.success);
      case 'Hủy':
        return _StatusUIV2(text: s.cancel, color: AppTokensV2.danger);
      default:
        return _StatusUIV2(text: name ?? '', color: AppTokensV2.fgMuted);
    }
  }

  String _getReasonTypeText(String? type) {
    if (type == null || type.isEmpty) return '';
    final s = S.of(context);
    switch (type.toLowerCase()) {
      case 'personal':
        return s.justification_reason_type1;
      case 'work':
        return s.justification_reason_type2;
      default:
        return type;
    }
  }

  String _mapFormType(String? type) {
    final s = S.of(context);
    switch (type) {
      case 'late':
        return s.justification_status1;
      case 'early':
        return s.justification_status2;
      case 'absence':
        return s.justification_status3;
      default:
        return type ?? '';
    }
  }

  // Bỏ nền sáng mặc định của khung nút ở đáy (Scaffold.bottomSheet) → chỉ còn nút.
  @override
  Widget build(BuildContext context) =>
      BottomSheetBarThemeV2(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
    final s = S.of(context);

    return BlocListener<JustificationDetailCubit, JustificationDetailState>(
      bloc: _cubit,
      listenWhen:
          (prev, cur) =>
              prev.isSubmitting != cur.isSubmitting ||
              prev.submitSuccess != cur.submitSuccess ||
              prev.approveStatus != cur.approveStatus ||
              prev.cancelStatus != cur.cancelStatus ||
              prev.error != cur.error,
      listener: (context, state) async {
        // Đang gửi duyệt / duyệt / từ chối → hộp loading chặn bấm thêm lần nữa.
        // Trước đây không có loading, bấm liên tục được.
        final isLoading =
            state.isSubmitting ||
            state.approveStatus == LoadStatus.LOADING ||
            state.cancelStatus == LoadStatus.LOADING;
        if (isLoading) {
          LoadingOverlay.show(context);
          return;
        }
        LoadingOverlay.hide(context);

        // Thành công: tải lại đơn NGAY (nút Gửi duyệt/Duyệt biến mất) rồi mới báo, thay vì
        // chờ thông báo 2 giây xong mới tải lại (trong 2 giây đó vẫn bấm lại được).
        if (state.submitSuccess) {
          _cubit.resetSubmitState();
          _cubit.getDetail(widget.id!);
          _showSuccess(s.justification_sendApproval);
          return;
        }

        if (state.approveStatus == LoadStatus.SUCCESS) {
          _cubit.resetApproveCancelStatus();
          _cubit.getDetail(widget.id!);
          _showSuccess(s.justification_submit_success);
          return;
        }

        if (state.cancelStatus == LoadStatus.SUCCESS) {
          _cubit.resetApproveCancelStatus();
          _cubit.getDetail(widget.id!);
          _showSuccess(s.justification_detail_deny_success);
          return;
        }

        if (state.error != null) {
          await Flushbar(
            message: state.error!,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetSubmitState();
          _cubit.resetApproveCancelStatus();
        }
      },
      child: BlocBuilder<JustificationDetailCubit, JustificationDetailState>(
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
              title: Text(
                s.justification_detail_title,
                style: AppTokensV2.title,
              ),
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

  Widget _buildBody(JustificationDetailState state) {
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
          state.error ?? S.of(context).justification_errorHappern,
          style: AppTokensV2.captionStrong,
        ),
      );
    }

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
        ],
      ),
    );
  }

  Widget _headerCard(JustificationDetailState state) {
    final e = state.detail;
    final statusUI = _getStatusUI(context, e?.stage?.name);

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
                  e?.employeeName ?? '',
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
                  color: statusUI.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusUI.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusUI.text,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusUI.color,
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
                child: Text(e?.date ?? '', style: AppTokensV2.body),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(JustificationDetailState state) {
    final s = S.of(context);
    final e = state.detail;
    if (e == null) return const SizedBox();

    return GlassCardV2(
      radius: AppTokensV2.radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(s.justification_detail_department, e.departmentName ?? ''),
          const SizedBox(height: 14),
          _row(
            s.justification_detail_reason,
            _getReasonTypeText(e.reasonType),
          ),
          if (e.exceptionLines != null && e.exceptionLines!.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...e.exceptionLines!.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _exceptionBox(line),
              ),
            ),
          ],
          const SizedBox(height: 14),
          _row(s.justification_detail_notes, e.note ?? ''),
          const SizedBox(height: 14),
          _row(s.justification_create, e.employeeName ?? ''),
        ],
      ),
    );
  }

  Widget _exceptionBox(ExceptionLineEntity e) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTokensV2.surface,
        borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
        border: Border.all(color: AppTokensV2.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          _row(s.justification_detail_form, _mapFormType(e.formType)),
          const SizedBox(height: 10),
          _row(
            s.justification_detail_hours,
            e.timeNumber != null ? e.timeNumber!.toStringAsFixed(2) : '',
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 4,
          child: Text(
            labelV2(title),
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

  Widget? _bottomBar(JustificationDetailState state) {
    final s = S.of(context);

    if (_isDraft(state.detail?.stage?.name)) {
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
                label: s.justification_detail_updatebtn,
                onTap: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CreateJustificationPageV2(
                            initialData: state.detail,
                          ),
                    ),
                  );
                  if (res == true) {
                    _cubit.getDetail(widget.id!);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButtonV2(
                label: s.justification_detail_sendbtn,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (_) => CustomDialog(
                          title: s.justification_sendApproval1,
                          content: s.justification_sendApproval2,
                          confirmText: s.justtification_sendApproval,
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
          ],
        ),
      );
    }

    if (_isManagerApprove(state.detail?.stage?.name) && isDirector) {
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

    return null;
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
        child: Text(label, textAlign: TextAlign.center, style: AppTokensV2.body),
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
