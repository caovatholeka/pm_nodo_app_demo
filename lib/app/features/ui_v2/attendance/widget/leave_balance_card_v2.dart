import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Bản tối (v2) của [LeaveBalanceCard] — thẻ "Số ngày phép còn lại".
class LeaveBalanceCardV2 extends StatelessWidget {
  final String remainingDays;

  const LeaveBalanceCardV2({
    super.key,
    required this.remainingDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTokensV2.surfaceStrong,
        border: Border.all(color: AppTokensV2.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            S.of(context).work_data_dayLeft,
            style: AppTokensV2.caption,
          ),
          Text(
            remainingDays,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTokensV2.fg,
            ),
          ),
        ],
      ),
    );
  }
}
