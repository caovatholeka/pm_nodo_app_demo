import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/request_summary_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';

import '../cubit/dashboard_cubit.dart';

class WorkStatusCard extends StatelessWidget {
  const WorkStatusCard({super.key});

  static const Map<String, List<String>> _keyAliases = {
    'leave': ['leave', 'hr_leave'],
    'overtime': ['overtime', 'ot'],
    'late_early': ['late_early', 'late_soon', 'attendance_exception'],
    'onsite': ['onsite', 'business_trip', 'going_on_business'],
    'wfh': ['wfh', 'work_from_home', 'working_from_home'],
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
        return 'Don nghi phep';
      case 'overtime':
        return 'Don xin OT';
      case 'late_early':
        return 'Don muon/som';
      case 'onsite':
        return 'Don Onsite';
      case 'wfh':
        return 'Don WFH';
      default:
        return 'Don';
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
        final keysOrder = ['leave', 'overtime', 'late_early', 'onsite'];
        final wfhItem = _find(list, 'wfh');

        return Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.25,
              children: keysOrder.map((key) {
                final item = _find(list, key);
                return _itemCard(
                  item?.label ?? _defaultLabel(key),
                  item?.count ?? 0,
                  _iconForKey(key),
                  isLoading: isLoading && item == null,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xffE6F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(AppAssets.icHome, width: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      wfhItem?.label ?? _defaultLabel('wfh'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isLoading && wfhItem == null)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue,),
                    )
                  else
                    Text(
                      "${wfhItem?.count ?? 0}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _itemCard(
  String title,
  int value,
  String icon, {
  bool isLoading = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(icon, width: 30),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
          )
        else
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
      ],
    ),
  );
}
