import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';

import 'package:pm_app/app/data/models/entities/notification_entity.dart';
import 'package:pm_app/app/features/widgets/notification_item.dart';
import 'package:pm_app/generated/l10n.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int selectedTab = 0;
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
  }

  void _onMarkAllRead(BuildContext context) {
    final cubit = context.read<NotiCubit>();
    final unread = cubit.state.totalUnread;
    final state = cubit.state;

    if(state.notifications.isEmpty) {
      Flushbar(
        message: "Không có thông báo nào để đọc",
        backgroundColor: const Color(0xFFFFC107),
        flushbarPosition: FlushbarPosition.TOP,
        margin:  const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.info_outline, color: Colors.white),
      ).show(context);
      return;
    }

    if (unread == 0) {
      Flushbar(
        message: "Các thông báo đã được đọc hết",
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
            title: "Đọc tất cả thông báo",
            content:
                "Bạn có chắc chắn muốn đánh dấu tất cả thông báo là đã đọc không?",
            confirmText: "Đồng ý",
            cancelText: "Hủy",
            onConfirm: () {
              Navigator.pop(context);
              cubit.markRead(markAll: true);
              Flushbar(
                message: "Đã đọc hết thông báo!!!!",
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: MyAppBar(
        titleAppbar: s.nottifications_title,
        haveBackButton: true,
        haveActionButton: true,
        iconPathAsset: AppAssets.icReadAll,
        actionCallBack: () {
          _onMarkAllRead(context);
        },
      ),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.appBG2),
            fit: BoxFit.cover,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildTabs(),
              const SizedBox(height: 10),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 6),
                  margin: const EdgeInsets.only(right: 3, left: 3),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),

                  child: BlocBuilder<NotiCubit, NotiState>(
                    builder: (context, state) {
                      
                      if (state.status == LoadStatus.LOADING) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1E88FF), 
                              ),
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
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 48,
                                  color: Colors.grey.withOpacity(0.6),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  s.notification_no_data,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        children: [
                          if (grouped["today"]!.isNotEmpty) ...[
                            _sectionTitle(s.notification_time),
                            const SizedBox(height: 14),
                            ...grouped["today"]!.map(
                              (e) => NotificationItem(item: e),
                            ),
                            const SizedBox(height: 26),
                          ],

                          if (grouped["yesterday"]!.isNotEmpty) ...[
                            _sectionTitle(s.notifications_time5),
                            const SizedBox(height: 14),
                            ...grouped["yesterday"]!.map(
                              (e) => NotificationItem(item: e),
                            ),
                            const SizedBox(height: 26),
                          ],

                          if (grouped["others"]!.isNotEmpty) ...[
                            _sectionTitle(s.notifications_time6),
                            const SizedBox(height: 14),
                            ...grouped["others"]!.map(
                              (e) => NotificationItem(item: e),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: tabs.length,
        itemBuilder: (context, i) {
          final bool isSelected = (i == selectedTab);

          return GestureDetector(
            onTap: () {
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
                color:
                    isSelected ? const Color(0xFF1E88FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? Colors.transparent : const Color(0xFFDCE3F2),
                  width: 1.4,
                ),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF697A98),
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: Colors.grey.withOpacity(0.25)),
        ),
      ],
    );
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

String timeAgo(String? rawDate, BuildContext context) {
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
