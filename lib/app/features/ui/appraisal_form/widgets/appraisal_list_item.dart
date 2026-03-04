import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';

class StatusUI {
  final String text;
  final Color color;
  final Color bgColor;

  const StatusUI({
    required this.text,
    required this.color,
    required this.bgColor,
  });
}

class AppraisalListItem extends StatelessWidget {
  final EvaluationEntity entity;
  final ValueChanged<EvaluationEntity>? onTap;

  const AppraisalListItem({super.key, required this.entity, this.onTap});

  StatusUI _getStatusUI(String? state) {
    switch (state) {
      case "draft":
        return StatusUI(
          text: "Nháp",
          color: AppColors.colorDraft,
          bgColor: AppColors.colorDraft.withValues(alpha: 0.1),
        );
      case "approved":
        return StatusUI(
          text: "Đã duyệt",
          color: AppColors.colorApproved,
          bgColor: AppColors.colorApproved.withValues(alpha: 0.1),
        );
      case "done":
        return StatusUI(
          text: "Hoàn thành",
          color: AppColors.colorFinished,
          bgColor: AppColors.colorFinished.withValues(alpha: 0.1),
        );
      case "cancel":
        return StatusUI(
          text: "Đã hủy",
          color: AppColors.colorCancel,
          bgColor: AppColors.colorCancel.withValues(alpha: 0.1),
        );
      default:
        return StatusUI(
          text: state ?? "",
          color: Colors.grey,
          bgColor: Colors.grey.withValues(alpha: 0.1),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusUI = _getStatusUI(entity.state);
    final df = DateFormat('dd/MM/yyyy');

    final dateText =
        (entity.dateFrom != null && entity.dateTo != null)
            ? "${df.format(DateTime.parse(entity.dateFrom!))} - ${df.format(DateTime.parse(entity.dateTo!))}"
            : "";

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          // <-- đảm bảo thanh màu kéo đầy chiều cao
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh màu bên trái: thêm borderRadius 2 góc trái để không bị che bởi parent
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: statusUI.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (onTap != null) {
                      onTap!(entity);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entity.name ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusUI.bgColor,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusUI.color,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusUI.text,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: statusUI.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildItem("Phòng ban:", entity.departmentName ?? ''),
                        const SizedBox(height: 12),
                        _buildItem("Nhân viên:", entity.employeeName ?? ''),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
