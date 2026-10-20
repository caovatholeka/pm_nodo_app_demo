import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
import 'package:pm_app/generated/l10n.dart';

/// Thẻ phiếu đánh giá — phiên bản giao diện tối (v2). Nội dung/hành vi giữ
/// nguyên [AppraisalListItem] (bản cũ), chỉ đổi cách trình bày sang hệ
/// thiết kế v2.
class AppraisalListItemV2 extends StatelessWidget {
  final EvaluationEntity entity;
  final ValueChanged<EvaluationEntity>? onTap;

  const AppraisalListItemV2({super.key, required this.entity, this.onTap});

  /// Ánh xạ trạng thái -> màu v2, giữ nguyên Ý NGHĨA màu bản cũ.
  static Color _statusColor(String? state) {
    switch (state) {
      case "draft":
        return AppTokensV2.fgMuted;
      case "director_confirm":
      case "approved":
      case "hr_confirm":
        return AppTokensV2.accent;
      case "done":
        return AppTokensV2.success;
      case "cancel":
        return AppTokensV2.danger;
      default:
        return AppTokensV2.fgMuted;
    }
  }

  String _statusText(BuildContext context, String? state) {
    final s = S.of(context);
    switch (state) {
      case "draft":
        return s.bt_status1;
      case "director_confirm":
      case "approved":
        return s.bt_status2;
      case "hr_confirm":
        return s.appraisal_status_hr_review;
      case "done":
        return s.bt_status3;
      case "cancel":
        return s.appraisal_status_cancelled;
      default:
        return state ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final color = _statusColor(entity.state);
    final fromText = AppDateUtils.formatFlexibleDateForDisplay(entity.dateFrom);
    final toText = AppDateUtils.formatFlexibleDateForDisplay(entity.dateTo);
    final dateText =
        fromText.isNotEmpty && toText.isNotEmpty ? "$fromText - $toText" : "";

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokensV2.surfaceStrong,
        borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
        border: Border.all(color: AppTokensV2.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap?.call(entity);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTokensV2.body.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _statusText(context, entity.state),
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(dateText, style: AppTokensV2.caption),
                        const SizedBox(height: 14),
                        _row(
                          '${s.employee_card_department}:',
                          entity.departmentName ?? '',
                        ),
                        const SizedBox(height: 10),
                        _row(
                          '${s.day_off_card_employee}:',
                          entity.employeeName ?? '',
                        ),
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

  Widget _row(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: AppTokensV2.caption.copyWith(fontSize: 12.5),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            style: AppTokensV2.captionStrong.copyWith(fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
