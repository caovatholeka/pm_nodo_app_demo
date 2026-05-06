import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/generated/l10n.dart';

class AttendanceStatusCard extends StatelessWidget {
  final String dateText;
  final String checkInTime;
  final String checkOutTime;
  final String checkInStatus;
  final String checkOutStatus;
  final VoidCallback? onCheckOutTap;

  const AttendanceStatusCard({
    super.key,
    required this.dateText,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInStatus,
    required this.checkOutStatus,
    this.onCheckOutTap,
  });

  bool _isDone(String status) {
    final normalized = status.toLowerCase().trim();
    return normalized != 'not yet' &&
        normalized != 'chua cham' &&
        normalized != 'chưa chấm';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final s = S.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.attendance_card1,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: width * 0.035,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dateText,
            style: TextStyle(
              fontSize: width * 0.055,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildItem(
                    title: s.attendance_card_status1,
                    time: checkInTime,
                    status: checkInStatus,
                    isDone: _isDone(checkInStatus),
                    onTap: onCheckOutTap,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.grey.withValues(alpha: 0.4),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: _buildItem(
                    title: s.attendance_card_status2,
                    time: checkOutTime,
                    status: checkOutStatus,
                    isDone: _isDone(checkOutStatus),
                    onTap: onCheckOutTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String title,
    required String time,
    required String status,
    required bool isDone,
    VoidCallback? onTap,
  }) {
    final backgroundColor =
        isDone ? Colors.white : AppColors.themePrimaryDefault;
    final borderColor =
        isDone ? Colors.transparent : AppColors.themePrimaryDefault;
    final textColor = isDone ? Colors.green : Colors.white;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: isDone ? null : onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: borderColor),
                boxShadow:
                    isDone
                        ? [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: AppColors.themePrimaryDefault.withValues(
                              alpha: 0.22,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
