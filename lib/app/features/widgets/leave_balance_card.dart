import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';

class LeaveBalanceCard extends StatelessWidget {
  final String remainingDays;

  const LeaveBalanceCard({
    super.key,
    required this.remainingDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: AppShadow.boxShadowNormal,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Số phép còn lại',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGrayB3,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            remainingDays,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
