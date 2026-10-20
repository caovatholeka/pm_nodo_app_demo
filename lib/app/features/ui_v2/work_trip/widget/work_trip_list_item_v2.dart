import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/generated/l10n.dart';

/// Thẻ đơn công tác — phiên bản giao diện tối (v2). Nội dung/hành vi giữ
/// nguyên [WorkTripListItem] (bản cũ), chỉ đổi cách trình bày sang hệ
/// thiết kế v2.
class WorkTripListItemV2 extends StatelessWidget {
  final WorkTripEntity entity;
  final VoidCallback? onShowDetail;
  final bool isChecked;
  final ValueChanged<bool?>? onCheckedChange;
  final bool canApprove;

  const WorkTripListItemV2({
    super.key,
    required this.entity,
    required this.isChecked,
    required this.canApprove,
    this.onCheckedChange,
    this.onShowDetail,
  });

  bool get isManagerApprove => entity.stage?.name == 'Trưởng phòng duyệt';

  /// Ánh xạ trạng thái -> màu, giữ nguyên Ý NGHĨA màu bản cũ
  /// (nháp/xám, đã duyệt/xanh dương, hoàn thành/xanh lá, huỷ/đỏ)
  /// nhưng dùng bảng màu tối v2.
  Color _statusColor(int id) {
    switch (id) {
      case 1:
      case 25:
      case 6:
      case 13:
      case 17:
      case 21:
        return AppTokensV2.fgMuted;
      case 14:
      case 22:
      case 26:
      case 30:
        return AppTokensV2.accent;
      case 15:
      case 19:
      case 23:
      case 27:
      case 31:
        return AppTokensV2.success;
      case 20:
      case 16:
      case 12:
      case 24:
      case 28:
      case 32:
        return AppTokensV2.danger;
      default:
        return AppTokensV2.fgMuted;
    }
  }

  String _statusTitle(int status, BuildContext context) {
    switch (status) {
      case 1:
      case 25:
      case 6:
      case 13:
      case 17:
      case 21:
        return S.of(context).bt_status1;
      case 14:
      case 22:
      case 26:
      case 30:
        return S.of(context).bt_status2;
      case 15:
      case 19:
      case 23:
      case 27:
      case 31:
        return S.of(context).bt_status3;
      case 20:
      case 16:
      case 12:
      case 24:
      case 28:
      case 32:
        return S.of(context).cancel;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusId = entity.stage?.id ?? 0;
    final color = _statusColor(statusId);

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
                    onShowDetail?.call();
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
                            if (canApprove && isManagerApprove)
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
                              child: Text(
                                entity.name ?? '',
                                style: AppTokensV2.body.copyWith(
                                  fontSize: 13,
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
                                    _statusTitle(statusId, context),
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
                          S.of(context).bt_card_total,
                          "${entity.employeeCount ?? 0}",
                        ),
                        const SizedBox(height: 10),
                        _row(S.of(context).bt_card_notes, entity.note ?? ""),
                        const SizedBox(height: 10),
                        _row(
                          S.of(context).bt_card_createby,
                          entity.employeeName ?? "",
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
