import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/items_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/attendance_data_item.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

class TimesheetDataDetail extends StatefulWidget {
  const TimesheetDataDetail({super.key});

  @override
  State<TimesheetDataDetail> createState() => _TimesheetDataDetailState();
}

class _TimesheetDataDetailState extends State<TimesheetDataDetail> {
  int _selectedMonth = DateTime.now().month;

  DateTime get _selectedDate => DateTime(DateTime.now().year, _selectedMonth);

  String get _monthLabel =>
      DateFormat("'Tháng' MM/yyyy", 'vi_VN').format(_selectedDate);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().getTimeSheetData(_selectedMonth);
    });
  }

  void _goNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create: (_) => GetIt.I<NotiCubit>()..loadNotifications('all'),
              child: const NotificationPage(),
            ),
      ),
    );
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
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMonth = tempMonth;
                        });

                        context.read<DashboardCubit>().getTimeSheetData(
                          tempMonth,
                        );
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

    if (title.contains('(') && title.contains(')')) {
      return title;
    }

    return '$title ($count lần)';
  }

  _AttendanceStyle _resolveStyle(ItemsEntity item) {
    final normalizedTitle = (item.title ?? '').trim().toLowerCase();

    if (normalizedTitle.contains('quên chấm')) {
      return const _AttendanceStyle(
        foreground: Color(0xFFFF3B30),
        background: Color(0xFFFFF0EF),
      );
    }

    if (normalizedTitle.contains('muộn') || normalizedTitle.contains('sớm')) {
      return const _AttendanceStyle(
        foreground: Color(0xFFE93FC8),
        background: Color(0xFFF9EAFE),
      );
    }

    if (normalizedTitle.contains('nghỉ không lương')) {
      return const _AttendanceStyle(
        foreground: Color(0xFFE91EBC),
        background: Color(0xFFFCEEF9),
      );
    }

    if (normalizedTitle.contains('nghỉ phép')) {
      return const _AttendanceStyle(
        foreground: Color(0xFFFFA000),
        background: Color(0xFFFFF8E8),
      );
    }

    if (normalizedTitle.contains('thiếu giờ')) {
      return const _AttendanceStyle(
        foreground: Color(0xFF1E6BFF),
        background: Color(0xFFEFF4FF),
      );
    }

    final normalized = (item.type ?? '').trim().toLowerCase();

    switch (normalized) {
      case 'missing_attendance':
      case 'missing_check_in':
      case 'missing_checkin':
      case 'forgot_check_in':
      case 'forgot_checkout':
      case 'missing_checkout':
        return const _AttendanceStyle(
          foreground: Color(0xFFFF3B30),
          background: Color(0xFFFFF0EF),
        );
      case 'late_early':
      case 'late':
      case 'early':
        return const _AttendanceStyle(
          foreground: Color(0xFFE93FC8),
          background: Color(0xFFF9EAFE),
        );
      case 'leave':
      case 'paid_leave':
        return const _AttendanceStyle(
          foreground: Color(0xFFFFA000),
          background: Color(0xFFFFF8E8),
        );
      case 'missing_hours':
      case 'missing_time':
        return const _AttendanceStyle(
          foreground: Color(0xFF1E6BFF),
          background: Color(0xFFEFF4FF),
        );
      case 'unpaid_leave':
        return const _AttendanceStyle(
          foreground: Color(0xFFE91EBC),
          background: Color(0xFFFCEEF9),
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
      appBar: MyAppBar(
        titleAppbar: 'Dữ liệu chấm công',
        haveBackButton: true,
        haveActionButton: true,
        iconPathAsset: AppAssets.icNotificationBell,
        actionCallBack: _goNotification,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: BlocBuilder<DashboardCubit, DashboardState>(
                  buildWhen:
                      (previous, current) =>
                          previous.timesheetStatus != current.timesheetStatus ||
                          previous.timesheet != current.timesheet,
                  builder: (context, state) {
                    final items =
                        state.timesheet?.items ?? const <ItemsEntity>[];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _TimesheetHeader(),
                        const SizedBox(height: 18),
                        _MonthSelector(label: _monthLabel, onTap: _pickMonth),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (state.timesheetStatus == LoadStatus.LOADING) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (state.timesheetStatus == LoadStatus.FAILURE) {
                                return const _TimesheetStatusCard(
                                  message: 'Không tải được dữ liệu chấm công',
                                  textColor: Color(0xFFE53935),
                                );
                              }

                              if (items.isEmpty) {
                                return const _TimesheetStatusCard(
                                  message:
                                      'Không có dữ liệu chấm công trong tháng này',
                                  textColor: Color(0xFF6B7280),
                                );
                              }

                              return ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: items.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 12),
                                itemBuilder: (_, index) {
                                  final item = items[index];
                                  final style = _resolveStyle(item);
                                  final title = _buildTitle(item);
                                  final subtitle =
                                      item.description?.trim().isNotEmpty ==
                                              true
                                          ? item.description!.trim()
                                          : 'Không có mô tả';

                                  return AttendanceItem(
                                    title: title,
                                    subtitle: subtitle,
                                    color: style.foreground,
                                    background: style.background,
                                    curvedStripe: true,
                                    borderRadius: 16,
                                    stripeWidth: 6,
                                    stripeInset: 0,
                                    padding: const EdgeInsets.fromLTRB(
                                      22,
                                      14,
                                      18,
                                      14,
                                    ),
                                    titleFontWeight: FontWeight.w700,
                                    subtitleFontWeight: FontWeight.w500,
                                    subtitleOpacity: 0.72,
                                    titleHeight: 1.25,
                                    subtitleHeight: 1.35,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MonthSelector({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SvgPicture.asset(AppAssets.icCalendar, width: 18, height: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: Color(0xFF4B5563),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimesheetHeader extends StatelessWidget {
  const _TimesheetHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4DE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.access_time_rounded,
            color: Color(0xFFFFA000),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Dữ liệu chấm công',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimesheetStatusCard extends StatelessWidget {
  final String message;
  final Color textColor;

  const _TimesheetStatusCard({required this.message, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _AttendanceStyle {
  final Color foreground;
  final Color background;

  const _AttendanceStyle({required this.foreground, required this.background});
}
