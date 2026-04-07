import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/request_summary_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';

import '../cubit/dashboard_cubit.dart';

class WorkStatusCard extends StatelessWidget {
  final ValueChanged<String>? onTap;

  const WorkStatusCard({
    super.key,
    this.onTap,
  });

  static const Map<String, List<String>> _keyAliases = {
    'leave': ['leave', 'hr_leave'],
    'overtime': ['overtime', 'ot'],
    'late_early': ['late_early', 'late_soon', 'attendance_exception'],
    'onsite': ['onsite', 'business_trip', 'going_on_business'],
    'wfh': ['wfh', 'work_from_home', 'working_from_home'],
  };

  static const Map<String, Color> _badgeBgColors = {
    'leave': Color(0xFFEAF1FF),
    'overtime': Color(0xFFFFF0E7),
    'late_early': Color(0xFFF3EAFD),
    'onsite': Color(0xFFE8F8EC),
    'wfh': Color(0xFFEAF8FF),
  };

  static const Map<String, Color> _badgeFgColors = {
    'leave': Color(0xFF4A7CFF),
    'overtime': Color(0xFFFF8A4C),
    'late_early': Color(0xFFB84AE6),
    'onsite': Color(0xFF21C24A),
    'wfh': Color(0xFF20B8DD),
  };

  RequestSummaryEntity? _find(List<RequestSummaryEntity> list, String key) {
    try {
      final aliases = _keyAliases[key] ?? [key];
      return list.firstWhere((e) {
        final normalized = (e.key ?? '').trim().toLowerCase();
        return aliases.contains(normalized);
      });
    } catch (_) {
      return null;
    }
  }

  String _defaultLabel(String key) {
    switch (key) {
      case 'leave':
        return 'Đơn nghỉ phép';
      case 'overtime':
        return 'Đơn xin OT';
      case 'late_early':
        return 'Đơn muộn/sớm';
      case 'onsite':
        return 'Đơn Onsite';
      case 'wfh':
        return 'Đơn WFH';
      default:
        return 'Đơn';
    }
  }

  String _iconForKey(String key) {
    switch (key) {
      case 'leave':
        return AppAssets.icCalendar2;
      case 'overtime':
        return AppAssets.icClock;
      case 'late_early':
        return AppAssets.icClock2;
      case 'onsite':
        return AppAssets.icWork;
      case 'wfh':
        return AppAssets.icHome;
      default:
        return AppAssets.icCalendar2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final list = state.requestSummaries;
        final isLoading = state.requestStatus == LoadStatus.LOADING;
        final keysOrder = const ['leave', 'overtime', 'late_early', 'onsite'];
        final wfhItem = _find(list, 'wfh');

        return Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.02,
              children: keysOrder.map((key) {
                final item = _find(list, key);

                return _itemCard(
                  title: item?.label ?? _defaultLabel(key),
                  value: item?.count ?? 0,
                  icon: _iconForKey(key),
                  badgeBgColor: _badgeBgColors[key] ?? const Color(0xFFF3F4F6),
                  badgeFgColor: _badgeFgColors[key] ?? const Color(0xFF6B7280),
                  isLoading: isLoading && item == null,
                  onTap: () => onTap?.call(key),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _horizontalItemCard(
              title: wfhItem?.label ?? _defaultLabel('wfh'),
              value: wfhItem?.count ?? 0,
              icon: _iconForKey('wfh'),
              badgeBgColor: _badgeBgColors['wfh'] ?? const Color(0xFFF3F4F6),
              badgeFgColor: _badgeFgColors['wfh'] ?? const Color(0xFF6B7280),
              isLoading: isLoading && wfhItem == null,
              onTap: () => onTap?.call('wfh'),
            ),
          ],
        );
      },
    );
  }
}

String _formatCount(int? value) {
  final count = value ?? 0;
  if (count < 10) return count.toString().padLeft(2, '0');
  return count.toString();
}

Widget _itemCard({
  required String title,
  required int value,
  required String icon,
  required Color badgeBgColor,
  required Color badgeFgColor,
  bool isLoading = false,
  VoidCallback? onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  badgeFgColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              color: Color(0xFF7A8493),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF5B6B7C),
              ),
            )
          else
            Text(
              _formatCount(value),
              style: const TextStyle(
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Color(0xFF232A36),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _horizontalItemCard({
  required String title,
  required int value,
  required String icon,
  required Color badgeBgColor,
  required Color badgeFgColor,
  bool isLoading = false,
  VoidCallback? onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  badgeFgColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF616B7A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF5B6B7C),
              ),
            )
          else
            Text(
              _formatCount(value),
              style: const TextStyle(
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Color(0xFF232A36),
              ),
            ),
        ],
      ),
    ),
  );
}
