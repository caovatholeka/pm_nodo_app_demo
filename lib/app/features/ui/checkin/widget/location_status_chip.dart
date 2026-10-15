import 'package:flutter/material.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../../core/commons/app_colors.dart';

enum LocationStatus { locating, weakSignal, inRange, outOfRange }

/// Thẻ cho người dùng biết trước khi bấm chấm công: đang định vị / GPS yếu /
/// trong phạm vi / ngoài phạm vi, kèm khoảng cách tới điểm chấm công.
class LocationStatusChip extends StatelessWidget {
  final LocationStatus status;
  final double? distanceMeters;
  final double? accuracyMeters;

  const LocationStatusChip({
    super.key,
    required this.status,
    this.distanceMeters,
    this.accuracyMeters,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final distance = formatDistance(
      distanceMeters ?? 0,
      Localizations.localeOf(context).languageCode,
    );

    final (Color color, IconData icon, String text) = switch (status) {
      LocationStatus.locating => (
          AppColors.neutral600,
          Icons.gps_not_fixed,
          s.check_in_locating,
        ),
      LocationStatus.weakSignal => (
          const Color(0xFFE08A00),
          Icons.gps_off,
          s.check_in_weakGps((accuracyMeters ?? 0).round().toString()),
        ),
      LocationStatus.inRange => (
          AppColors.colorSuccess500,
          Icons.check_circle,
          s.check_in_inRange(distance),
        ),
      LocationStatus.outOfRange => (
          AppColors.colorNoClockIn,
          Icons.error,
          s.check_in_outOfRange(distance),
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          status == LocationStatus.locating
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              : Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 35 m / 1,2 km (tiếng Việt dùng dấu phẩy thập phân).
String formatDistance(double meters, String languageCode) {
  if (meters < 1000) return '${meters.round()} m';
  final km = (meters / 1000).toStringAsFixed(1);
  return '${languageCode == 'vi' ? km.replaceAll('.', ',') : km} km';
}
