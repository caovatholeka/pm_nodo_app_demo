
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/justification/create_justification_page.dart';
import 'package:pm_app/app/features/ui/justification/justification_detail.dart';
import 'package:pm_app/app/features/ui/justification/widgets/justification_list_item.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';
import 'bloc/justification_cubit.dart';

class JustificationPage extends StatefulWidget {
  final bool? isFromHome;
  const JustificationPage({super.key, this.isFromHome});

  @override
  State<JustificationPage> createState() => _JustificationPageState();
}

class _JustificationPageState extends State<JustificationPage> {
  final _cubit = JustificationCubit();
  final TextEditingController _filterCtrl = TextEditingController();
  final Set<int> _selectedIds = {};
  final _df = DateFormat('dd/MM/yyyy');
  DateTimeRange? _selectedRange;

  bool get _isDirector {
    final jobTitle = context.read<AppCubit>().state.userProfile?.jobTitle ?? '';
    return jobTitle.toLowerCase().contains('giám đốc');
  }

  @override
  void initState() {
    super.initState();
    _cubit.loadList();
  }

  @override
  void dispose() {
    _filterCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _openCalendar() async {
    final now = DateTime.now();
    final defaultRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );

    final currentLocale = Localizations.localeOf(context).toLanguageTag();
    final res = await showModalBottomSheet<DateTimeRange?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder:
          (_) => CalendarRangeSheet(
            initial: _selectedRange ?? defaultRange,
            locale: currentLocale,
          ),
    );

    if (res == null) {
      setState(() {
        _selectedRange = null;
        _filterCtrl.clear();
      });
      _cubit.loadList();
      return;
    }

    setState(() {
      _selectedRange = res;
      _filterCtrl.text = "${_df.format(res.start)} - ${_df.format(res.end)}";
    });

    _cubit.loadList(
      startDate: DateFormat('yyyy-MM-dd').format(res.start),
      endDate: DateFormat('yyyy-MM-dd').format(res.end),
    );
  }

  void _refreshList() {
    if (_selectedRange != null) {
      _cubit.loadList(
        startDate: DateFormat('yyyy-MM-dd').format(_selectedRange!.start),
        endDate: DateFormat('yyyy-MM-dd').format(_selectedRange!.end),
      );
    } else {
      _cubit.loadList();
    }
  }

  void _approveSelected() {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: s.confirm,
            content: s
                .justification_confirm_submit("{count}")
                .replaceFirst("{count}", _selectedIds.length.toString()),
            confirmText: s.authorize,
            cancelText: s.cancel,
            success: true,
            onConfirm: () {
              Navigator.pop(context);
              _cubit.approveByIds(_selectedIds.toList());
            },

            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  void _goNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
              child: const NotificationPage(),
            ),
      ),
    );
  }

  void _sendRQJustification(JustificationEntity entity) {
    showDialog(
      context: context,
       builder: (_) => CustomDialog(
        title: "Xác nhận",
        content: "Bạn có muốn gửi đơn duyệt này không?",
        cancelText: "Không",
        confirmText: "Ok",
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);
          _cubit.onConfirmJustification(entity.id!);
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (_) => _cubit,
      child: BlocListener<JustificationCubit, JustificationState>(
        listenWhen: (p, c) => p.approveStatus != c.approveStatus,
        listener: (context, state) {
          if (state.approveStatus == LoadStatus.SUCCESS) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(s.justification_submit_success),
                backgroundColor: Colors.green,
              ),
            );
            _selectedIds.clear();
            setState(() {});
            context.read<JustificationCubit>().resetApproveStatus();
          }

          if (state.approveStatus == LoadStatus.FAILURE) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? s.justification_submit_failed),
                backgroundColor: Colors.red,
              ),
            );
            context.read<JustificationCubit>().resetApproveStatus();
          }

          if(state.submitStatus == LoadStatus.SUCCESS) {
            SnackBar(
                content: Text(state.error ?? s.justification_submit_failed),
                backgroundColor: Colors.green,
              );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: BlocBuilder<AppCubit, AppState>(
              buildWhen: (p, c) => p.totalUnread != c.totalUnread,
              builder: (context, appState) {
                return MyAppBar(
                  titleAppbar: s.justification_title,
                  haveBackButton: true,
                  haveActionButton: true,
                  iconPathAsset: AppAssets.icNotificationBell,
                  badgeCount: appState.totalUnread,
                  actionCallBack: _goNotification,
                );
              },
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _openCalendar,
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _filterCtrl,
                            decoration: InputDecoration(
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                size: 18,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateJustificationPage(),
                          ),
                        );
                        _refreshList();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.mainPrimaryColor6,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<JustificationCubit, JustificationState>(
                builder: (context, state) {
                  if (!_isDirector) return const SizedBox.shrink();

                  final approvableIds =
                      state.list
                          .where((e) => e.stage?.name == 'Trưởng phòng duyệt')
                          .map((e) => e.id)
                          .whereType<int>()
                          .toSet();

                  if (approvableIds.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final isAllChecked =
                      _selectedIds.isNotEmpty &&
                      _selectedIds.containsAll(approvableIds);

                  final isLoading = state.approveStatus == LoadStatus.LOADING;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  checkboxTheme: CheckboxThemeData(
                                    fillColor: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return AppColors.mainPrimaryColor6;
                                      }
                                      return Colors.transparent;
                                    }),
                                    checkColor: WidgetStateProperty.all(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                child: Checkbox(
                                  value: isAllChecked,
                                  onChanged:
                                      isLoading
                                          ? null
                                          : (value) {
                                            setState(() {
                                              if (value == true) {
                                                _selectedIds
                                                  ..clear()
                                                  ..addAll(approvableIds);
                                              } else {
                                                _selectedIds.clear();
                                              }
                                            });
                                          },
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(S.of(context).choose_all),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed:
                                _selectedIds.isEmpty || isLoading
                                    ? null
                                    : _approveSelected,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainPrimaryColor6,
                              disabledBackgroundColor: AppColors
                                  .mainPrimaryColor6
                                  .withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '${S.of(context).authorize} ${_selectedIds.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<JustificationCubit, JustificationState>(
                  builder: (context, state) {
                    if (state.loadStatus == LoadStatus.LOADING) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }

                    if (state.loadStatus == LoadStatus.FAILURE) {
                      return Center(
                        child: Text(state.error ?? S.of(context).to_do_failed),
                      );
                    }

                    if (state.list.isEmpty) {
                      return Center(
                        child: Text(S.of(context).justification_emptyData),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      itemCount: state.list.length,
                      itemBuilder: (context, index) {
                        final item = state.list[index];
                        final stageName = item.stage?.name ?? '';

                        final isFinished = stageName == 'Hoàn thành';
                        final isCanceled = stageName == 'Hủy';

                        final canSwipe = !isFinished && !isCanceled;

                        final card = JustificationListItem(
                          entity: item,
                          isChecked: _selectedIds.contains(item.id),
                          canApprove: _isDirector,
                          onCheckedChange:
                              _isDirector
                                  ? (v) {
                                    setState(() {
                                      if (v == true) {
                                        _selectedIds.add(item.id!);
                                      } else {
                                        _selectedIds.remove(item.id);
                                      }
                                    });
                                  }
                                  : null,
                          onTap: () async {
                            if (_selectedIds.isNotEmpty) return;
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => JustificationDetailPage(id: item.id),
                              ),
                            );
                            _refreshList();
                          },
                        );

                        if (!canSwipe) {
                          return card;
                        }

                        return Slidable(
                          key: ValueKey(item.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.45,
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  _sendRQJustification(item);
                                },
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                icon: Icons.send,
                                label: "Gửi duyệt",
                              ),
                            ],
                          ),
                          child: card,
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
    );
  }
}
