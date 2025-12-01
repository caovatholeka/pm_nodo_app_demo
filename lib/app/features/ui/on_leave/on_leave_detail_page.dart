import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/detail_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/create_new_leave_page.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../data/models/entities/on_leave_entity.dart';
import '../../widgets/custom_dash_view.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/primary_button.dart';

class OnLeaveDetailPage extends StatefulWidget {
  int? detailId;
  OnLeaveEntity? detailEntity;

  OnLeaveDetailPage({super.key, this.detailId, this.detailEntity});

  @override
  State<OnLeaveDetailPage> createState() => _OnLeaveDetailPageState();
}

class _OnLeaveDetailPageState extends State<OnLeaveDetailPage> {
  final _cubit = GetIt.I.get<DetailOnLeaveCubit>();

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
    switch (status) {
      case 1:
      case 6:
      case 13:
      case 17:
        return "Nháp";
      case 14:
        return "Trưởng phòng duyệt";
      case 11:
      case 15:
      case 9:
        return "Hoàn thành";
      case 20:
      case 16:
      case 12:
        return "Huỷ";
      default:
        return "";
    }
  }

  Future<void> doUpdate(BuildContext context) async {
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
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailOnLeaveCubit, DetailOnLeaveState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state.loadStatus == LoadStatus.LOADING ||
            state.deleteStatus == LoadStatus.LOADING ||
            state.confirmStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        } else if (state.deleteStatus == LoadStatus.SUCCESS) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          Navigator.pop(context, true);
          AppSnackBar.showInfo(title: "Thành công",message: "Xoá bản ghi thành công!");

          // _showDialog(
          //   title: "Thành công",
          //   message: "Xoá bản ghi thành công!",
          //   success: true,
          //   onConfirm: () => Navigator.pop(context, true),
          // );
        } else if (state.confirmStatus == LoadStatus.SUCCESS) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          Navigator.pop(context, true);
          AppSnackBar.showInfo(title: "Thành công",message: "Đã gửi duyệt thành công!");
          // _showDialog(
          //   title: "Thành công",
          //   message: "Đã gửi duyệt thành công!",
          //   success: true,
          //   onConfirm: () => Navigator.pop(context, true),
          // );
        } else if (state.confirmStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showError(title: "Cảnh báo",message: "Gửi duyệt không thành công!");
          // _showDialog(title: "Lỗi", message: "Gửi duyệt lỗi!", success: false);
        } else if (state.deleteStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showError(title: "Cảnh báo",message: "Không xóa được bản ghi khác nháp!");
          // _showDialog(
          //   title: "Lỗi",
          //   message: "Không xóa được bản ghi khác nháp!",
          //   success: false,
          // );
        } else {
          LoadingOverlay.hide(context);
        }
      },

      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bodyColor,
          appBar: MyAppBar(
            titleAppbar: "Chi tiết yêu cầu nghỉ phép",
            haveBackButton: true,
          ),
          // extendBodyBehindAppBar: true,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16,right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(16)
                    ),
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
      _buildItem("Nhân viên", entity?.employeeName ?? "")
          .paddingOnly(bottom: 12),
      CustomDashView(),

      _buildItem("Phòng ban", entity?.departmentName ?? "")
          .paddingOnly(top: 12, bottom: 12),
      CustomDashView(),

      // _buildItem("Số phép còn lại",
      //         (entity?.remainLeave ?? 0).toString())
      //     .paddingOnly(top: 12, bottom: 12),
      // CustomDashView(),

      _buildItem("Loại nghỉ", entity?.holidayStatus ?? "")
          .paddingOnly(top: 12, bottom: 12),
      CustomDashView(),

      _buildItem(
        "Từ ngày",
        AppDateUtils.changeIso8601StringToDateTimeString(
          entity?.dateFrom,
        ),
      ).paddingOnly(top: 12, bottom: 12),
      CustomDashView(),

      _buildItem(
        "Đến ngày",
        AppDateUtils.changeIso8601StringToDateTimeString(
          entity?.dateTo,
        ),
      ).paddingOnly(top: 12, bottom: 12),
      CustomDashView(),

      _buildItem(
        "Lý do nghỉ",
        entity?.description ?? "",
      ).paddingOnly(top: 12, bottom: 12),
      CustomDashView(),

      Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: _buildStatusRow,
      ),
      CustomDashView(),

      _buildItem(
        "Lý do hủy",
        entity?.reasonCancel ?? "").paddingOnly(top: 4, bottom: 12),
        CustomDashView(),

      _buildItem(
        "Người duyệt",
        entity?.userApprove?.name ?? "",
      ).paddingOnly(top: 12, bottom: 12),

      const SizedBox(height: 30),
    ],
  );
}



get _bottomSheet {
  return (_cubit.state.detailEntity?.leaveStage?.id == 13) ?
  Container(
    margin: const EdgeInsets.only(left: 16,right: 16,bottom: 36),
    width: double.infinity,
    height: 46,
    child: Row(
      children: [
        Expanded(
          child: PrimaryButton(
            mainText: "Xóa",
            type: PrimaryButtonType.secondary,
            callback: () => showDeleteConfirmDialog(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            mainText: "Gửi duyệt",
            type: PrimaryButtonType.primary,
            callback: () {
              _cubit.confirmHrLeave(_cubit.state.detailEntity?.id ?? 0);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            mainText: "Cập nhật",
            type: PrimaryButtonType.primary,
            callback: () => doUpdate(context),
          ),
        ),
      ],
    ),
  ) : const SizedBox.shrink();
}


  void showDeleteConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (_) => CustomDialog(
            iconPath: AppAssets.ic_delete,
            title: "Xác nhận xoá",
            content: "Bạn có chắc muốn xoá bản ghi này không?",
            success: false,
            confirmText: "Xoá",
            cancelText: "Huỷ",
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
          "Trạng thái",
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
