import 'package:flutter/material.dart';

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

  bool _isDone(String status) {
    return status.toLowerCase() != "not yet";
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hôm nay",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: w * 0.035,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Text(
            dateText,
            style: TextStyle(
              fontSize: w * 0.055,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildItem(
                    title: "Check In",
                    time: checkInTime,
                    status: checkInStatus,
                    isDone: _isDone(checkInStatus),
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.grey.withOpacity(0.4),
                  margin: EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: _buildItem(
                    title: "Check Out",
                    time: checkOutTime,
                    status: checkOutStatus,
                    isDone: _isDone(checkOutStatus),
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
  }) {
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
        SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isDone ? Colors.white : Colors.blue,
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                isDone
                    ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.15),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ]
                    : [],
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDone ? Colors.green : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
