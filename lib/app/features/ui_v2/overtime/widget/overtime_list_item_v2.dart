import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/generated/l10n.dart';

/// Thẻ đơn tăng ca — phiên bản giao diện tối (v2). Nội dung/hành vi giữ
/// nguyên [OvertimeListItem] (bản cũ), chỉ đổi cách trình bày sang hệ
/// thiết kế v2.
class OvertimeListItemV2 extends StatelessWidget {
  final OvertimeEntity entity;
  final VoidCallback? onTap;

  final bool canApprove;
  final bool isChecked;
  final ValueChanged<bool?>? onCheckedChange;

  const OvertimeListItemV2({
    super.key,
    required this.entity,
    this.onTap,
    required this.canApprove,
    required this.isChecked,
    this.onCheckedChange,
  });

  bool get _showCheckbox =>
      canApprove && entity.stage?.name == 'Trưởng phòng duyệt';

  String _formatDateRange(String? from, String? to) {
    if (from == null || to == null) return '';
    final df = DateFormat('dd/MM/yyyy');
    final fromText = df.format(DateTime.parse(from));
    final toText = df.format(DateTime.parse(to));
    return '$fromText - $toText';
  }

  /// Ánh xạ trạng thái -> màu, giữ nguyên Ý NGHĨA màu bản cũ
  /// (nháp/xám, đã duyệt/xanh dương, hoàn thành/xanh lá, huỷ/đỏ)
  /// nhưng dùng bảng màu tối v2.
  Color _statusColor(String? name) {
    switch (name) {
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

  String _localizedStatusName(BuildContext context, String? name) {
    final s = S.of(context);
    switch (name) {
      case 'Nháp':
        return s.bt_status1;
      case 'Trưởng phòng duyệt':
        return s.bt_status2;
      case 'Hoàn thành':
        return s.bt_status3;
      default:
        return name ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = entity.stage;
    final rawStatusName = stage?.name;
    final color = _statusColor(rawStatusName);
    final displayStatusName = _localizedStatusName(context, rawStatusName);
    final dateRangeText = _formatDateRange(entity.fromDate, entity.toDate);
    final s = S.of(context);

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
                            if (_showCheckbox)
                              Theme(
                                data: Theme.of(context).copyWith(
                                  checkboxTheme: CheckboxThemeData(
                                    fillColor: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return AppTokensV2.accent;
                                      }
                                      return Colors.transparent;
                                    }),
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
                                    style: AppTokensV2.body.copyWith(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateRangeText,
                                    style: AppTokensV2.caption,
                                  ),
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
                                    displayStatusName,
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
                        _row(s.ot_cardCreator, entity.employeeName ?? ''),
                        const SizedBox(height: 10),
                        _row(s.ot_cardNote, entity.note ?? '', maxLines: 2),
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
            title,
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
