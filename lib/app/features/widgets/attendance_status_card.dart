import 'package:flutter/material.dart';
import '../../core/commons/app_colors.dart';

class AttendanceStatusCard extends StatelessWidget {
  final String dateText;
  final String checkInTime;
  final String checkOutTime;
  final String checkInStatus;
  final String checkOutStatus;

  const AttendanceStatusCard({
    super.key,
    required this.dateText,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInStatus,
    required this.checkOutStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hôm nay",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.searchText,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            dateText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.themeBlackDefault,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(child: _buildCheckIn()),
                Container(
                  width: 1,
                  height: 65,
                  color: Colors.grey.withOpacity(0.25),
                ),
                Expanded(child: _buildCheckOut()),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildCheckIn() {
  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Check In",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.themeBlackDefault,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          checkInTime,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
        ),

        const SizedBox(height: 10),

        IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Text(
                checkInStatus,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0EB200),
                ),
              ),
            ),
          ),
        )
      ],
    ),
  );
}


  Widget _buildCheckOut() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Check Out",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.themeBlackDefault,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          checkOutTime,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
        ),

        const SizedBox(height: 10),

        IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
            width: 130,
            decoration: BoxDecoration(
              color: const Color(0xFF007BFF),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                checkOutStatus,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
