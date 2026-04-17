import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/items_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/attendance_data_item.dart';
import 'package:pm_app/generated/l10n.dart';

class AttendanceData extends StatelessWidget {
  final VoidCallback? onTap;

  const AttendanceData({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen:
            (previous, current) =>
                previous.timesheetStatus != current.timesheetStatus ||
                previous.timesheet != current.timesheet,
        builder: (context, state) {
          final items = state.timesheet?.items ?? const <ItemsEntity>[];

          return Column(
            children: [
              _Header(onTap: onTap),
              const SizedBox(height: 16),
              if (state.timesheetStatus == LoadStatus.LOADING)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.timesheetStatus == LoadStatus.FAILURE)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      s.appraisal_timesheet_load_failed,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(s.appraisal_timesheet_empty),
                  ),
                )
              else
                ..._buildItems(items, s),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildItems(List<ItemsEntity> items, S s) {
    return List.generate(items.length, (index) {
      final item = items[index];
      final style = _resolveStyle(item.type);
      final title = _buildTitle(item, s);
      final subtitle =
          item.description?.trim().isNotEmpty == true
              ? item.description!.trim()
              : s.appraisal_no_description;

      return Padding(
        padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 10),
        child: AttendanceItem(
          title: title,
          subtitle: subtitle,
          color: style.foreground,
          background: style.background,
        ),
      );
    });
  }

  String _buildTitle(ItemsEntity item, S s) {
    final title = item.title?.trim();
    final count = item.count;

    if (title == null || title.isEmpty) {
      return count == null ? '--' : s.appraisal_item_count(count);
    }

    if (count == null) {
      return title;
    }

    return s.appraisal_occurrence_count(title, count);
  }

  _AttendanceStyle _resolveStyle(String? type) {
    final normalized = (type ?? '').trim().toLowerCase();

    switch (normalized) {
      case 'missing_attendance':
      case 'missing_check_in':
      case 'missing_checkin':
      case 'forgot_check_in':
      case 'forgot_checkout':
      case 'missing_checkout':
        return const _AttendanceStyle(
          foreground: Color(0xFFFF3B30),
          background: Color(0xFFFCEAEA),
        );
      case 'late_early':
      case 'late':
      case 'early':
        return const _AttendanceStyle(
          foreground: Color(0xFFE91E63),
          background: Color(0xFFF3E5F5),
        );
      case 'leave':
      case 'paid_leave':
        return const _AttendanceStyle(
          foreground: Color(0xFFFF9800),
          background: Color(0xFFFFF3E0),
        );
      case 'missing_hours':
      case 'missing_time':
        return const _AttendanceStyle(
          foreground: Color(0xFF1E6BFF),
          background: Color(0xFFEAF2FF),
        );
      case 'unpaid_leave':
        return const _AttendanceStyle(
          foreground: Color(0xFFE91E63),
          background: Color(0xFFF8E6F3),
        );
      default:
        return const _AttendanceStyle(
          foreground: Color(0xFF0F766E),
          background: Color(0xFFECFDF5),
        );
    }
  }
}

class _Header extends StatelessWidget {
  final VoidCallback? onTap;

  const _Header({this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

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
        Expanded(
          child: Text(
            s.appraisal_timesheet_title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            s.to_do_all,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceStyle {
  final Color foreground;
  final Color background;

  const _AttendanceStyle({
    required this.foreground,
    required this.background,
  });
}
