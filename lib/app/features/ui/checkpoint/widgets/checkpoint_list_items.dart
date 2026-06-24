import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/checkpoint_entity.dart';
import 'package:pm_app/generated/l10n.dart';

class CheckpointStatusUI {
  final String text;
  final Color color;
  final Color bgColor;

  const CheckpointStatusUI({
    required this.text,
    required this.color,
    required this.bgColor,
  });
}

class CheckpointListItem extends StatelessWidget {
  final CheckpointEntity entity;
  final ValueChanged<CheckpointEntity>? onTap;

  const CheckpointListItem({super.key, required this.entity, this.onTap});

  CheckpointStatusUI _getStatusUI(BuildContext context, String? state) {
    final s = S.of(context);

    switch (state) {
      case "draft":
        return CheckpointStatusUI(
          text: s.bt_status1,
          color: AppColors.colorDraft,
          bgColor: AppColors.colorDraft.withValues(alpha: 0.1),
        );
      case "director_confirm":
      case "approved":
        return CheckpointStatusUI(
          text: s.bt_status2,
          color: AppColors.colorApproved,
          bgColor: AppColors.colorApproved.withValues(alpha: 0.1),
        );
      case "hr_confirm":
        return CheckpointStatusUI(
          text: s.appraisal_status_hr_review,
          color: AppColors.colorApproved,
          bgColor: AppColors.colorApproved.withValues(alpha: 0.1),
        );
      case "done":
        return CheckpointStatusUI(
          text: s.bt_status3,
          color: AppColors.colorFinished,
          bgColor: AppColors.colorFinished.withValues(alpha: 0.1),
        );
      case "cancel":
        return CheckpointStatusUI(
          text: s.appraisal_status_cancelled,
          color: AppColors.colorCancel,
          bgColor: AppColors.colorCancel.withValues(alpha: 0.1),
        );
      default:
        return CheckpointStatusUI(
          text: state ?? '',
          color: Colors.grey,
          bgColor: Colors.grey.withValues(alpha: 0.1),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusUI = _getStatusUI(context, entity.stage ?? entity.state);
    final fromText = AppDateUtils.formatFlexibleDateForDisplay(entity.dateFrom);
    final toText = AppDateUtils.formatFlexibleDateForDisplay(entity.dateTo);
    final dateText =
        fromText.isNotEmpty && toText.isNotEmpty ? '$fromText - $toText' : '';
    final managerName = entity.parent ?? entity.managerName ?? '';
    final employeeName = entity.employee ?? entity.employeeName ?? '';

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  onTap: () => onTap?.call(entity),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                entity.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textBlack600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusPill(statusUI: statusUI),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(label: 'Quản lý:', value: managerName),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Nhân viên:', value: employeeName),
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
}

class _StatusPill extends StatelessWidget {
  final CheckpointStatusUI statusUI;

  const _StatusPill({required this.statusUI});

  @override
  Widget build(BuildContext context) {
    if (statusUI.text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: statusUI.bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusUI.color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            statusUI.text,
            style: TextStyle(fontSize: 9, color: statusUI.color),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.themeBlackDefault,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
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
