import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:pm_app/app/core/theme_v2/label_v2.dart';

/// Thẻ đơn muộn/sớm — phiên bản giao diện tối (v2). Nội dung/hành vi giữ
/// nguyên [JustificationListItem] (bản cũ), chỉ đổi cách trình bày sang hệ
/// thiết kế v2.
class JustificationListItemV2 extends StatelessWidget {
  final JustificationEntity entity;
  final VoidCallback? onTap;
  final bool isChecked;
  final bool canApprove;
  final ValueChanged<bool?>? onCheckedChange;

  const JustificationListItemV2({
    super.key,
    required this.entity,
    required this.isChecked,
    required this.canApprove,
    this.onCheckedChange,
    this.onTap,
  });

  bool get isManagerApprove => entity.stage?.name == 'Trưởng phòng duyệt';

  /// Ánh xạ trạng thái -> màu v2, giữ nguyên Ý NGHĨA màu bản cũ
  /// (nháp/xám, chờ trưởng phòng duyệt/xanh dương, hoàn thành/xanh lá, huỷ/đỏ).
  static Color _statusColor(String? statusName) {
    switch (statusName) {
      case 'Nháp':
        return AppTokensV2.fgMuted;
      case 'Trưởng phòng duyệt':
        return AppTokensV2.accent;
      case 'Hoàn thành':
        return AppTokensV2.success;
      case 'Hủy':
        return AppTokensV2.danger;
      default:
        return AppTokensV2.fgMuted;
    }
  }

  String _statusText(BuildContext context, String? statusName) {
    final s = S.of(context);
    switch (statusName) {
      case 'Nháp':
        return s.bt_status1;
      case 'Trưởng phòng duyệt':
        return s.bt_status2;
      case 'Hoàn thành':
        return s.bt_status3;
      case 'Hủy':
        return s.cancel;
      default:
        return statusName ?? '';
    }
  }

  String _reasonTypeText(String? type, BuildContext context) {
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
    final color = _statusColor(entity.stage?.name);
    final df = DateFormat('dd/MM/yyyy');
    final dateText =
        entity.date != null ? df.format(DateTime.parse(entity.date!)) : '';

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
                    onTap?.call();
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isManagerApprove && canApprove)
                              Theme(
                                data: Theme.of(context).copyWith(
                                  checkboxTheme: CheckboxThemeData(
                                    fillColor: WidgetStateProperty.resolveWith(
                                      (states) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return AppTokensV2.accent;
                                        }
                                        return Colors.transparent;
                                      },
                                    ),
                                    checkColor: WidgetStateProperty.all(
                                      Colors.white,
                                    ),
                                    side: BorderSide(
                                      color: AppTokensV2.fgMuted,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                child: Checkbox(
                                  value: isChecked,
                                  onChanged: onCheckedChange,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entity.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTokensV2.body.copyWith(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(dateText, style: AppTokensV2.caption),
                                ],
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
                                    _statusText(context, entity.stage?.name),
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
                        const SizedBox(height: 14),
                        _row(
                          s.justification_reason_type,
                          _reasonTypeText(entity.reasonType, context),
                        ),
                        const SizedBox(height: 10),
                        _row(s.justification_create, entity.employeeName ?? ''),
                        const SizedBox(height: 10),
                        _row(
                          s.attendance_reason,
                          entity.note ?? '',
                          maxLines: 2,
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

  Widget _row(String title, String value, {int? maxLines}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            labelV2(title),
            style: AppTokensV2.caption.copyWith(fontSize: 12.5),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
            style: AppTokensV2.captionStrong.copyWith(fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
