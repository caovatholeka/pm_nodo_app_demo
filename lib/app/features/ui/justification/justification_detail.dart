import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/exception_line_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/justification/create_justification_page.dart';
import 'package:pm_app/app/features/ui/justification/widgets/dashed_border_box.dart';
import 'package:pm_app/app/features/widgets/custom_dash_view.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

import 'bloc/justification_detail_cubit.dart';

class JustificationDetailPage extends StatefulWidget {
  final int? id;
  const JustificationDetailPage({super.key, this.id});

  @override
  State<JustificationDetailPage> createState() =>
      _JustificationDetailPageState();
}

class _JustificationDetailPageState extends State<JustificationDetailPage> {
  final _cubit = GetIt.I<JustificationDetailCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getDetail(widget.id ?? 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isDraft(JustificationDetailState state) {
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
    return BlocListener<JustificationDetailCubit, JustificationDetailState>(
      bloc: _cubit,
      listener: (context, state) async {
        if (state.submitSuccess) {
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
                appBar: MyAppBar(
                  titleAppbar: "Chi tiết yêu cầu MS",
                  haveBackButton: true,
                  haveActionButton: true,
                  iconPathAsset: AppAssets.icNotificationBell,
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
        ],
      ),
    );
  }

  Widget _contentCard(JustificationDetailState state) {
    final e = state.detail;
    if (e == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row("Nhân viên", e.employeeName ?? ""),
          const CustomDashView(),
          _row("Phòng ban", e.departmentName ?? ""),
          const CustomDashView(),
          _row("Loại lý do", e.reasonType ?? ""),
          const CustomDashView(),
          _row("Ngày", e.date ?? ""),
          const SizedBox(height: 12),

          if (e.exceptionLines != null)
            ...e.exceptionLines!.map(_exceptionBox).toList(),

          const SizedBox(height: 12),
          _row("Ghi chú", e.note ?? ""),
          const CustomDashView(),
          _statusRow(e.stage?.name ?? ""),
          const CustomDashView(),
          _row("Người tạo", e.employeeName ?? ""),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
            flex: 4,
            child: Text(
              "Trạng thái",
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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

  Widget _exceptionBox(ExceptionLineEntity e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashedBorderBox(
        radius: 12,
        color: const Color(0xFF3B82F6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _row("Hình thức", _mapFormType(e.formType)),
              const CustomDashView(),
              _row("Số giờ", _formatHour(e.timeNumber)),
            ],
          ),
        ),
      ),
    );
  }

  String _mapFormType(String? type) {
    switch (type) {
      case "late":
        return "Đi muộn";
      case "early":
        return "Về sớm";
      case "absence":
        return "Vắng mặt";
      default:
        return type ?? "";
    }
  }

  String _formatHour(double? hour) {
    if (hour == null) return "";
    final h = hour.floor();
    final m = ((hour - h) * 60).round();
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  Widget _actionButtons(JustificationDetailState state) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            mainText: "Xóa",
            type: PrimaryButtonType.secondary,
            callback: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            mainText: "Gửi duyệt",
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
            mainText: "Cập nhật",
            type: PrimaryButtonType.primary,
            callback: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => CreateJustificationPage(initialData: state.detail),
                ),
              );

              if(res == true) {
                _cubit.getDetail(widget.id!);
              }
            },
          ),
        ),
      ],
    );
  }
}
