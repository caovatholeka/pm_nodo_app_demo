import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/generated/l10n.dart';

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

class JustificationListItem extends StatelessWidget {
  final JustificationEntity entity;
  final VoidCallback? onTap;

  const JustificationListItem({
    super.key,
    required this.entity,
    this.onTap,
  });

  StatusUI _getStatusUI(BuildContext context, String? statusName) {
    final s = S.of(context);

    switch (statusName) {
      case 'Nháp':
        return StatusUI(
          text: s.bt_status1,
          color: AppColors.colorDraft,
          bgColor: AppColors.colorDraft.withValues(alpha: 0.1),
        );

      case 'Trưởng phòng duyệt':
        return StatusUI(
          text: s.bt_status2,
          color: AppColors.colorApproved,
          bgColor: AppColors.colorApproved.withValues(alpha: 0.1),
        );

      case 'Hoàn thành':
        return StatusUI(
          text: s.bt_status3,
          color: AppColors.colorFinished,
          bgColor: AppColors.colorFinished.withValues(alpha: 0.1),
        );

      default:
        return StatusUI(
          text: statusName ?? '',
          color: Colors.grey,
          bgColor: Colors.grey.withValues(alpha: 0.1),
        );
    }
  }

  String _getReasonTypeText(String? type, BuildContext context) {
    if (type == null || type.isEmpty) return '';
    final s = S.of(context);
    switch (type.toLowerCase()) {
      case 'personal':
        return s.justification_reason_type1;
      case 'work':
        return s.justification_reason_type2;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final statusUI = _getStatusUI(context, entity.stage?.name);

    final df = DateFormat('dd/MM/yyyy');
    final dateText = entity.date != null
        ? df.format(DateTime.parse(entity.date!))
        : '';

    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                blurRadius: 10,
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusUI.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entity.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateText,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
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
                                      fontWeight: FontWeight.w400,
                                      color: statusUI.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildItem(
                          s.justification_reason_type,
                          _getReasonTypeText(
                            entity.reasonType,
                            context,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildItem(
                          s.justification_create,
                          entity.employeeName ?? '',
                        ),
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
