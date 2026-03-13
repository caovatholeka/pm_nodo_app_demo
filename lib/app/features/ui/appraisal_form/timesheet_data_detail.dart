import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/items_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/attendance_data_item.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

class TimesheetDataDetail extends StatefulWidget {
  const TimesheetDataDetail({super.key});

  @override
  State<TimesheetDataDetail> createState() => _TimesheetDataDetailState();
}

class _TimesheetDataDetailState extends State<TimesheetDataDetail> {
  int _selectedMonth = DateTime.now().month;

  String get _monthLabel =>
      'Tháng ${_selectedMonth.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().getTimeSheetData(_selectedMonth);
    });
  }

  void _pickMonth() {
    int tempMonth = _selectedMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMonth = tempMonth;
                        });

                        context
                            .read<DashboardCubit>()
                            .getTimeSheetData(tempMonth);

                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Xong',
                        style: TextStyle(
                          color: Color(0xFF2E87FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: tempMonth - 1,
                  ),
                  onSelectedItemChanged: (index) {
                    tempMonth = index + 1;
                  },
                  children: List.generate(
                    12,
                    (i) => Center(
                      child: Text(
                        'Tháng ${(i + 1).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildTitle(ItemsEntity item) {
    final title = item.title?.trim();
    final count = item.count;

    if (title == null || title.isEmpty) {
      return count == null ? '--' : 'Mục $count';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: const MyAppBar(
        titleAppbar: 'Dữ liệu chấm công',
        haveBackButton: true,
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.appBG2, 
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMonthSelector(),
                  const SizedBox(height: 16),

                  Expanded(
                    child: BlocBuilder<DashboardCubit, DashboardState>(
                      buildWhen: (p, c) =>
                          p.timesheetStatus != c.timesheetStatus ||
                          p.timesheet != c.timesheet,
                      builder: (context, state) {
                        final items =
                            state.timesheet?.items ?? const <ItemsEntity>[];

                        if (state.timesheetStatus == LoadStatus.LOADING) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state.timesheetStatus == LoadStatus.FAILURE) {
                          return const Center(
                            child: Text(
                              'Không tải được dữ liệu chấm công',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (items.isEmpty) {
                          return const Center(
                            child: Text('Không có dữ liệu chấm công'),
                          );
                        }

                        return ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, index) {
                            final item = items[index];
                            final style = _resolveStyle(item.type);
                            final title = _buildTitle(item);

                            final subtitle =
                                item.description?.trim().isNotEmpty == true
                                    ? item.description!.trim()
                                    : 'Không có mô tả';

                            return AttendanceItem(
                              title: title,
                              subtitle: subtitle,
                              color: style.foreground,
                              background: style.background,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _pickMonth,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              AppAssets.icCalendar,
              width: 14,
              height: 14,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _monthLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ],
        ),
      ),
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