import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/service/local_notification_service.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui_v2/notification/noti_page_v2.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/features/ui/home/home_cubit.dart';
import 'package:pm_app/app/features/ui_v2/application/application_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/attendance/attendance_data_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/home/work_time_v2.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/entities/shift_of_day_entity.dart';
import 'package:pm_app/app/features/ui_v2/task/task_detail_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/staff/staff_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/on_leave/on_leave_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/task/task_manage_page_v2.dart';

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
    _cubit.loadHomeTaskStages(); // tab Mới / Đang thực hiện / Hoàn thành / Từ chối
    _cubit.getShiftToday();
    // Như Home v1: cập nhật số thông báo chưa đọc mỗi lần vào Home.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotiCubit>().countUnreadNoti();
    });
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

  Future<void> _onRefresh() async {
    await Future.wait([
      _cubit.getListAttendanceToday(),
      _cubit.getListNewTasks(),
      _cubit.getShiftToday(),
      context.read<NotiCubit>().countUnreadNoti(),
    ]);
  }

  Future<void> _openDetailTask(TaskEntity entity) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailPageV2(taskEntity: entity, taskId: entity.id),
      ),
    );
    if (result == true) _onRefresh();
  }

  /// Mở danh sách việc; quay về thì tải lại "Việc cần làm" (việc vừa tạo/đổi trạng thái).
  Future<void> _openTaskManage() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const TaskManagePageV2()));
    if (mounted) _cubit.getListNewTasks();
  }

  /// Thời điểm đang hẹn nhắc, để không đặt lại lịch trùng lặp mỗi lần state đổi.
  DateTime? _scheduledReminderAt;

  /// Đặt hoặc huỷ lịch nhắc chấm công ra theo trạng thái chấm công hôm nay.
  Future<void> _syncCheckOutReminder(HomeState state) async {
    final checkIn = AppDateUtils.parseFlexibleDate(state.checkInToday);
    final shift = state.shiftToday;
    final at = checkOutReminderAtV2(
      checkIn: checkIn,
      checkOut: AppDateUtils.parseFlexibleDate(state.checkOutToday),
      now: DateTime.now(),
      shiftStart: _progressShiftStart(shift, checkIn),
      shiftEnd: shift?.end,
    );

    if (at == null) {
      if (_scheduledReminderAt != null) {
        _scheduledReminderAt = null;
        await LocalNotificationService.cancelCheckOutReminder();
      }
      return;
    }

    if (_scheduledReminderAt == at) return; // đã hẹn đúng giờ này rồi
    _scheduledReminderAt = at;
    await LocalNotificationService.scheduleCheckOutReminder(
      at: at,
      title: 'Đã đủ 8 tiếng làm việc',
      body: 'Bấm để mở app và chấm công ra.',
    );
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
            child: BlocConsumer<HomeCubit, HomeState>(
              listenWhen: (p, c) =>
                  p.checkInToday != c.checkInToday ||
                  p.checkOutToday != c.checkOutToday ||
                  p.shiftToday != c.shiftToday, // ca tải xong sau → tính lại giờ nhắc
              listener: (_, state) => _syncCheckOutReminder(state),
              builder: (context, state) {
                // Kéo xuống để tải lại (như Home v1), kể cả khi nội dung ngắn.
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppTokensV2.accent,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                    children: [
                      _header(),
                      const SizedBox(height: 16),
                      _hero(state),
                      const SizedBox(height: 22),
                      _utilities(),
                      const SizedBox(height: 22),
                      _tasks(state),
                    ],
                  ),
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
              child: Icon(Icons.notifications_none_rounded,
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
        // Chữ tĩnh (trước là hiệu ứng đánh máy + con trỏ nhấp nháy; ký tự con trỏ làm
        // dòng chữ cao/thấp theo nhịp nháy → cả thẻ chấm công bên dưới nhảy lên xuống).
        Text('Cố gắng hết mình hôm nay nhé!',
            style: AppTokensV2.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ])),
      _bell(),
    ]);
  }

  Widget _hero(HomeState state) {
    final checkIn = _fmtTime(state.checkInToday);
    final checkOut = _fmtTime(state.checkOutToday);
    final checkedIn = checkIn != '--:--';

    // Giờ ca quy định (như Home v1: chưa có ca -> 08:30 - 18:00, ngày nghỉ -> --:--)
    final shift = state.shiftToday;
    final hm = DateFormat('HH:mm');
    final shiftIn = shift == null
        ? "08:30"
        : (shift.isDayOff ? "--:--" : hm.format(shift.start));
    final shiftOut = shift == null
        ? "18:00"
        : (shift.isDayOff ? "--:--" : hm.format(shift.end));
    final shiftName = shift?.name?.trim();

    // Đã tải xong mà không có ca → "Chưa phân ca" (trước hiện mặc định "Ca HC").
    // Đang tải / tải lỗi → chưa hiện badge.
    final noShift = shift == null && state.shiftStatus == LoadStatus.SUCCESS;
    final shiftBadgeText = shift == null
        ? 'Chưa phân ca'
        : (shift.isDayOff
            ? 'Ngày nghỉ'
            : (shiftName != null && shiftName.isNotEmpty
                ? 'Ca $shiftName · $shiftIn - $shiftOut'
                : 'Ca $shiftIn - $shiftOut'));

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
      // Thẻ đứng yên: đã bỏ dải sáng quét ngang (ShimmerSweepV2) chạy liên tục phía trên.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokensV2.radius),
        child: GlassCardV2(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Hôm nay · ${_todayShort()}', style: AppTokensV2.captionStrong),
                  if (shift != null || noShift)
                    _shiftBadge(shift, shiftBadgeText),
                ],
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: _timeCol('Chấm Công Vào', checkIn,
                      checkedIn ? 'Đã chấm' : 'Chưa chấm', checkedIn),
                ),
                Container(width: 1, height: 44, color: AppTokensV2.border),
                const SizedBox(width: 12),
                Expanded(
                  child: _timeCol(
                      'Chấm Công Ra',
                      checkOut,
                      checkOut != '--:--' ? 'Đã chấm' : 'Chưa chấm',
                      checkOut != '--:--'),
                ),
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
      ),
    );
  }

  /// Badge hiển thị tên ca và khung giờ trên đầu card Hero.
  /// - Chế độ sáng: màu xanh dương iOS (#007AFF) tương phản tốt trên nền trắng.
  /// - Chế độ tối: nền app đã pha xanh navy nên dùng màu kính trắng bạc (#FFFFFF)
  ///   để nổi bật rõ ràng, không bị chìm vào nền.
  Widget _shiftBadge(ShiftOfDayEntity? shift, String text) {
    // Ngày nghỉ / chưa phân ca: badge màu cảnh báo.
    final isDayOff = shift?.isDayOff ?? true;
    final Color badgeFg;
    final Color badgeBg;
    final Color badgeBorder;
    final Color dotColor;

    if (isDayOff) {
      badgeFg = AppTokensV2.warn;
      badgeBg = AppTokensV2.warn.withValues(alpha: AppTokensV2.isDark ? 0.16 : 0.10);
      badgeBorder = AppTokensV2.warn.withValues(alpha: AppTokensV2.isDark ? 0.36 : 0.25);
      dotColor = AppTokensV2.warn;
    } else if (AppTokensV2.isDark) {
      // Dark mode: kính mờ trắng sáng cao cấp, chữ trắng tinh nổi bật trên nền xanh navy tối
      badgeFg = Colors.white;
      badgeBg = const Color(0x1FFFFFFF); // rgba(255, 255, 255, 0.12)
      badgeBorder = const Color(0x47FFFFFF); // rgba(255, 255, 255, 0.28)
      dotColor = const Color(0xFF60A5FA); // chấm xanh dương sáng nhẹ
    } else {
      // Light mode: xanh dương iOS trên nền trắng
      badgeFg = AppTokensV2.accent;
      badgeBg = AppTokensV2.accent.withValues(alpha: 0.08);
      badgeBorder = AppTokensV2.accent.withValues(alpha: 0.25);
      dotColor = AppTokensV2.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeBorder, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.5,
            height: 5.5,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5.5),
          Text(
            text,
            style: TextStyle(
              color: badgeFg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }

  /// Mốc bắt đầu tính giờ làm: giờ vào ca được phân; chưa có ca thì 08:30 (giờ mặc định
  /// hiện trên thẻ). Chấm vào sớm hơn mốc này vẫn tính từ mốc này.
  DateTime? _progressShiftStart(ShiftOfDayEntity? shift, DateTime? checkIn) {
    if (shift != null) return shift.start;
    return checkIn == null ? null : defaultShiftStartV2(checkIn);
  }

  /// Tiến độ giờ làm theo ca được phân hôm nay: thanh tiến độ + "còn bao lâu nữa đủ giờ".
  /// Không hiện khi: chưa phân ca, ngày nghỉ (ca CT/L), vào muộn quá 15 phút so với giờ
  /// bắt đầu ca ([showWorkProgressV2]).
  Widget _workProgress(HomeState state) {
    final shift = state.shiftToday;
    // Chưa phân ca (hoặc chưa tải được ca) / ngày nghỉ → không hiện: không có giờ ca để tính.
    if (shift == null || shift.isDayOff) return const SizedBox.shrink();
    final checkIn = AppDateUtils.parseFlexibleDate(state.checkInToday);
    if (!showWorkProgressV2(checkIn: checkIn, shiftStart: shift.start)) {
      return const SizedBox.shrink();
    }
    final p = computeWorkProgressV2(
      checkIn: checkIn,
      checkOut: AppDateUtils.parseFlexibleDate(state.checkOutToday),
      now: DateTime.now(),
      shiftStart: shift.start,
      shiftEnd: shift.end,
    );
    if (p == null || p.required <= Duration.zero) return const SizedBox.shrink();

    final ratio = (p.worked.inMinutes / p.required.inMinutes)
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
            FractionallySizedBox(
              widthFactor: ratio,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: p.done
                      ? LinearGradient(
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
                  ? 'Đã đủ giờ — có thể chấm công ra'
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTokensV2.captionStrong.copyWith(fontSize: 10.5)),
        const SizedBox(height: 4),
        Text(time, style: AppTokensV2.number),
        const SizedBox(height: 3),
        Row(
          children: [
            ok
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: AppTokensV2.success, shape: BoxShape.circle),
                  )
                : Icon(Icons.schedule, size: 12, color: AppTokensV2.fgSoft),
            const SizedBox(width: 5),
            Text(
              status,
              style: TextStyle(
                color: ok ? AppTokensV2.success : AppTokensV2.fgSoft,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _utilities() {
    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.people_alt_outlined,
        'Nhân viên',
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StaffPageV2(isFromHome: true))),
      ),
      (
        Icons.description_outlined,
        'Dữ liệu công',
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AttendanceDataPageV2())),
      ),
      (
        Icons.event_available_outlined,
        'Nghỉ phép',
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OnLeavePageV2(isFromHome: true))),
      ),
      (
        Icons.fingerprint,
        'Chấm công',
        () => GlobalData.instance.bottomNavIndex.value = 2,
      ),
      (
        Icons.checklist_rounded,
        'Việc cần làm',
        _openTaskManage,
      ),
      (
        Icons.assignment_outlined,
        'Đơn từ',
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ApplicationPageV2())),
      ),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tiện ích', style: AppTokensV2.section),
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

  /// Hàng tab trạng thái việc (chọn tab nào thì hiện việc của trạng thái đó).
  Widget _taskTabs(HomeState state) {
    final stages = state.homeTaskStages.isEmpty
        ? HomeCubit.defaultHomeTaskStages
        : state.homeTaskStages;
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: stages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final stage = stages[i];
          final selected = stage.id == state.homeTaskStageId;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (stage.id == null || selected) return;
              HapticFeedback.selectionClick();
              _cubit.selectHomeTaskStage(stage.id!);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppTokensV2.accent.withValues(alpha: 0.22)
                    : AppTokensV2.surfaceStrong,
                border: Border.all(
                    color: selected ? AppTokensV2.accent : AppTokensV2.border),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Text(
                stage.name ?? '',
                style: TextStyle(
                  color: selected ? AppTokensV2.accent : AppTokensV2.fgSoft,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tasks(HomeState state) {
    final tasks = state.listNewTasks ?? const [];
    final loading = state.loadDataStatus == LoadStatus.LOADING && tasks.isEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Việc cần làm', style: AppTokensV2.section),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openTaskManage,
          child: Text('Xem tất cả',
              style: TextStyle(
                  color: AppTokensV2.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 10),
      _taskTabs(state),
      const SizedBox(height: 12),
      if (loading)
        GlassCardV2(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppTokensV2.accent),
            ),
          ),
        )
      else if (tasks.isEmpty)
        GlassCardV2(
          padding: const EdgeInsets.all(20),
          child: Center(
              child: Text('Không có việc nào', style: AppTokensV2.caption)),
        )
      else
        for (final t in tasks.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openDetailTask(t),
              child: GlassCardV2(
                padding: const EdgeInsets.all(13),
                child: Row(children: [
                  Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
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
          ),
    ]);
  }
}
