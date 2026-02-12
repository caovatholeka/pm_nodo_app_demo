import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/overtime/create_overtime.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/overtime_cubit.dart';
import 'package:pm_app/app/features/ui/overtime/overtime_detail.dart';
import 'package:pm_app/app/features/ui/overtime/widgets/overtime_list_item.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

class OvertimePage extends StatefulWidget {
  final bool? isFromHome;
  const OvertimePage({super.key, this.isFromHome});

  @override
  State<OvertimePage> createState() => _OvertimePageState();
}

class _OvertimePageState extends State<OvertimePage> {
  final _cubit = OvertimeCubit();
  final TextEditingController _filterCtrl = TextEditingController();
  final Set<int> _selectedIds = {};
  final _df = DateFormat('dd/MM/yyyy');
  DateTimeRange? _selectedRange;

  bool get _isDirector {
    final jobTitle = context.read<AppCubit>().state.userProfile?.jobTitle ?? "";
    return jobTitle.toLowerCase().contains("giám đốc");
  }

  @override
  void initState() {
    super.initState();
    _cubit.loadOTList();
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

    final res = await showModalBottomSheet<DateTimeRange?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder:
          (_) => CalendarRangeSheet(
            initial: _selectedRange ?? defaultRange,
            locale: "vi",
          ),
    );

    if (res == null) {
      setState(() {
        _selectedRange = null;
        _filterCtrl.clear();
      });
      _cubit.loadOTList();
      return;
    }

    setState(() {
      _selectedRange = res;
      _filterCtrl.text = "${_df.format(res.start)} - ${_df.format(res.end)}";
    });

    _cubit.loadOTList(
      startDate: DateFormat('yyyy-MM-dd').format(res.start),
      endDate: DateFormat('yyyy-MM-dd').format(res.end),
    );
  }

  void _refreshList() {
    if (_selectedRange != null) {
      _cubit.loadOTList(
        startDate: DateFormat('yyyy-MM-dd').format(_selectedRange!.start),
        endDate: DateFormat('yyyy-MM-dd').format(_selectedRange!.end),
      );
    } else {
      _cubit.loadOTList();
    }
  }

  void _approveSelected() {
    if (_selectedIds.isEmpty) return;

    final ids = _selectedIds.toList();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: "Xác nhận duyệt",
            content: "Bạn có chắc muốn duyệt ${ids.length} đơn tăng ca",
            confirmText: "Duyệt",
            cancelText: "Hủy",
            success: true,
            onConfirm: () {
              Navigator.pop(context);
              _cubit.approveBulkOvertimes(ids);
            },
            onCancel: () {
              Navigator.pop(context);
            },
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocProvider(
      create: (_) => _cubit,
      child: BlocListener<OvertimeCubit, OvertimeState>(
        listenWhen: (prev, cur) => prev.approveStatus != cur.approveStatus,
        listener: (context, state) {
          if (state.approveStatus == LoadStatus.LOADING) {
            LoadingOverlay.show(context);
          }

          if (state.approveStatus == LoadStatus.SUCCESS) {
            LoadingOverlay.hide(context);

            AppSnackBar.showInfo(
              title: "Thành công",
              message: "Duyệt tăng ca thành công",
            );

            _selectedIds.clear();

            if (_selectedRange != null) {
              _cubit.loadOTList(
                startDate: DateFormat(
                  'yyyy-MM-dd',
                ).format(_selectedRange!.start),
                endDate: DateFormat('yyyy-MM-dd').format(_selectedRange!.end),
              );
            } else {
              _cubit.loadOTList();
            }

            setState(() {});
          }

          if (state.approveStatus == LoadStatus.FAILURE) {
            LoadingOverlay.hide(context);

            AppSnackBar.showError(
              title: "Cảnh báo",
              message: state.error ?? "Duyệt tăng ca thất bại",
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
                  titleAppbar: s.ot_pageTitle,
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
                            builder: (_) => const CreateOTPage(),
                          ),
                        );
                        _refreshList();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== BULK APPROVE BAR =====
              BlocBuilder<OvertimeCubit, OvertimeState>(
                builder: (context, state) {
                  if (!_isDirector) return const SizedBox.shrink();

                  final approvableIds =
                      state.list
                          .where((e) => e.stage?.name == 'Trưởng phòng duyệt')
                          .map((e) => e.id)
                          .whereType<int>()
                          .toSet();

                  if (approvableIds.isEmpty) {
                    _selectedIds.clear();
                    return const SizedBox.shrink();
                  }

                  final isAllChecked =
                      _selectedIds.isNotEmpty &&
                      _selectedIds.containsAll(approvableIds);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Theme(
                              //   data: Theme.of(context).copyWith(
                              //     checkboxTheme: CheckboxThemeData(
                              //       fillColor: WidgetStateProperty.resolveWith((
                              //         states,
                              //       ) {
                              //         if (states.contains(
                              //           WidgetState.selected,
                              //         )) {
                              //           return AppColors.mainPrimaryColor6;
                              //         }
                              //         return Colors.transparent;
                              //       }),
                              //     ),
                              //   ),
                              //   child: Checkbox(
                              //     value: isAllChecked,
                              //     onChanged: (v) {
                              //       setState(() {
                              //         if (v == true) {
                              //           _selectedIds
                              //             ..clear()
                              //             ..addAll(approvableIds);
                              //         } else {
                              //           _selectedIds.clear();
                              //         }
                              //       });
                              //     },
                              //   ),
                              // ),
                              // const SizedBox(width: 4),
                              // const Text("Chọn tất"),
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   height: 40,
                        //   child: ElevatedButton(
                        //     onPressed:
                        //         _selectedIds.isEmpty ? null : _approveSelected,
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColors.mainPrimaryColor6,
                        //       disabledBackgroundColor: AppColors
                        //           .mainPrimaryColor6
                        //           .withOpacity(0.4),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //     ),
                        //     child: Text(
                        //       "Duyệt (${_selectedIds.length})",
                        //       style: const TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  );
                },
              ),

              // ===== LIST =====
              Expanded(
                child: BlocBuilder<OvertimeCubit, OvertimeState>(
                  builder: (context, state) {
                    if (state.loadStatus == LoadStatus.LOADING) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }

                    if (state.loadStatus == LoadStatus.FAILURE) {
                      return Center(
                        child: Text(state.error ?? 'Có lỗi xảy ra'),
                      );
                    }

                    if (state.list.isEmpty) {
                      return Center(child: Text(s.ot_emptyData));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      itemCount: state.list.length,
                      itemBuilder: (context, index) {
                        final item = state.list[index];

                        return OvertimeListItem(
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
                                builder: (_) => OvertimeDetail(id: item.id),
                              ),
                            );
                            _refreshList();
                          },
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
