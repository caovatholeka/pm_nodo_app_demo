import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/ui_v2/attendance/attendance_data_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/on_leave/on_leave_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/task/task_manage_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/overtime/overtime_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/justification/justification_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/work_trip/work_trip_page_v2.dart';

import 'package:pm_app/app/data/models/entities/notification_entity.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Thông báo — giao diện tối (v2). Nội dung/hành vi giữ nguyên bản cũ
/// [NotificationPage]: 4 tab (tất cả/chung/cá nhân/chưa đọc), đánh dấu đã đọc
/// tất cả, chạm 1 thông báo để đánh dấu đã đọc + điều hướng theo tiêu đề.
/// Tái dùng [NotiCubit] được provide từ bên ngoài (không tạo mới, không close).
class NotificationPageV2 extends StatefulWidget {
  const NotificationPageV2({super.key});

  @override
  State<NotificationPageV2> createState() => _NotificationPageV2State();
}

class _NotificationPageV2State extends State<NotificationPageV2> {
  int selectedTab = 0;
  final ScrollController _scroll = ScrollController();

  /// Loại thông báo tương ứng tab đang chọn (khớp mapping khi đổi tab).
  String get _currentType => switch (selectedTab) {
        0 => "all",
        1 => "general",
        2 => "current_user",
        3 => "unseen",
        _ => "all",
      };

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 100) {
      final cubit = context.read<NotiCubit>();
      if (cubit.state.canLoadMore) {
        cubit.loadMore(_currentType);
      }
    }
  }

  late List<String> tabs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = S.of(context);

    tabs = [
      s.notifications_all,
      s.notifications_general,
      s.notifications_personal,
      s.notifications_unread,
    ];
  }

  @override
  void initState() {
    super.initState();
    context.read<NotiCubit>().loadNotifications("all");
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onMarkAllRead(BuildContext context) {
    final cubit = context.read<NotiCubit>();
    final unread = cubit.state.totalUnread;
    final state = cubit.state;
    final s = S.of(context);

    if (state.notifications.isEmpty) {
      Flushbar(
        message: s.notifications_empty,
        backgroundColor: const Color(0xFFFFC107),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.info_outline, color: Colors.white),
      ).show(context);
      return;
    }

    if (unread == 0) {
      Flushbar(
        message: s.notifications_readAll,
        backgroundColor: const Color(0xFFFFC107),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.info_outline, color: Colors.white),
      ).show(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: s.notifications_readAlltitle,
            content: s.notifications_readAllSub,
            confirmText: s.notifications_agree,
            cancelText: s.cancel,
            onConfirm: () {
              Navigator.pop(context);
              cubit.markRead(markAll: true);
              Flushbar(
                message: s.notifications_readAllSuscess,
                backgroundColor: const Color.fromARGB(255, 0, 255, 85),
                flushbarPosition: FlushbarPosition.TOP,
                margin: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(12),
                duration: const Duration(seconds: 2),
                icon: const Icon(Icons.info_outline, color: Colors.white),
              ).show(context);
            },
          ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationEntity noti) {
    HapticFeedback.selectionClick();
    final title = noti.title ?? "";
    final cubit = context.read<NotiCubit>();

    if (noti.id != null && noti.isSeen != true) {
      cubit.markRead(markAll: false, id: noti.id);
    }

    switch (title) {
      case "Đơn nghỉ phép":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OnLeavePageV2(isFromHome: true)));
        break;
      case "Phân công công việc":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TaskManagePageV2(isFromHome: true)));
        break;
      case "Đơn tăng ca":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OvertimePageV2(isFromHome: true)));
        break;
      case "Đơn muộn sớm":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const JustificationPageV2(isFromHome: true)));
        break;
      case "Đơn công tác":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WorkTripPageV2(isFromHome: true)));
        break;
      case "Giải trình công không hợp lệ":
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AttendanceDataPageV2()));
        break;
      default:
        debugPrint("⚠️ Chưa map notification title: $title");
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
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
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: StaggerRevealV2(index: 1, child: _buildTabs()),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<NotiCubit, NotiState>(
                  builder: (context, state) => _buildBody(s, state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(S s) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.maybePop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTokensV2.fg, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(s.nottifications_title,
              style: AppTokensV2.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onMarkAllRead(context),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              border: Border.all(color: AppTokensV2.border),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.done_all_rounded,
                size: 20, color: AppTokensV2.fgSoft),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(S s, NotiState state) {
    if (state.status == LoadStatus.LOADING) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: AppTokensV2.accent,
          ),
        ),
      );
    }

    final sorted = _sortByDate(state.notifications);
    final grouped = _groupByDay(sorted);

    if (sorted.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off_outlined,
                  size: 44, color: AppTokensV2.fgMuted),
              const SizedBox(height: 12),
              Text(s.notification_no_data, style: AppTokensV2.captionStrong),
            ],
          ),
        ),
      );
    }

    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
      children: [
        if (grouped["today"]!.isNotEmpty) ...[
          _sectionTitle(s.notification_time),
          const SizedBox(height: 12),
          ...grouped["today"]!.asMap().entries.map(
                (e) => _notiCard(e.value, e.key),
              ),
          const SizedBox(height: 22),
        ],
        if (grouped["yesterday"]!.isNotEmpty) ...[
          _sectionTitle(s.notifications_time5),
          const SizedBox(height: 12),
          ...grouped["yesterday"]!.asMap().entries.map(
                (e) => _notiCard(e.value, e.key),
              ),
          const SizedBox(height: 22),
        ],
        if (grouped["others"]!.isNotEmpty) ...[
          _sectionTitle(s.notifications_time6),
          const SizedBox(height: 12),
          ...grouped["others"]!.asMap().entries.map(
                (e) => _notiCard(e.value, e.key),
              ),
        ],
      ],
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: tabs.length,
        itemBuilder: (context, i) {
          final bool isSelected = (i == selectedTab);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => selectedTab = i);

              final type = switch (i) {
                0 => "all",
                1 => "general",
                2 => "current_user",
                3 => "unseen",
                _ => "all",
              };

              context.read<NotiCubit>().loadNotifications(type);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTokensV2.accent : AppTokensV2.surfaceStrong,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTokensV2.border,
                  width: 1.2,
                ),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTokensV2.fgSoft,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Text(title, style: AppTokensV2.section),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: AppTokensV2.border)),
      ],
    );
  }

  Widget _notiCard(NotificationEntity item, int index) {
    final bool isUnread = !(item.isSeen ?? false);
    final (IconData icon, Color iconColor) = _getIconData(item.title ?? "");

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: StaggerRevealV2(
        index: index < 6 ? index : 0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleNotificationTap(context, item),
          child: GlassCardV2(
            padding: const EdgeInsets.all(14),
            radius: 17,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 21, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isUnread) ...[
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(top: 5, right: 6),
                              decoration: BoxDecoration(
                                color: AppTokensV2.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              item.title ?? "",
                              style: (isUnread
                                      ? AppTokensV2.body
                                      : AppTokensV2.body.copyWith(
                                          color: AppTokensV2.fgSoft,
                                          fontWeight: FontWeight.w600))
                                  .copyWith(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(timeAgoV2(item.createDate, context),
                              style: AppTokensV2.caption),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.content ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTokensV2.caption.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getIconData(String rawTitle) {
    final title = rawTitle.toLowerCase();

    if (title.contains("điểm danh") || title.contains("checkin")) {
      return (Icons.fingerprint_rounded, AppTokensV2.success);
    } else if (title.contains("nhân viên") || title.contains("nghỉ")) {
      return (Icons.people_alt_rounded, AppTokensV2.accent);
    } else if (title.contains("đơn") || title.contains("phiếu")) {
      return (Icons.description_rounded, AppTokensV2.warn);
    }

    return (Icons.notifications_rounded, AppTokensV2.danger);
  }

  List<NotificationEntity> _sortByDate(List<NotificationEntity> list) {
    final cloned = List<NotificationEntity>.from(list);
    cloned.sort((a, b) {
      final da = _parseDate(a.createDate);
      final db = _parseDate(b.createDate);
      return db.compareTo(da);
    });
    return cloned;
  }

  DateTime _parseDate(String? raw) {
    try {
      return DateFormat("dd-MM-yy HH:mm").parse(raw ?? "");
    } catch (_) {
      return DateTime(2000);
    }
  }

  Map<String, List<NotificationEntity>> _groupByDay(
    List<NotificationEntity> list,
  ) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    List<NotificationEntity> todayList = [];
    List<NotificationEntity> yesterdayList = [];
    List<NotificationEntity> others = [];

    for (var e in list) {
      final d = _parseDate(e.createDate);

      if (_isSameDay(d, today)) {
        todayList.add(e);
      } else if (_isSameDay(d, yesterday)) {
        yesterdayList.add(e);
      } else {
        others.add(e);
      }
    }

    return {"today": todayList, "yesterday": yesterdayList, "others": others};
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Bản sao của `timeAgo` (bản cũ) để tránh phụ thuộc file `ui/notification/noti_page.dart`.
String timeAgoV2(String? rawDate, BuildContext context) {
  final s = S.of(context);
  if (rawDate == null) return "";

  DateTime date;
  try {
    date = DateFormat("dd-MM-yy HH:mm").parse(rawDate);
  } catch (_) {
    return rawDate;
  }

  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) {
    return s.notifications_time1;
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes}${s.notifications_time2}";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} giờ trước";
  } else if (diff.inDays == 1) {
    return "1 ngày trước";
  } else {
    return "${diff.inDays}${s.notifications_time4}";
  }
}
