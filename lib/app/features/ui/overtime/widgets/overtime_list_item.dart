import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/generated/l10n.dart';

class OvertimeListItem extends StatelessWidget {
  final OvertimeEntity entity;
  final VoidCallback? onTap;

  final bool canApprove;
  final bool isChecked;
  final ValueChanged<bool?>? onCheckedChange;

  const OvertimeListItem({
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

  Color _getStatusColorByName(String? name) {
    switch (name) {
      case 'Nháp':
        return AppColors.colorDraft;
      case 'Chờ xác nhận':
      case 'Trưởng phòng duyệt':
        return AppColors.colorApproved;
      case 'Hoàn thành':
      case 'Hợp lệ':
        return AppColors.colorFinished;
      case 'Hủy':
      case 'Không hợp lệ':
        return AppColors.colorCancel;
      case 'Đã khóa':
      case 'Khóa kì công':
        return Colors.grey;
      case 'Tính toán công':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getBgColorByName(String? name) {
    return _getStatusColorByName(name).withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final stage = entity.stage;
    final statusName = stage?.name;

    final statusColor = _getStatusColorByName(statusName);
    final bgColor = _getBgColorByName(statusName);

    final dateRangeText =
        _formatDateRange(entity.fromDate, entity.toDate);
    final s = S.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withAlpha(25)),
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
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),

              Expanded(
                child: InkWell(
                  onTap: onTap,
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
                            if (_showCheckbox)
                              Theme(
                                data: Theme.of(context).copyWith(
                                  checkboxTheme: CheckboxThemeData(
                                    fillColor:
                                        WidgetStateProperty.resolveWith(
                                      (states) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return AppColors
                                              .mainPrimaryColor6;
                                        }
                                        return Colors.transparent;
                                      },
                                    ),
                                    checkColor:
                                        WidgetStateProperty.all(
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
                                  visualDensity:
                                      VisualDensity.compact,
                                ),
                              ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
                                    dateRangeText,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius:
                                    BorderRadius.circular(99),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusName ?? '',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight:
                                          FontWeight.w400,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        _buildItem(
                          s.ot_cardCreator,
                          entity.employeeName ?? '',
                        ),
                        const SizedBox(height: 12),
                        _buildItem(
                          s.ot_cardNote,
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

  Widget _buildItem(String title, String value, {int? maxLines}) {
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
            maxLines: maxLines,
            overflow:
                maxLines != null ? TextOverflow.ellipsis : null,
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
