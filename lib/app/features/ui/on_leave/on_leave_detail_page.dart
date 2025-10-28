import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/detail_on_leave_cubit.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../data/models/entities/on_leave_entity.dart';
import '../../widgets/custom_dash_view.dart';
import '../../widgets/my_app_bar.dart';

class OnLeaveDetailPage extends StatefulWidget {
  int? detailId;
  OnLeaveEntity? detailEntity;

  OnLeaveDetailPage({
    Key? key,
    this.detailId,
    this.detailEntity
  }) : super(key: key);

  @override
  State<OnLeaveDetailPage> createState() => _OnLeaveDetailPageState();
}

class _OnLeaveDetailPageState extends State<OnLeaveDetailPage> {
  final _cubit = GetIt.I.get<DetailOnLeaveCubit>();

  @override
  void initState() {
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
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailOnLeaveCubit,DetailOnLeaveState>(
        bloc: _cubit,
        listener: (context,state){

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
                    "Nguyễn Đăng Huy(NV00034)")
                    .paddingOnly(bottom: 8),
                CustomDashView(),

                // phòng ban
                _buildItem("Phòng ban",
                    "")
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // số phép còn lại
                _buildItem("Số phép còn lại",
                    "")
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // loại nghỉ
                _buildItem("Loại nghỉ",
                    "")
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // từ ngày
                _buildItem("Từ ngày",
                    "")
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // đến ngày
                _buildItem("Đến ngày",
                    "")
                    .paddingOnly(bottom: 8,top: 8),
                CustomDashView(),

                // lý do nghỉ
                _buildItem("Lý do nghỉ",
                    "")
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


              ],
            );
          }),

    );
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
}
