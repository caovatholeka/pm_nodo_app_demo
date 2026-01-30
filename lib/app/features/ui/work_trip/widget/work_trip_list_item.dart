import 'package:flutter/material.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../../core/commons/app_colors.dart';

class WorkTripListItem extends StatelessWidget {
  final WorkTripEntity entity;
  final VoidCallback? onShowDetail;
  final bool isChecked;
  final ValueChanged<bool?>? onCheckedChange;
  final bool canApprove;

  const WorkTripListItem({
    super.key,
    required this.entity,
    required this.isChecked,
    required this.canApprove,
    this.onCheckedChange,
    this.onShowDetail,
  });

  bool get isManagerApprove =>
      entity.stage?.name == 'Trưởng phòng duyệt';

  Color getStatusColor(int id) {
    switch (id) {
      case 1:
      case 25:
      case 6:
      case 13:
      case 17:
      case 21:
        return AppColors.colorDraft;
      case 14:
      case 22:
      case 26:
      case 30:
        return AppColors.colorApproved;
      case 15:
      case 19:
      case 23:
      case 27:
      case 31:
        return AppColors.colorFinished;
      case 20:
      case 16:
      case 12:
      case 24:
      case 28:
      case 32:
        return AppColors.colorCancel;
      default:
        return Colors.transparent;
    }
  }

  Color getBgColor(int status) {
    switch (status) {
      case 1:
      case 25:
      case 6:
      case 13:
      case 17:
      case 21:
        return AppColors.colorDraft.withValues(alpha: 0.1);
      case 14:
      case 22:
      case 26:
      case 30:
        return AppColors.colorApproved.withValues(alpha: 0.1);
      case 15:
      case 19:
      case 23:
      case 27:
      case 31:
        return AppColors.colorFinished.withValues(alpha: 0.1);
      case 20:
      case 16:
      case 12:
      case 24:
      case 28:
      case 32:
        return AppColors.colorCancel.withValues(alpha: 0.1);
      default:
        return Colors.transparent;
    }
  }

  String getStatusTitle(int status, BuildContext context) {
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

    return ClipRRect(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                    fillColor:
                                        WidgetStateProperty.resolveWith(
                                      (states) {
                                        if (states.contains(
                                            WidgetState.selected)) {
                                          return AppColors.mainPrimaryColor6;
                                        }
                                        return Colors.transparent;
                                      },
                                    ),
                                    checkColor: WidgetStateProperty.all(
                                      Colors.white,
                                    ),
                                    side: const BorderSide(
                                      color: Colors.grey,
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
                                style: TextStyle(
                                  fontSize: 14,
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
                          S.of(context).bt_card_total,
                          "${entity.employeeCount ?? 0}",
                        ),
                        const SizedBox(height: 12),
                        _buildItem(
                          S.of(context).bt_card_notes,
                          entity.note ?? "",
                        ),
                        const SizedBox(height: 12),
                        _buildItem(
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
