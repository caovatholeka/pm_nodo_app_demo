import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/ui/application/application_page.dart';
import 'package:pm_app/app/features/ui/home/home_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/on_leave_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_page.dart';
import 'package:pm_app/app/features/ui/task/task_manage_page.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_page.dart';

class HomePageV2 extends StatefulWidget {
  const HomePageV2({super.key});
  @override
  State<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2> {
  final HomeCubit _cubit = GetIt.I.get<HomeCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getListAttendanceToday();
    _cubit.getListNewTasks();
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

  Widget _header() {
    return Row(children: [
      Container(
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
      ),
      const SizedBox(width: 12),
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Xin chào, $_name',
            style: AppTokensV2.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 1),
        const Text('Cố gắng hết mình hôm nay nhé!', style: AppTokensV2.caption),
      ])),
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
    ]);
  }

  Widget _hero(HomeState state) {
    final checkIn = (state.checkInToday?.isNotEmpty ?? false)
        ? state.checkInToday!
        : '--:--';
    final checkOut = (state.checkOutToday?.isNotEmpty ?? false)
        ? state.checkOutToday!
        : '--:--';
    final checkedIn = checkIn != '--:--';
    return GlassCardV2(
      gradient: AppTokensV2.accentGradient,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Hôm nay',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _timeCol('Chấm Công Vào', checkIn,
                  checkedIn ? 'Đã chấm' : 'Chưa chấm', checkedIn)),
          Container(width: 1, height: 40, color: Colors.white24),
          const SizedBox(width: 12),
          Expanded(
              child: _timeCol(
                  'Chấm Công Ra',
                  checkOut,
                  checkOut != '--:--' ? 'Đã chấm' : 'Chưa chấm',
                  checkOut != '--:--')),
        ]),
        const SizedBox(height: 15),
        PrimaryButtonV2(
          label: checkedIn ? 'Chấm công ra' : 'Chấm công vào',
          onTap: () => GlobalData.instance.bottomNavIndex.value = 2, // tab Chấm công
        ),
      ]),
    );
  }

  Widget _timeCol(String label, String time, String status, bool ok) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
      Text(time, style: AppTokensV2.number.copyWith(color: Colors.white)),
      Row(children: [
        Icon(ok ? Icons.check_circle : Icons.schedule,
            size: 12, color: ok ? AppTokensV2.success : Colors.white54),
        const SizedBox(width: 4),
        Text(status,
            style: TextStyle(
                color: ok ? AppTokensV2.success : Colors.white54,
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
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppTokensV2.surface,
            border: Border.all(color: AppTokensV2.border),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(icon, color: AppTokensV2.accent, size: 24),
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
