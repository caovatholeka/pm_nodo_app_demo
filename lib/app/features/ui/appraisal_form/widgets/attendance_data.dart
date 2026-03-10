import 'package:flutter/material.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/attendance_data_item.dart';

class AttendanceData extends StatelessWidget {
  const AttendanceData({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0,3),
          )
        ],
      ),
      child: Column(
        children: const [

          _Header(),

          SizedBox(height: 16),

          AttendanceItem(
            title: "Quên chấm công (4 lần)",
            subtitle: "Cần bổ sung giải trình trước 15:00",
            color: Color(0xFFFF3B30),
            background: Color(0xFFFCEAEA),
          ),

          SizedBox(height: 10),

          AttendanceItem(
            title: "Muộn/Sớm (2 lần)",
            subtitle: "Tổng thời gian: 45 phút",
            color: Color(0xFFE91E63),
            background: Color(0xFFF3E5F5),
          ),

          SizedBox(height: 10),

          AttendanceItem(
            title: "Nghỉ phép",
            subtitle: "Phiếu yêu cầu nghỉ phép được chấp thuận",
            color: Color(0xFFFF9800),
            background: Color(0xFFFFF3E0),
          ),

          SizedBox(height: 10),

          AttendanceItem(
            title: "Thiếu giờ ra",
            subtitle: "Yêu cầu giải trình",
            color: Color(0xFF1E6BFF),
            background: Color(0xFFEAF2FF),
          ),

          SizedBox(height: 10),

          AttendanceItem(
            title: "Nghỉ không lương",
            subtitle: "Phiếu yêu cầu nghỉ phép được chấp thuận",
            color: Color(0xFFE91E63),
            background: Color(0xFFF8E6F3),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.access_time,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            "Dữ liệu chấm công",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            "Xem tất cả",
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 14,
            ),
          ),
        )
      ],
    );
  }
}