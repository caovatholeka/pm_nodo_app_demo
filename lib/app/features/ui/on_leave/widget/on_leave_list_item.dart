import 'package:flutter/material.dart';

import '../../../../core/commons/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/entities/on_leave_entity.dart';

class OnLeaveListItem extends StatelessWidget {
  final OnLeaveEntity entity;
  final VoidCallback? onShowDetail;

  const OnLeaveListItem(
      {super.key,
        required this.entity,
        this.onShowDetail,
      });

  // trạng thái đơn nghỉ :
  // Nháp , Trưởng phòng duyệt, Hoàn thành, Huỷ

  Color getStatusColor(int id){
    switch(id){
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

  Color getBgColor(int status){
    switch(status){
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

  String getStatusTitle(int status){
    switch(status){
      case 1:
      case 6:
      case 13:
      case 17:
        return "Nháp";//S.current.pending_approval;
      case 14:
        return  "Trưởng phòng duyệt";//S.current.approved;
      case 11:
      case 15:
      case 9:
        return  "Hoàn thành"; //S.current.rejected;
      case 20:
      case 16:
      case 12:
        return "Huỷ";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onShowDetail,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withAlpha(25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              offset: const Offset(0, 0),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${AppDateUtils.changeIso8601StringToDateTimeString(entity.dateFrom)}"
                    " - ${AppDateUtils.changeIso8601StringToDateTimeString(entity.dateTo)}",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.themeBlackDefault
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                  decoration: BoxDecoration(
                    color: getBgColor(entity.leaveStage?.id ?? 0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: getStatusColor(entity.leaveStage?.id ?? 0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 4,),
                      Text(
                        getStatusTitle(entity.leaveStage?.id ?? 0),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: getStatusColor(entity.leaveStage?.id ?? 0),
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Column(
              children: [
                const SizedBox(height: 16,),
                _buildItem("Loại nghỉ", entity.holidayStatus ?? ""),
                const SizedBox(height: 12,),
                _buildItem("Người duyệt:",entity.userApprove?.name ?? ""),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String title, String value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(flex : 1,
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.themeBlackDefault
              ),
              textAlign: TextAlign.start,
            )),
        Expanded(flex : 1,
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.themeBlackDefault
              ),
              textAlign: TextAlign.start,
            )),
      ],
    );
  }
}