import 'package:flutter/material.dart';
import 'package:pm_app/generated/l10n.dart';
import '../../../../core/commons/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/entities/on_leave_entity.dart';

const int kManagerApproveStatusId = 14;

class OnLeaveListItem extends StatelessWidget {
  final OnLeaveEntity entity;
  final bool isChecked;
  final ValueChanged<bool?>? onCheckedChanged;
  final VoidCallback? onShowDetail;
  final bool showCheckbox;

  const OnLeaveListItem({
    super.key,
    required this.entity,
    required this.isChecked,
    required this.showCheckbox,
    this.onCheckedChanged,
    this.onShowDetail,
  });

  int get statusId => entity.leaveStage?.id ?? 0;
  bool get isManagerApprove => statusId == kManagerApproveStatusId;

  Color getStatusColor(int id) {
    switch (id) {
      case 1:
      case 6:
      case 13:
      case 17:
        return AppColors.colorDraft;
      case 14:
        return AppColors.colorApproved;
      case 11:
      case 15:
      case 9:
        return AppColors.colorFinished;
      case 20:
      case 16:
      case 12:
        return AppColors.colorCancel;
      default:
        return Colors.transparent;
    }
  }

  Color getBgColor(int id) {
    switch (id) {
      case 1:
      case 6:
      case 13:
      case 17:
        return AppColors.colorDraft.withValues(alpha: 0.1);
      case 14:
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

  String get approveOrReason {
    if (entity.userApprove != null &&
        (entity.userApprove?.name?.isNotEmpty ?? false)) {
      return entity.userApprove!.name!;
    }
    return entity.description ?? "-";
  }

  String approveOrReasonTitle(BuildContext context) {
    return entity.userApprove != null
        ? "${S.of(context).day_off_approver}:"
        : "${S.of(context).attendance_reason}:";
  }

  String getStatusTitle(int id, BuildContext context) {
    switch (id) {
      case 1:
      case 6:
      case 13:
      case 17:
        return S.of(context).day_off_status1;
      case 14:
        return S.of(context).day_off_status2;
      case 11:
      case 15:
      case 9:
        return S.of(context).to_do_completed;
      case 20:
      case 16:
      case 12:
        return S.of(context).cancel;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withAlpha(25)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10),
          ],
        ),
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

              Expanded(
                child: InkWell(
                  onTap: onShowDetail,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isManagerApprove && showCheckbox)
                              Theme(
                                data: Theme.of(context).copyWith(
                                  checkboxTheme: CheckboxThemeData(
                                    fillColor: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return AppColors.mainPrimaryColor6;
                                      }
                                      return Colors.transparent;
                                    }),
                                    checkColor: WidgetStateProperty.all(
                                      Colors.white,
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
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.themeBlackDefault,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
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
                                    getStatusTitle(statusId, context),
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
                        _buildItem(
                          "${S.of(context).day_off_card_employee}:",
                          entity.employeeName ?? "",
                        ),
                        const SizedBox(height: 12),
                        _buildItem(
                          "${S.of(context).day_off_card_type}:",
                          entity.holidayStatus ?? "",
                        ),
                        const SizedBox(height: 12),
                        _buildItem(
                          approveOrReasonTitle(context),
                          approveOrReason,
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

  Widget _buildItem(String title, String value, {bool isReason = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
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
          flex: 6,
          child: Text(
            value,
            maxLines: isReason ? 2 : 1,
            overflow: isReason ? TextOverflow.ellipsis : TextOverflow.visible,
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
