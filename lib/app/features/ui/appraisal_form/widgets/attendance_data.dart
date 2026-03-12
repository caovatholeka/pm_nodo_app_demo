import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/items_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/attendance_data_item.dart';

class AttendanceData extends StatelessWidget {
  final VoidCallback? onTap;

  const AttendanceData({
    super.key,
    this.onTap,
  });

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
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Khong tai duoc du lieu cham cong',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Khong co du lieu cham cong trong thang nay'),
                  ),
                )
              else
                ..._buildItems(items),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildItems(List<ItemsEntity> items) {
    return List.generate(items.length, (index) {
      final item = items[index];
      final style = _resolveStyle(item.type);
      final title = _buildTitle(item);
      final subtitle = item.description?.trim().isNotEmpty == true
          ? item.description!.trim()
          : 'Khong co mo ta';

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

  String _buildTitle(ItemsEntity item) {
    final title = item.title?.trim();
    final count = item.count;

    if (title == null || title.isEmpty) {
      return count == null ? '--' : 'Muc $count';
    }

    if (count == null) {
      return title;
    }

    return '$title ($count)';
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
            'Dữ liệu chấm công',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
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