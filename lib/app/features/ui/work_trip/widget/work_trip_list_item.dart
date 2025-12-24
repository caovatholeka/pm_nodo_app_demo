import 'package:flutter/material.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';

import '../../../../core/commons/app_colors.dart';

class WorkTripListItem extends StatelessWidget {
  final WorkTripEntity entity;
  final VoidCallback? onShowDetail;

  const WorkTripListItem({
    super.key,
    required this.entity,
    this.onShowDetail,
  });

  Color getStatusColor(int id) {
    switch (id) {
      case 25:
        return AppColors.colorDraft;
      case 26:
        return AppColors.colorApproved;
      case 9:
        return AppColors.colorFinished;
      case 12:
        return AppColors.colorCancel;
      default:
        return Colors.transparent;
    }
  }

  Color getBgColor(int status) {
    switch (status) {
      case 25:
        return AppColors.colorDraft.withValues(alpha: 0.1);
      case 26:
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
      case 25:
        return "Nháp";
      case 26:
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

  @override
  Widget build(BuildContext context) {
    final statusId =  entity.stage?.id ?? 0;
    return InkWell(
      onTap: onShowDetail,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
          // Dùng IntrinsicHeight để thanh màu có chiều cao bằng nội dung
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: getStatusColor(statusId),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),

                // Nội dung
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                             entity.name ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.themeBlackDefault,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: getBgColor(statusId),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: getStatusColor(statusId),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    getStatusTitle(statusId),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      color: getStatusColor(statusId),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildItem("Tổng số người:",  "${entity.employeeCount ?? 0}"),
                        const SizedBox(height: 12),
                        _buildItem("Ghi chú:", entity.note ?? ""),
                        const SizedBox(height: 12),
                        _buildItem("Người tạo:", entity.employeeName ?? ""),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.themeBlackDefault,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.themeBlackDefault,
            ),
          ),
        ),
      ],
    );
  }
}
