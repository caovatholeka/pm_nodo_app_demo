import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/task_stage_entity.dart';
import 'package:pm_app/app/features/ui/task/widget/status_widget.dart';

import '../../../../core/commons/app_shadow.dart';
import '../../../../core/commons/screen_size.dart';


class TaskStageBottomSheet extends StatefulWidget {
  final List<TaskStageEntity>? listStages;
  final String? currentTaskStatus;

  const TaskStageBottomSheet({
    super.key,
    this.listStages,
    this.currentTaskStatus,

  });

  @override
  State<TaskStageBottomSheet> createState() => _TaskStageBottomSheetState();
}

class _TaskStageBottomSheetState extends State<TaskStageBottomSheet> {


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
    return Container(
      height: ScreenSize.of(context).height * 0.45,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: AppShadow.boxShadow,
      ),
    child: Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6,),
          Text("Chọn giai đoạn giao dịch",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack600
            ),
          ).paddingOnly(left: 16,bottom: 8),

          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.textGray600,
          ).paddingOnly(bottom: 12),

          SizedBox(
              width: double.infinity,
              height: ScreenSize.of(context).height * 0.35,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: (widget.listStages ?? []).length,
                itemBuilder: (context, index) {
                  TaskStageEntity value = (widget.listStages ?? [])[index];
                  return InkWell(
                    onTap: (){
                      Navigator.pop(context, value);
                    },
                    child: Row(
                      children: [
                        (widget.currentTaskStatus == value.code) ? StatusWidget(color: getStatusColor(value.code ?? ""),
                          width: 10,
                          height: 26,
                        ) : const SizedBox(
                          width: 10,
                          height: 26,
                        ),
                        const SizedBox(width: 14,),
                        Text(
                          "${value.id ?? 0}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGray500
                          ),
                        ),
                        const SizedBox(width: 14,),
                        Expanded(
                            flex: 8,
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal : 12, vertical: 16),
                              decoration: BoxDecoration(
                                  color: getStatusColor(value.code ?? ""),
                                  borderRadius: BorderRadius.all(Radius.circular(6))
                              ),
                              child: Text(value.name ?? "",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.whiteColor
                                ),
                              ),
                            )),
                        const SizedBox(width: 16,),
                      ],
                    ),
                  );
                },
                separatorBuilder: (buildContext, index) => Container(
                  height: 10,
                  color: Colors.white,
                ),
              ))
        ],
      ),
    )
    );
  }
}
