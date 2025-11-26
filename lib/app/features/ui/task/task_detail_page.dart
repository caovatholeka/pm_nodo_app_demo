import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';
import 'package:pm_app/app/features/ui/task/create_new_task.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../widgets/custom_dash_view.dart';
import '../../widgets/custom_dialog.dart';


class TaskDetailPage extends StatefulWidget {
  int? taskId;
  TaskEntity? taskEntity;

  TaskDetailPage({super.key, this.taskId, this.taskEntity});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _cubit = GetIt.I.get<TaskCubit>();

  @override
  void initState() {
    _cubit.getDetailTask(widget.taskId ?? 0);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color getStatusColor(String code){
    switch(code){
      case "new":
        return AppColors.newTask;
      case "in_progress":
        return AppColors.progressTask;
      case "done":
        return AppColors.doneTask;
      case "rejected":
        return AppColors.rejectTask;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit,TaskState>(
        bloc: _cubit,
      listener: (context,state){
        if(state.deleteStatus == LoadStatus.LOADING){
          LoadingOverlay.show(context);
        }
        if(state.deleteStatus == LoadStatus.SUCCESS){
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showInfo(title:"Thành công",message: "Xoá công việc thành công!!");
          Navigator.pop(context,true);
        }
        if (state.deleteStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showError(title:"Cảnh báo",message: "Có lỗi xảy ra , vui lòng thử lại sau!!");
        }
        else{
          LoadingOverlay.hide(context);
        }
      },
      builder: (context,state) {
         return Scaffold(
           backgroundColor: AppColors.bodyColor,
           appBar: AppBar(
             title: Text("Chi tiết việc cần làm"),
             flexibleSpace: Container(
               width: double.infinity,
               height: double.infinity,
               decoration: BoxDecoration(
                 image: DecorationImage(
                   image: AssetImage(AppAssets.appbarBg),
                   fit: BoxFit.fill,
                 ),
               ),
             ),
             leading: IconButton(
               onPressed: () {
                 Navigator.of(context).maybePop();
               },
               icon: Image.asset(
                 AppAssets.ic_arrowB,
                 width: 30,
                 height: 30,
               ),
             ),
           ),
           body: SizedBox(
             width: double.infinity,
             height: double.infinity,
             child: Stack(
               children: [
                 SingleChildScrollView(
                   padding: const EdgeInsets.only(left: 16,right: 16),
                   child: BlocBuilder<TaskCubit,TaskState>(
                       bloc: _cubit,
                       buildWhen: (prev,cur) => prev.loadDetailStatus != cur.loadDetailStatus ||
                       prev.detailTask != cur.detailTask,
                       builder: (context,state){
                         return  state.loadDetailStatus == LoadStatus.LOADING ?
                          Center(child: CircularProgressIndicator(color: AppColors.themePrimaryDefault,),) :
                          Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 20),
                           decoration: BoxDecoration(
                             color: AppColors.whiteColor,
                             borderRadius: BorderRadius.all(Radius.circular(6))
                           ),

                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(state.detailTask?.name ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textEditorPrimary,
                                ),
                               ),
                               const SizedBox(height: 16,),
                               _getPriority,
                               const SizedBox(height: 8,),
                               CustomDashView(),
                               const SizedBox(height: 8,),
                               _buildItem("Loại Công việc",
                                   (state.detailTask?.taskType ?? "") == "normal" ? "Thông thường" : "Tuyển dụng")
                                   .paddingOnly(bottom: 8),
                               CustomDashView(),

                               const SizedBox(height: 8,),
                               _buildItem("Người giao việc",
                                   state.detailTask?.assigner?.name ?? "")
                                   .paddingOnly(bottom: 8),
                               CustomDashView(),

                               const SizedBox(height: 8,),
                               _buildItem("Người được phân công",
                                   state.detailTask?.userIds?.map((sc) => sc.name).toList().join(",") ?? "")
                                   .paddingOnly(bottom: 8),
                               CustomDashView(),

                               const SizedBox(height: 8,),
                               _buildItem("Hạn chót",
                                   state.detailTask?.deadline ?? "")
                                   .paddingOnly(bottom: 8),
                               CustomDashView(),

                               const SizedBox(height: 8,),
                               _statusWidget,
                               const SizedBox(height: 8,),
                               CustomDashView(),

                               const SizedBox(height: 8,),
                               _buildItem("Mô tả",
                                   state.detailTask?.description ?? "")
                                   .paddingOnly(bottom: 16),
                             ],
                           ),
                         );
                       })
                 ),
                 Positioned(
                     bottom: 40,
                     left: 32,
                     right: 32,
                     child: SizedBox(
                       width: double.infinity,
                       child: _bottomSheet
                     ))
               ],
             ),
           ),
           // bottomSheet: _bottomSheet,
         );
      });
  }

  get _getPriority {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 5,
          child: Text(
            "Mức độ ưu tiên",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.themeBlackDefault,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          flex: 5,
          child: Align(
            alignment: Alignment.centerRight,
            child: SvgPicture.asset(AppAssets.icStar, width: 24, height: 24,
                color: (_cubit.state.detailTask?.priority == 1) ? Colors.amber : Colors.grey,
                ),
          )
        ),
      ],
    );
  }

  get _bottomSheet {
    return BlocBuilder<TaskCubit, TaskState>(
      bloc: _cubit,
      buildWhen: (prev, cur) => prev.detailTask != cur.detailTask,
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: (){
                  showDeleteConfirmDialog();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    border: Border.all(
                      width: 1,
                      color: AppColors.themeBlackDefault.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    "Xoá",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.themePrimaryDefault
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: (){
                  doUpdate(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.themePrimaryDefault,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    border: Border.all(
                      width: 1,
                      color: AppColors.themeBlackDefault.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    "Cập nhật",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.whiteColor
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  get _statusWidget {
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
          overflow: TextOverflow.ellipsis,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
          decoration: BoxDecoration(
            color: getStatusColor(_cubit.state.detailTask?.stage?.code ?? "").withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getStatusColor(_cubit.state.detailTask?.stage?.code ?? "")
                ),
              ).paddingOnly(right: 4),
              Text(
                (_cubit.state.detailTask?.stage?.name ?? "").toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: getStatusColor(_cubit.state.detailTask?.stage?.code ?? "")
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
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
            maxLines: 2,
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

  // Helper func
  Future<void> doUpdate(BuildContext context) async {
    final bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewTask(
          isEdit: true,
          detailEntity: _cubit.state.detailTask,
        ),
      ),
    );
    if (updated == true) {
      Navigator.pop(context, true);
    }
  }

  void showDeleteConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => CustomDialog(
        iconPath: AppAssets.ic_delete,
        title: "Xoá yêu cầu",
        content: "Bạn có chắc muốn xoá yêu cầu này không? \n"
            "Thao tác này không thể hoàn tác",
        success: false,
        confirmText: "Xoá",
        cancelText: "Huỷ bỏ",
        onConfirm: () {
          Navigator.pop(context);
          _cubit.deleteTask(_cubit.state.detailTask?.id ?? 0);
        },
      ),
    );
  }
}
