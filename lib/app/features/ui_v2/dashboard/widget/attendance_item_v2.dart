import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';

/// Bản v2 (dark) của `AttendanceItem`
/// (lib/app/features/ui/dashboard/widgets/attendance_data_item.dart).
/// Cùng contract dữ liệu — chỉ đổi nền để đọc được trên nền tối
/// (bản gốc dùng nền màu pastel sáng theo [background], v2 dùng
/// [surfaceStrong] chung + dải màu [color] để phân biệt loại mục).
class AttendanceItemV2 extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final double borderRadius;
  final double stripeWidth;

  const AttendanceItemV2({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    this.borderRadius = 16,
    this.stripeWidth = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTokensV2.surfaceStrong,
          border: Border.all(color: AppTokensV2.border),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: stripeWidth,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    bottomLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius * 0.66),
                    bottomRight: Radius.circular(borderRadius * 0.66),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTokensV2.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
