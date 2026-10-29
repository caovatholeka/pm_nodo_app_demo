import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/entities/on_leave_entity.dart';
import 'package:pm_app/app/core/theme_v2/label_v2.dart';

const int kManagerApproveStatusIdV2 = 14;

/// Thẻ đơn nghỉ phép — phiên bản giao diện tối (v2). Nội dung/hành vi giữ nguyên
/// [OnLeaveListItem] (bản cũ), chỉ đổi cách trình bày sang hệ thiết kế v2.
class OnLeaveListItemV2 extends StatelessWidget {
  final OnLeaveEntity entity;
  final bool isChecked;
  final bool showCheckbox;
  final bool isDirector;

  final ValueChanged<bool?>? onCheckedChanged;
  final VoidCallback? onShowDetail;

  const OnLeaveListItemV2({
    super.key,
    required this.entity,
    required this.isChecked,
    required this.showCheckbox,
    required this.isDirector,
    this.onCheckedChanged,
    this.onShowDetail,
  });

  int get statusId => entity.leaveStage?.id ?? 0;
  bool get isManagerApprove => statusId == kManagerApproveStatusIdV2;

  /// Ánh xạ trạng thái -> màu, giữ nguyên Ý NGHĨA màu bản cũ
  /// (nháp/xám, đã duyệt/xanh dương, hoàn thành/xanh lá, huỷ/đỏ)
  /// nhưng dùng bảng màu tối v2.
  Color _statusColor(int id) => statusColorFor(id);

  /// Bản `static` để các widget khác (vd. marker trên lịch) dùng chung
  /// đúng bảng màu trạng thái, không phải định nghĩa lại.
  static Color statusColorFor(int id) {
    switch (id) {
      case 1:
      case 6:
      case 13:
      case 17:
        return AppTokensV2.fgMuted;
      case 14:
        return AppTokensV2.accent;
      case 11:
      case 15:
      case 9:
        return AppTokensV2.success;
      case 20:
      case 16:
      case 12:
        return _cancelColor;
      default:
        return AppTokensV2.fgMuted;
    }
  }

  static Color get _cancelColor => AppTokensV2.danger;

  String _statusTitle(int id, BuildContext context) {
    final s = S.of(context);
    switch (id) {
      case 1:
      case 6:
      case 13:
      case 17:
        return s.day_off_status1;
      case 14:
        return s.day_off_status2;
      case 11:
      case 15:
      case 9:
        return s.to_do_completed;
      case 20:
      case 16:
      case 12:
        return s.cancel;
      default:
        return "";
    }
  }

  String get _approveOrReason {
    if (entity.userApprove != null &&
        (entity.userApprove?.name?.isNotEmpty ?? false)) {
      return entity.userApprove!.name!;
    }
    return entity.description ?? "-";
  }

  String _approveOrReasonTitle(BuildContext context) {
    // "attendance_reason" tiếng Việt có sẵn ":" → trước đây hiện "Lý do::"
    return entity.userApprove != null
        ? "${labelV2(S.of(context).day_off_approver)}:"
        : "${labelV2(S.of(context).attendance_reason)}:";
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(statusId);
    final showCheckboxNow = isDirector && isManagerApprove && showCheckbox;

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
                            if (showCheckboxNow)
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
                                  onChanged: onCheckedChanged,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                "${AppDateUtils.changeIso8601StringToDateTimeString(entity.dateFrom)} - "
                                "${AppDateUtils.changeIso8601StringToDateTimeString(entity.dateTo)}",
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
                          "${S.of(context).day_off_card_employee}:",
                          entity.employeeName ?? "",
                        ),
                        const SizedBox(height: 10),
                        _row(
                          "${S.of(context).day_off_card_type}:",
                          entity.holidayStatus ?? "",
                        ),
                        const SizedBox(height: 10),
                        _row(
                          _approveOrReasonTitle(context),
                          _approveOrReason,
                          isReason: entity.userApprove == null,
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

  Widget _row(String title, String value, {bool isReason = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(title, style: AppTokensV2.caption.copyWith(fontSize: 12.5)),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            maxLines: isReason ? 2 : 1,
            overflow: isReason ? TextOverflow.ellipsis : TextOverflow.visible,
            style: AppTokensV2.captionStrong.copyWith(fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
