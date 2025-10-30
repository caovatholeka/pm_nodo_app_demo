import 'package:flutter/material.dart';

import '../../../../core/commons/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/entities/on_leave_entity.dart';

class OnLeaveListItem extends StatelessWidget {
  final OnLeaveEntity entity;
  final VoidCallback? onShowDetail;

  OnLeaveListItem(
      {Key? key,
        required this.entity,
        this.onShowDetail,
      })
      : super(key: key);

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
        return AppColors.colorRejected.withValues(alpha: 0.1);
      default:
        return Colors.transparent;
    }
  }

  String getStatusTitle(int status){
    switch(status){
      case 1:
        return "Chờ duyệt";//S.current.pending_approval;
      case 2:
        return  "Đã duyệt";//S.current.approved;
      case 3:
        return  "Từ chối"; //S.current.rejected;
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
                    color: getBgColor(entity.status ?? 0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: getStatusColor(entity.status ?? 0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 4,),
                      Text(
                        getStatusTitle(entity.status ?? 0),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: getStatusColor(entity.status ?? 0),
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
                _buildItem("Loại nghỉ",""),
                const SizedBox(height: 12,),
                _buildItem("Người duyệt:",""),
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