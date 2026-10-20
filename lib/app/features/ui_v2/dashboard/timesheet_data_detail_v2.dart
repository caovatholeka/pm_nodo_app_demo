import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/entities/items_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/attendance_item_v2.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/month_picker_sheet_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn "Dữ liệu công cụ chấm công" — chi tiết Dashboard, giao diện tối (v2).
///
/// Bản gốc: `lib/app/features/ui/dashboard/timesheet_data_detail.dart`.
/// Giữ nguyên [DashboardCubit] qua GetIt, cùng lời gọi
/// `getTimeSheetData(month)` (postFrameCallback + khi đổi tháng) và cùng
/// logic build tiêu đề/màu theo loại mục (`_buildTitle`/`_resolveStyle`).
class TimesheetDataDetailV2 extends StatefulWidget {
  const TimesheetDataDetailV2({super.key});

  @override
  State<TimesheetDataDetailV2> createState() => _TimesheetDataDetailV2State();
}

class _TimesheetDataDetailV2State extends State<TimesheetDataDetailV2> {
  final _cubit = GetIt.I.get<DashboardCubit>();
  int _selectedMonth = DateTime.now().month;

  DateTime get _selectedDate => DateTime(DateTime.now().year, _selectedMonth);

  String _monthLabel(BuildContext context) =>
      '${S.of(context).month} ${DateFormat('MM/yyyy').format(_selectedDate)}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.getTimeSheetData(_selectedMonth);
    });
  }

  void _goNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.I<NotiCubit>()..loadNotifications('all'),
          child: const NotificationPage(),
        ),
      ),
    );
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPickerV2(context, initialMonth: _selectedMonth);
    if (picked == null || !mounted) return;
    setState(() => _selectedMonth = picked);
    _cubit.getTimeSheetData(picked);
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

    if (title.contains('(') && title.contains(')')) {
      return title;
    }

    return s.appraisal_occurrence_count(title, count);
  }

  Color _resolveColor(ItemsEntity item) {
    final normalizedTitle = (item.title ?? '').trim().toLowerCase();

    if (normalizedTitle.contains('quên chấm')) {
      return AppTokensV2.danger;
    }
    if (normalizedTitle.contains('muộn') || normalizedTitle.contains('sớm')) {
      return AppTokensV2.warn;
    }
    if (normalizedTitle.contains('nghỉ không lương')) {
      return AppTokensV2.danger;
    }
    if (normalizedTitle.contains('nghỉ phép')) {
      return AppTokensV2.accent;
    }
    if (normalizedTitle.contains('thiếu giờ')) {
      return AppTokensV2.accent2;
    }

    final normalized = (item.type ?? '').trim().toLowerCase();

    switch (normalized) {
      case 'missing_attendance':
      case 'missing_check_in':
      case 'missing_checkin':
      case 'forgot_check_in':
      case 'forgot_checkout':
      case 'missing_checkout':
        return AppTokensV2.danger;
      case 'late_early':
      case 'late':
      case 'early':
        return AppTokensV2.warn;
      case 'leave':
      case 'paid_leave':
        return AppTokensV2.accent;
      case 'missing_hours':
      case 'missing_time':
        return AppTokensV2.accent2;
      case 'unpaid_leave':
        return AppTokensV2.danger;
      default:
        return AppTokensV2.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        backgroundColor: AppTokensV2.bgDeep,
        body: AmbientBackgroundV2(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: StaggerRevealV2(index: 0, child: _topBar(s)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StaggerRevealV2(index: 1, child: _monthSelector(s)),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: StaggerRevealV2(
                      index: 2,
                      child: GlassCardV2(
                        padding: const EdgeInsets.all(12),
                        child: BlocBuilder<DashboardCubit, DashboardState>(
                          buildWhen: (previous, current) =>
                              previous.timesheetStatus !=
                                  current.timesheetStatus ||
                              previous.timesheet != current.timesheet,
                          builder: (context, state) {
                            final items =
                                state.timesheet?.items ?? const <ItemsEntity>[];

                            if (state.timesheetStatus == LoadStatus.LOADING) {
                              return Center(
                                child: CircularProgressIndicator(
                                    color: AppTokensV2.accent,
                                    strokeWidth: 2.2),
                              );
                            }

                            if (state.timesheetStatus == LoadStatus.FAILURE) {
                              return _statusCard(
                                s.appraisal_timesheet_load_failed,
                                AppTokensV2.danger,
                              );
                            }

                            if (items.isEmpty) {
                              return _statusCard(
                                s.appraisal_timesheet_empty,
                                AppTokensV2.fgMuted,
                              );
                            }

                            return ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, index) {
                                final item = items[index];
                                final color = _resolveColor(item);
                                final title = _buildTitle(item, s);
                                final subtitle =
                                    item.description?.trim().isNotEmpty == true
                                        ? item.description!.trim()
                                        : s.appraisal_no_description;

                                return AttendanceItemV2(
                                  title: title,
                                  subtitle: subtitle,
                                  color: color,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(S s) {
    return Row(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          s.appraisal_timesheet_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNotification,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            border: Border.all(color: AppTokensV2.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.notifications_none_rounded,
              size: 19, color: AppTokensV2.fgSoft),
        ),
      ),
    ]);
  }

  Widget _monthSelector(S s) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickMonth,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppTokensV2.surfaceStrong,
          border: Border.all(color: AppTokensV2.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 16, color: AppTokensV2.fgMuted),
            const SizedBox(width: 10),
            Text(_monthLabel(context), style: AppTokensV2.body),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 22, color: AppTokensV2.fgMuted),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(String message, Color textColor) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppTokensV2.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTokensV2.border),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTokensV2.captionStrong.copyWith(color: textColor),
        ),
      ),
    );
  }
}
