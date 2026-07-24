import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui_v2/notification/noti_page_v2.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_fx_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/ui/application/application_page.dart';
import 'package:pm_app/app/features/ui/home/home_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_page.dart';
import 'package:pm_app/app/features/ui_v2/home/work_time_v2.dart';
import 'package:pm_app/app/features/ui/task/task_manage_page.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_page.dart';

class HomePageV2 extends StatefulWidget {
  const HomePageV2({super.key});
  @override
  State<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2> {
  final HomeCubit _cubit = GetIt.I.get<HomeCubit>();

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _cubit.getListAttendanceToday();
    _cubit.getListNewTasks();
    // Đếm ngược "còn bao lâu đủ giờ" cập nhật mỗi phút.
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// "2026-07-24 08:02:15" -> "08:02"; không parse được -> "--:--"
  String _fmtTime(String? raw) {
    final d = AppDateUtils.parseFlexibleDate(raw);
    if (d == null) return '--:--';
    return DateFormat('HH:mm').format(d);
  }

  /// Ngày hôm nay dạng gọn: "T5, 24/07"
  String _todayShort() {
    final n = DateTime.now();
    const wd = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return '${wd[n.weekday - 1]}, ${DateFormat('dd/MM').format(n)}';
  }

  String get _name => GlobalData.instance.userProfile?.name ?? '';
  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTokensV2.bgDeep,
        body: AmbientBackgroundV2(
          child: SafeArea(
            bottom: false,
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                  children: [
                    StaggerRevealV2(index: 0, child: _header()),
                    const SizedBox(height: 16),
                    StaggerRevealV2(index: 1, child: _hero(state)),
                    const SizedBox(height: 22),
                    StaggerRevealV2(index: 2, child: _utilities()),
                    const SizedBox(height: 22),
                    StaggerRevealV2(index: 3, child: _tasks(state)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _initialsBox() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: AppTokensV2.accentGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppTokensV2.glow,
              blurRadius: 18,
              offset: const Offset(0, 6))
        ],
      ),
      alignment: Alignment.center,
      child: Text(_initials,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800)),
    );
  }

  Widget _avatar() {
    final raw = GlobalData.instance.userProfile?.avatarUrl?.trim();
    final uri = (raw == null || raw.isEmpty) ? null : Uri.tryParse(raw);
    final valid = uri != null && uri.hasScheme && uri.host.isNotEmpty;
    if (!valid) return _initialsBox();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: raw!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        placeholder: (_, __) => _initialsBox(),
        errorWidget: (_, __, ___) => _initialsBox(),
      ),
    );
  }

  Widget _bell() {
    return BlocBuilder<NotiCubit, NotiState>(
      buildWhen: (p, c) => p.totalUnread != c.totalUnread,
      builder: (context, s) {
        final unread = s.totalUnread;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationPageV2())),
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppTokensV2.border),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  color: AppTokensV2.fg, size: 20),
            ),
            if (unread > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: BoxDecoration(
                    color: AppTokensV2.danger,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTokensV2.bgDeep, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ]),
        );
      },
    );
  }

  Widget _header() {
    return Row(children: [
      _avatar(),
      const SizedBox(width: 12),
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Xin chào, $_name',
            style: AppTokensV2.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 1),
        const TypewriterTextV2('Cố gắng hết mình hôm nay nhé!',
            style: AppTokensV2.caption),
      ])),
      _bell(),
    ]);
  }

  Widget _hero(HomeState state) {
    final checkIn = _fmtTime(state.checkInToday);
    final checkOut = _fmtTime(state.checkOutToday);
    final checkedIn = checkIn != '--:--';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokensV2.radius),
        boxShadow: [
          BoxShadow(
              color: AppTokensV2.glow,
              blurRadius: 30,
              offset: const Offset(0, 14)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokensV2.radius),
        child: Stack(children: [
          GlassCardV2(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hôm nay · ${_todayShort()}', style: AppTokensV2.captionStrong),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _timeCol('Chấm Công Vào', checkIn,
                        checkedIn ? 'Đã chấm' : 'Chưa chấm', checkedIn)),
                Container(width: 1, height: 40, color: AppTokensV2.border),
                const SizedBox(width: 12),
                Expanded(
                    child: _timeCol(
                        'Chấm Công Ra',
                        checkOut,
                        checkOut != '--:--' ? 'Đã chấm' : 'Chưa chấm',
                        checkOut != '--:--')),
              ]),
              _workProgress(state),
              const SizedBox(height: 15),
              PrimaryButtonV2(
                label: checkedIn ? 'Chấm công ra' : 'Chấm công vào',
                onTap: () =>
                    GlobalData.instance.bottomNavIndex.value = 2, // tab Chấm công
              ),
            ]),
          ),
          const Positioned.fill(child: ShimmerSweepV2()),
        ]),
      ),
    );
  }

  /// Tiến độ 8 tiếng làm việc: thanh tiến độ + "còn bao lâu nữa đủ giờ".
  Widget _workProgress(HomeState state) {
    final p = computeWorkProgressV2(
      checkIn: AppDateUtils.parseFlexibleDate(state.checkInToday),
      checkOut: AppDateUtils.parseFlexibleDate(state.checkOutToday),
      now: DateTime.now(),
    );
    if (p == null) return const SizedBox.shrink();

    final ratio = (p.worked.inMinutes / WorkRuleV2.requiredWork.inMinutes)
        .clamp(0.0, 1.0)
        .toDouble();
    final outAt = DateFormat('HH:mm').format(p.earliestOut);

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(children: [
            Container(height: 6, color: AppTokensV2.border),
            AnimatedFractionallySizedBox(
              duration: AppTokensV2.dBase,
              curve: AppTokensV2.easeExpo,
              widthFactor: ratio,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: p.done
                      ? const LinearGradient(
                          colors: [AppTokensV2.success, AppTokensV2.success])
                      : AppTokensV2.accentGradient,
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 7),
        Row(children: [
          Icon(p.done ? Icons.check_circle_rounded : Icons.timelapse_rounded,
              size: 13,
              color: p.done ? AppTokensV2.success : AppTokensV2.accent),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              p.done
                  ? 'Đã đủ 8 tiếng — có thể chấm công ra'
                  : 'Còn ${formatDurationShortV2(p.remaining)} nữa đủ giờ',
              style: TextStyle(
                color: p.done ? AppTokensV2.success : AppTokensV2.fg,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('Ra lúc $outAt', style: AppTokensV2.captionStrong),
        ]),
      ]),
    );
  }

  Widget _timeCol(String label, String time, String status, bool ok) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTokensV2.captionStrong.copyWith(fontSize: 10.5)),
      Text(time, style: AppTokensV2.number),
      Row(children: [
        ok
            ? const PulseDotV2(color: AppTokensV2.success, size: 8)
            : const Icon(Icons.schedule, size: 12, color: AppTokensV2.fgSoft),
        const SizedBox(width: 5),
        Text(status,
            style: TextStyle(
                color: ok ? AppTokensV2.success : AppTokensV2.fgSoft,
                fontSize: 10,
                fontWeight: FontWeight.w700)),
      ]),
    ]);
  }

  Widget _utilities() {
    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.people_alt_outlined,
        'Nhân viên',
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => StaffPage(isFromHome: true))),
      ),
      (
        Icons.description_outlined,
        'Dữ liệu công',
        () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AttendanceDataPage())),
      ),
      (
        Icons.event_available_outlined,
        'Nghỉ phép',
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => OnLeavePage(isFromHome: true))),
      ),
      (
        Icons.fingerprint,
        'Chấm công',
        () => GlobalData.instance.bottomNavIndex.value = 2,
      ),
      (
        Icons.checklist_rounded,
        'Việc cần làm',
        () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => TaskManagePage())),
      ),
      (
        Icons.assignment_outlined,
        'Đơn từ',
        () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => ApplicationPage())),
      ),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Tiện ích', style: AppTokensV2.section),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 10,
        childAspectRatio: 0.92,
        children: [for (final it in items) _utilTile(it.$1, it.$2, it.$3)],
      ),
    ]);
  }

  Widget _utilTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        GlassCardV2(
          padding: EdgeInsets.zero,
          radius: 17,
          child: SizedBox(
            width: 54,
            height: 54,
            child: Icon(icon, color: AppTokensV2.accent, size: 24),
          ),
        ),
        const SizedBox(height: 7),
        Text(label,
            style: AppTokensV2.caption.copyWith(color: AppTokensV2.fgSoft),
            textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _tasks(HomeState state) {
    final tasks = state.listNewTasks ?? const [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
        Text('Việc cần làm', style: AppTokensV2.section),
        Text('Xem tất cả',
            style: TextStyle(
                color: AppTokensV2.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 12),
      if (tasks.isEmpty)
        GlassCardV2(
          padding: const EdgeInsets.all(20),
          child: Center(
              child: Text('Không có việc cần làm', style: AppTokensV2.caption)),
        )
      else
        for (final t in tasks.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: GlassCardV2(
              padding: const EdgeInsets.all(13),
              child: Row(children: [
                Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                        color: AppTokensV2.accent, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(t.name ?? '—',
                        style: AppTokensV2.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]),
            ),
          ),
    ]);
  }
}
