import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/features/ui/task/widget/status_widget.dart';

class ListTaskItem extends StatelessWidget {
  final TaskEntity entity;
  final VoidCallback? onShowDetail;
  final VoidCallback? onShowChangeStatus;
  final VoidCallback? onAddTaskNote;
  final bool? isShowNote;

  const ListTaskItem(
      {super.key,
        required this.entity,
        this.onShowDetail,
        this.onShowChangeStatus,
        this.onAddTaskNote,
        this.isShowNote
      });


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
    return GestureDetector(
      onTap: onShowDetail,
      child: Container(
        // padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border.all(
            color: Color(0xFFE9EAEB),
            width: 1,
          ),
          borderRadius: BorderRadius.all(Radius.circular(6))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12,),
            Row(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StatusWidget(color: getStatusColor(entity.stage?.code ?? "")),
                const SizedBox(width: 6,),
                Expanded(
                  flex: 8,
                  child: InkWell(
                    onTap: onShowChangeStatus,
                    child: Container(
                      padding: const EdgeInsets.only(left : 12, right: 12),
                      height: 37,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: getStatusColor(entity.stage?.code ?? ""),
                          borderRadius: BorderRadius.all(Radius.circular(6))
                      ),
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entity.stage?.name ?? "",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor
                            ),
                          ),
                          InkWell(
                            onTap: onShowChangeStatus,
                            child: Icon(Icons.arrow_drop_down,color: Colors.white,size: 18,),
                          )
                        ],
                      ),
                      // width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(width: 16,),
              ],
            ).paddingOnly(bottom: 12),
            // title, user_id
            Padding(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppAssets.icStar,width: 24,height: 24,),
                  const SizedBox(width: 8,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.name ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textEditorPrimary
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      const SizedBox(height: 3,),
                      Text(
                        entity.userIds?.map((user) => user.name).toList().join(",") ?? "",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textEditorSecond
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  )
                ],
              ),
            ),
            // deadline
            Padding(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hạn chót", style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textGray600
                  ),),
                  Text(entity.deadline ?? "",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textBlack600
                  ),),
                ],
              ),
            ),
            const SizedBox(height: 12,),
            // task type
            Padding(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Loại công việc", style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGray600
                  ),),
                  Text((entity.taskType ?? "") == "normal" ?
                      "Thông thường" : "Tuyển dụng",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textBlack600
                    ),),
                ],
              ),
            ),
            const SizedBox(height: 16,),
            // ngay giao viec
            Padding(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: SizedBox(
                height: 32,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (isShowNote ?? false) ?
                    InkWell(
                      onTap: onAddTaskNote,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add,size: 21,).paddingOnly(right: 6),
                          Text("Ghi chú kết quả", style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGray600
                          ),)
                        ],
                      ),
                    ) : Spacer(),
                    Row(
                      children: [
                        Text("19/11/2025 15:04:09",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGray600
                          ),
                        )
                      ],
                    ),
                  ],

                ),
              ),
            ),
            const SizedBox(height: 16,),
          ],
        ),
      ),
    );
  }
}
