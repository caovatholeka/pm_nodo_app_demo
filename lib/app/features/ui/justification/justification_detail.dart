import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/data/models/entities/exception_line_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/justification_approve_param.dart';
import 'package:pm_app/app/data/models/param/justification_cancel_param.dart';
import 'package:pm_app/app/features/ui/justification/create_justification_page.dart';
import 'package:pm_app/app/features/ui/justification/widgets/dashed_border_box.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/on_leave/widget/reject_reason_dialog.dart';
import 'package:pm_app/app/features/widgets/custom_dash_view.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/generated/l10n.dart';

import 'bloc/justification_detail_cubit.dart';

class StatusUI {
  final String text;
  final Color color;
  final Color bgColor;

  const StatusUI({
    required this.text,
    required this.color,
    required this.bgColor,
  });
}

class JustificationDetailPage extends StatefulWidget {
  final int? id;
  const JustificationDetailPage({super.key, this.id});

  @override
  State<JustificationDetailPage> createState() =>
      _JustificationDetailPageState();
}

class _JustificationDetailPageState extends State<JustificationDetailPage> {
  final _cubit = GetIt.I<JustificationDetailCubit>();

  bool get isDirector {
    final jobTitle =
        GlobalData.instance.userProfile?.jobTitle?.toLowerCase() ?? '';
    return jobTitle.contains('giám đốc');
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

  bool _isManagerApprove(String? name) {
    return name == 'Trưởng phòng duyệt';
  }

  @override
  void initState() {
    super.initState();
    _cubit.getDetail(widget.id ?? 0);
  }

  bool _isDraft(String? name) {
    return name == 'Nháp';
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

  StatusUI _getStatusUI(BuildContext context, String? name) {
    final s = S.of(context);

    switch (name) {
      case 'Nháp':
        return StatusUI(
          text: s.bt_status1,
          color: AppColors.colorDraft,
          bgColor: AppColors.colorDraft.withValues(alpha: 0.15),
        );
      case 'Trưởng phòng duyệt':
        return StatusUI(
          text: s.bt_status2,
          color: AppColors.colorApproved,
          bgColor: AppColors.colorApproved.withValues(alpha: 0.15),
        );
      case 'Hoàn thành':
        return StatusUI(
          text: s.bt_status3,
          color: AppColors.colorFinished,
          bgColor: AppColors.colorFinished.withValues(alpha: 0.15),
        );
      case 'Hủy':
        return StatusUI(
          text: s.cancel,
          color: AppColors.colorCancel,
          bgColor: AppColors.colorCancel.withValues(alpha: 0.15),
        );
      default:
        return StatusUI(
          text: name ?? '',
          color: Colors.grey,
          bgColor: Colors.grey.withValues(alpha: 0.15),
        );
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<JustificationDetailCubit, JustificationDetailState>(
      bloc: _cubit,
      listenWhen:
          (prev, cur) =>
              prev.submitSuccess != cur.submitSuccess ||
              prev.approveStatus != cur.approveStatus ||
              prev.cancelStatus != cur.cancelStatus ||
              prev.error != cur.error,
      listener: (context, state) async {

        if (state.submitSuccess) {
          await Flushbar(
            message: s.justification_sendApproval,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetApproveCancelStatus();
          _cubit.getDetail(widget.id!);
        }

        if (state.approveStatus == LoadStatus.SUCCESS) {
          await Flushbar(
            message: s.justification_submit_success,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetApproveCancelStatus();
          _cubit.getDetail(widget.id!);
        }

        if (state.cancelStatus == LoadStatus.SUCCESS) {
          await Flushbar(
            message: s.justification_detail_deny_success,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.cancel, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetApproveCancelStatus();
          _cubit.getDetail(widget.id!);
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
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: MyAppBar(
                        titleAppbar: s.justification_detail_title,
                        haveBackButton: true,
                        haveActionButton: true,
                        iconPathAsset: AppAssets.icNotificationBell,
                        actionCallBack: _goNotification,
                  ),
                ),
                body: SafeArea(child: _buildBody(state)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(JustificationDetailState state) {
    if (state.loadStatus == LoadStatus.LOADING) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.colorApproved),
      );
    }

    if (state.loadStatus == LoadStatus.FAILURE) {
      return Center(
        child: Text(state.error ?? S.of(context).justification_errorHappern),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        children: [
          _contentCard(state),
          if (_isDraft(state.detail?.stage?.name)) ...[
            const SizedBox(height: 20),
            _actionButtons(state),
            const SizedBox(height: 24),
          ],

          if (_isManagerApprove(state.detail?.stage?.name) && isDirector) ...[
            const SizedBox(height: 20),
            _directorActionButtons(state),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _contentCard(JustificationDetailState state) {
    final s = S.of(context);
    final e = state.detail;
    if (e == null) return const SizedBox();

    final statusUI = _getStatusUI(context, e.stage?.name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row(s.justification_detail_employee, e.employeeName ?? ''),
          const CustomDashView(),
          _row(s.justification_detail_department, e.departmentName ?? ''),
          const CustomDashView(),
          _row(s.justification_detail_reason, _getReasonTypeText(e.reasonType)),
          const CustomDashView(),
          _row(s.justification_detail_date, e.date ?? ''),
          const SizedBox(height: 12),
          if (e.exceptionLines != null) ...e.exceptionLines!.map(_exceptionBox),
          const SizedBox(height: 12),
          _row(s.justification_detail_notes, e.note ?? ''),
          const CustomDashView(),
          _statusRow(statusUI),
          const CustomDashView(),
          _row(s.justification_create, e.employeeName ?? ''),
        ],
      ),
    );
  }

  Widget _directorActionButtons(JustificationDetailState state) {
    final s = S.of(context);

    return Row(
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
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(StatusUI statusUI) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              s.justification_detail_status,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusUI.bgColor,
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
                        color: statusUI.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exceptionBox(ExceptionLineEntity e) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashedBorderBox(
        radius: 12,
        color: const Color(0xFF3B82F6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _row(s.justification_detail_form, _mapFormType(e.formType)),
              const CustomDashView(),
              _row(
                s.justification_detail_hours,
                e.timeNumber != null ? e.timeNumber!.toStringAsFixed(2) : '',
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _actionButtons(JustificationDetailState state) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            mainText: s.justification_detail_sendbtn,
            type: PrimaryButtonType.primary,
            isLoading: state.isSubmitting,
            callback: () {
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
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            mainText: s.justification_detail_updatebtn,
            type: PrimaryButtonType.primary,
            callback: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => CreateJustificationPage(initialData: state.detail),
                ),
              );
              if (res == true) {
                _cubit.getDetail(widget.id!);
              }
            },
          ),
        ),
      ],
    );
  }
}
