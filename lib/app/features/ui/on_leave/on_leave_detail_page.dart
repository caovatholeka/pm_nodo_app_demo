import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/detail_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/create_new_leave_page.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
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

  OnLeaveDetailPage({
    super.key,
    this.detailId,
    this.detailEntity
  });

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

  @override
  void dispose() {
    super.dispose();
  }

  Color getStatusColor(int status){
    switch(status){
      case 1:
        return AppColors.colorPending;
      case 2:
        return AppColors.colorApproved;
      case 3:
        return AppColors.colorRejected;
      case 4:
        return AppColors.colorCancel;
      case 5:
        return AppColors.colorApproved;
      case 6:
        return AppColors.colorCancel;
      default:
        return Colors.transparent;
    }
  }

  Color getBgColor(int status){
    switch(status){
      case 1:
        return AppColors.colorPending.withValues(alpha: 0.1);
      case 2:
        return AppColors.colorApproved.withValues(alpha: 0.1);
      case 3:
        return AppColors.colorRejected.withValues(alpha: 0.1);
      case 4:
        return AppColors.colorCancel.withValues(alpha: 0.1);
      case 5:
        return AppColors.colorApproved.withValues(alpha: 0.1);
      case 6:
        return AppColors.colorCancel.withValues(alpha: 0.1);
      default:
        return Colors.transparent;
    }
  }

  String getStatusTitle(int status){
    switch(status){
      case 1:
        return "Chờ duyệt";
      case 2:
        return "Đã duyệt";
      case 3:
        return "Từ chối";
      case 4:
        return "Huỷ nghỉ phép";
      case 5:
        return "Đã duyệt huỷ";
      default:
        return "";
    }
  }
  Future<void> doUpdate(BuildContext context) async{
    final bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateNewLeavePage(
        isEdit: true,
        detailEntity: _cubit.state.detailEntity,
      )),
    );
    if (updated == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailOnLeaveCubit,DetailOnLeaveState>(
        bloc: _cubit,
        listener: (context,state){
          if(state.loadStatus == LoadStatus.LOADING ||
            state.deleteStatus == LoadStatus.LOADING ||
            state.confirmStatus == LoadStatus.LOADING
          ){
            LoadingOverlay.show(context);
          }
          else if(state.deleteStatus == LoadStatus.SUCCESS){
            LoadingOverlay.hide(context);
            AppSnackBar.showInfo(title: "Thành công",message: "Xoá bản ghi thành công!");
            Navigator.of(context).pop();
          }
          else if(state.confirmStatus == LoadStatus.SUCCESS){
            LoadingOverlay.hide(context);
            AppSnackBar.showInfo(title: "Thành công",message: "Đã gửi duyệt thành công!");
            Navigator.of(context).pop();
          }
          else if(state.confirmStatus == LoadStatus.FAILURE){
            LoadingOverlay.hide(context);
            AppSnackBar.showInfo(title: "Lỗi",message: "Gửi duyệt lỗi!");
          }
          else if(state.deleteStatus == LoadStatus.FAILURE){
            LoadingOverlay.hide(context);
            AppSnackBar.showInfo(title: "Lỗi",message: "Không xóa được bản ghi khác nháp!");
          }
          else{
            LoadingOverlay.hide(context);
          }
        },
        builder: (context,state){
          return Scaffold(
            appBar: MyAppBar(titleAppbar: "Chi tiết yêu cầu nghỉ phép",
              haveBackButton: true,
            ),
            extendBodyBehindAppBar: true,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets.appBg),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 120,),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                      decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),)
                      ),
                      child: _contentBody,
                    ),
                  ))
                ],
              ),
            ),
          );
        });
  }

  get _contentBody {
    return SingleChildScrollView(
      child: BlocBuilder<DetailOnLeaveCubit,DetailOnLeaveState>(
          bloc: _cubit,
          buildWhen: (prev,cur) => prev.loadStatus != cur.loadStatus ||
            prev.detailEntity != cur.detailEntity,
          builder: (context,state){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // nhân viên
                _buildItem("Nhân viên",
                    _cubit.state.detailEntity?.employeeName ?? "")
                    .paddingOnly(bottom: 8),
                CustomDashView(),

                // phòng ban
                _buildItem("Phòng ban",
                    _cubit.state.detailEntity?.departmentName ??"")
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // số phép còn lại
                _buildItem("Số phép còn lại",
                    (_cubit.state.detailEntity?.remainLeave ?? 0).toString())
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // loại nghỉ
                _buildItem("Loại nghỉ",
                    _cubit.state.detailEntity?.holidayStatus ?? "")
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // từ ngày
                _buildItem("Từ ngày",
                    AppDateUtils.changeIso8601StringToDateTimeString(_cubit.state.detailEntity?.dateFrom))
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // đến ngày
                _buildItem("Đến ngày",
                    AppDateUtils.changeIso8601StringToDateTimeString(_cubit.state.detailEntity?.dateTo))
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // lý do nghỉ
                _buildItem("Lý do nghỉ",
                    _cubit.state.detailEntity?.description ?? "")
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // Trạng thái

                // Người duyệt
                _buildItem("Người duyệt",
                    "")
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // Người follow
                _buildItem("Người follow",
                    "")
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                const SizedBox(height: 30,),
                // state.detailEntity?.state == "draft"  ?
                //   _bottomSheet : const SizedBox.shrink(),
                _bottomSheet,
                const SizedBox(height: 30,),
              ],
            );
          }),

    );
  }

  get _bottomSheet{
    return BlocBuilder<DetailOnLeaveCubit,DetailOnLeaveState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.detailEntity != cur.detailEntity,
        builder: (context,state){
          return Container(
            padding: const EdgeInsets.fromLTRB(32, 10, 32, 15),
            child: SafeArea(
              bottom: true,
              top: false,
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: PrimaryButton(
                        callback:(){
                          _cubit.confirmHrLeave(_cubit.state.detailEntity?.id ?? 0);
                        },
                        mainText: "Gửi duyệt",//context.loc.update,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.whiteColor
                        ),
                      )),
                  const SizedBox(width: 10,),
                  Expanded(
                      flex: 1,
                      child: PrimaryButton(
                        callback:(){
                          doUpdate(context);
                        },
                        mainText: "Cập nhật",//context.loc.update,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.whiteColor
                        ),
                      )),
                  const SizedBox(width: 10,),
                  Expanded(
                      flex: 1,
                      child: PrimaryButton(
                        callback: (){
                          // logger.d(_cubit.state.detailOnLeave?.id ?? 0);
                          // show dialog
                          showDeleteConfirmDialog(context);
                        },
                        mainText: "Xoá",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.whiteColor
                        ),
                      )),
                ],
              )
            ),
          );
        });

  }

  Widget _buildItem(String title, String value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 4,
          child: Text(title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.themeBlackDefault
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        Flexible(
          flex: 6,
          child: Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.themeBlackDefault
            ),
            overflow: TextOverflow.clip,
            maxLines: 3,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  get _buildStatusRow{
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Trạng thái",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.themeBlackDefault
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 4),
          decoration: BoxDecoration(
            color: getBgColor(_cubit.state.detailEntity?.status ?? 0),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Center(
            child: Text(
              getStatusTitle(_cubit.state.detailEntity?.status ?? 0),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color:getStatusColor(_cubit.state.detailEntity?.status ?? 0),
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
      ],
    ).paddingOnly(bottom: 8,top: 8);
  }

  void showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Xác nhận",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                color: AppColors.themeBlackDefault,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Bạn chắc muốn xoá",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                color: AppColors.themeBlackDefault,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whiteColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      "Huỷ",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        color: AppColors.themeBlackDefault,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width:24,),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // call cubit change password
                      _cubit.deleteOnLeave(_cubit.state.detailEntity?.id ?? 0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.themePrimaryDefault,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      "Xác nhận",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
