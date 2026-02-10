import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/justification/widgets/dashed_border_box.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/overtime/create_overtime.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/create_overtime_cubit.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/overtime_detail_cubit.dart';
import 'package:pm_app/app/features/widgets/custom_dash_view.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/generated/l10n.dart';

class OvertimeDetail extends StatefulWidget {
  final int? id;
  const OvertimeDetail({super.key, this.id});

  @override
  State<OvertimeDetail> createState() => _OvertimeDetailPageState();
}

class _OvertimeDetailPageState extends State<OvertimeDetail> {
  final _cubit = GetIt.I<OvertimeDetailCubit>();

  bool get isDirector {
    final jobTitle =
        GlobalData.instance.userProfile?.jobTitle?.toLowerCase() ?? '';
    return jobTitle.contains('giám đốc');
  }

  bool _isManagerApprove(OvertimeDetailState state) {
    return state.detail?.stage?.name == 'Trưởng phòng duyệt';
  }

  void _onDirectorReject() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: "Xác nhận",
            content: "Bạn có chắc chắn muốn huỷ yêu cầu tăng ca này?",
            confirmText: "Huỷ",
            cancelText: "Đóng",
            success: false,
            onConfirm: () => Navigator.pop(context),
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  void _onDirectorApprove() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: "Xác nhận",
            content: "Bạn có chắc chắn muốn duyệt yêu cầu tăng ca này?",
            confirmText: "Duyệt",
            cancelText: "Huỷ",
            success: true,
            onConfirm: () {
              Navigator.pop(context);
              _cubit.approveOT();
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cubit.resetApproveStatus(); 
    _cubit.resetSubmitState(); 
    _cubit.getDetailOT(widget.id ?? 0);
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

  bool _isDraft(OvertimeDetailState state) {
    return state.detail?.stage?.name == 'Nháp';
  }

  Color _getStatusColorByName(String? name) {
    switch (name) {
      case 'Nháp':
        return Colors.orange;
      case 'Chờ xác nhận':
      case 'Trưởng phòng duyệt':
        return Colors.blue;
      case 'Hoàn thành':
      case 'Hợp lệ':
        return Colors.green;
      case 'Hủy':
      case 'Không hợp lệ':
        return Colors.red;
      case 'Đã khóa':
      case 'Khóa kì công':
        return Colors.grey;
      case 'Tính toán công':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocListener<OvertimeDetailCubit, OvertimeDetailState>(
      bloc: _cubit,
      listener: (context, state) async {
        if (state.approveStatus == LoadStatus.SUCCESS) {
          await Flushbar(
            message: 'Gửi duyệt thành công',
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
            message: 'Duyệt tăng ca thành công',
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
            message: 'Duyệt tăng ca thất bại',
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
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: BlocBuilder<AppCubit, AppState>(
                    buildWhen:
                        (prev, cur) => prev.totalUnread != cur.totalUnread,
                    builder: (context, appState) {
                      return MyAppBar(
                        titleAppbar: s.ot_detail_title,
                        haveBackButton: true,
                        haveActionButton: true,
                        iconPathAsset: AppAssets.icNotificationBell,
                        badgeCount: appState.totalUnread,
                        actionCallBack: _goNotification,
                      );
                    },
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

  Widget _buildBody(OvertimeDetailState state) {
    if (state.loadStatus == LoadStatus.LOADING) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.loadStatus == LoadStatus.FAILURE) {
      return Center(child: Text(state.error ?? "Đã xảy ra lỗi"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        children: [
          _contentCard(state),
          if (_isDraft(state)) ...[
            const SizedBox(height: 20),
            _actionButtons(state),
            const SizedBox(height: 24),
          ],
          if (_isManagerApprove(state) && isDirector) ...[
            const SizedBox(height: 20),
            _directorActionButtons(),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _directorActionButtons() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            mainText: "Từ chối",
            type: PrimaryButtonType.secondary,
            callback: _onDirectorReject,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            mainText: "Duyệt",
            type: PrimaryButtonType.primary,
            callback: _onDirectorApprove,
          ),
        ),
      ],
    );
  }

  Widget _contentCard(OvertimeDetailState state) {
    final e = state.detail;
    if (e == null) return const SizedBox();
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row(s.ot_detail_employee, e.employeeName ?? ""),
          const CustomDashView(),
          _row(
            s.ot_detail_workshift,
            e.overtimeDetail
                    ?.map((d) => d.shift?.name)
                    .whereType<String>()
                    .toSet()
                    .join(', ') ??
                "",
          ),
          const CustomDashView(),
          _row(s.ot_detail_department, e.departmentName ?? ""),
          const CustomDashView(),
          _row(s.ot_detail_createDate, e.dateCreate ?? ""),
          const CustomDashView(),
          _row(s.ot_detail_fromDate, e.fromDate ?? ""),
          const CustomDashView(),
          _row(s.ot_detail_toDate, e.toDate ?? ""),
          const SizedBox(height: 16),
          if (e.overtimeDetail != null)
            ...e.overtimeDetail!.map(_overtimeDetailBox),
          const SizedBox(height: 16),
          _row(
            s.ot_detail_receive,
            e.overtimeDetail
                    ?.map((d) => _mapOTFormType(d.formType))
                    .where((s) => s.isNotEmpty)
                    .toSet()
                    .join(', ') ??
                "",
          ),
          const CustomDashView(),
          _row(s.ot_detail_notes, e.note ?? ""),
          const CustomDashView(),
          _statusRow(e.stage?.name ?? ""),
          const CustomDashView(),
          _row(s.ot_detail_creator, e.employeeName ?? ""),
        ],
      ),
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

  Widget _statusRow(String name) {
    final color = _getStatusColorByName(name);
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              s.ot_detail_status,
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
                  color: color.withOpacity(0.15),
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
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
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

  Widget _overtimeDetailBox(dynamic d) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashedBorderBox(
        radius: 12,
        color: const Color(0xFF60A5FA),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _row(s.ot_detail_date, d.date ?? ""),
              const CustomDashView(),
              _row(
                s.ot_detail_totalHour,
                d.overtime != null ? d.overtime!.toStringAsFixed(2) : "",
              ),
              const CustomDashView(),
              _row(s.ot_detail_receive, _mapOTFormType(d.formType)),
            ],
          ),
        ),
      ),
    );
  }

  String _mapOTFormType(String? type) {
    switch (type) {
      case 'pay':
        return 'Trả tiền';
      case 'leave':
        return 'Nghỉ Phép';
      default:
        return '';
    }
  }

  Widget _actionButtons(OvertimeDetailState state) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            mainText: s.ot_detail_send,
            type: PrimaryButtonType.primary,
            isLoading: state.isSubmitting,
            callback: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (_) => CustomDialog(
                      title: "Xác nhận gửi duyệt",
                      content:
                          "Bạn có chắc chắn muốn gửi duyệt yêu cầu này không?",
                      confirmText: "Gửi duyệt",
                      cancelText: "Hủy",
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
            mainText: s.ot_detail_update,
            type: PrimaryButtonType.primary,
            callback: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BlocProvider(
                        create: (_) => CreateOvertimeCubit(),
                        child: CreateOTPage(initialData: state.detail),
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
    );
  }
}
