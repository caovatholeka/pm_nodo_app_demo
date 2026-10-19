import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/checkpoint/cubit/checkpoint_cubit.dart';
import 'package:pm_app/app/features/ui/checkpoint/widgets/checkpoint_list_items.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

class CheckpointPage extends StatefulWidget {
  final bool? isFromHome;

  const CheckpointPage({super.key, this.isFromHome});

  @override
  State<CheckpointPage> createState() => _CheckpointPageState();
}

class _CheckpointPageState extends State<CheckpointPage> {
  final _cubit = GetIt.I.get<CheckpointCubit>();
  final _filterController = TextEditingController();
  final _df = DateFormat('dd/MM/yyyy');
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _cubit.getListCheckpoint();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final state = _cubit.state;
    await _cubit.getListCheckpoint(
      dateFrom: state.startDateFilter,
      dateTo: state.endDateFilter,
    );
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
            locale: Localizations.localeOf(context).toLanguageTag(),
          ),
    );

    if (res == null) {
      setState(() {
        _selectedRange = null;
        _filterController.clear();
      });

      _cubit.onChangeDateFilter('', '');
      await _cubit.getListCheckpoint(dateFrom: '', dateTo: '');
      return;
    }

    final start = _df.format(res.start);
    final end = _df.format(res.end);

    setState(() {
      _selectedRange = res;
      _filterController.text = '$start - $end';
    });

    _cubit.onChangeDateFilter(start, end);
    await _cubit.getListCheckpoint(dateFrom: start, dateTo: end);
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

  Future<void> _showSubmitDialog(int id) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => CustomDialog(
            title: 'Xác nhận',
            content: 'Bạn có chắc muốn gửi duyệt phiếu checkpoint này không?',
            confirmText: 'Đồng ý',
            cancelText: 'Hủy',
            onConfirm: () {
              Navigator.pop(context);
              _cubit.submitCheckpoint(id);
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<CheckpointCubit, CheckpointState>(
      bloc: _cubit,
      listenWhen:
          (previous, current) =>
              previous.loadSubmitStatus != current.loadSubmitStatus,
      listener: (context, state) {
        if (state.loadSubmitStatus == LoadStatus.SUCCESS) {
          Flushbar(
            message: 'Gửi duyệt thành công',
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.colorCompliant,
            flushbarPosition: FlushbarPosition.TOP,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetSubmitStatus();
          unawaited(_onRefresh());
        }

        if (state.loadSubmitStatus == LoadStatus.FAILURE) {
          Flushbar(
            message: state.error ?? 'Gửi duyệt thất bại',
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.colorCancel,
            flushbarPosition: FlushbarPosition.TOP,
            icon: const Icon(Icons.error, color: Colors.white),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);

          _cubit.resetSubmitStatus();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: MyAppBar(
          titleAppbar: 'Phiếu Checkpoint',
          haveBackButton: true,
          haveActionButton: true,
          iconPathAsset: AppAssets.icNotificationBell,
          actionCallBack: _goNotification,
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
                          controller: _filterController,
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
                    onTap: () {},
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
            Expanded(
              child: BlocBuilder<CheckpointCubit, CheckpointState>(
                bloc: _cubit,
                buildWhen:
                    (p, c) =>
                        p.loadDataStatus != c.loadDataStatus ||
                        p.listCheckpoint != c.listCheckpoint,
                builder: (context, state) {
                  if (state.loadDataStatus == LoadStatus.LOADING) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mainPrimaryColor6,
                      ),
                    );
                  }

                  if (state.loadDataStatus == LoadStatus.FAILURE) {
                    return Center(child: Text(state.error ?? s.to_do_failed));
                  }

                  if (state.listCheckpoint.isEmpty) {
                    return Center(child: Text(s.bt_empty));
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      itemCount: state.listCheckpoint.length,
                      itemBuilder: (context, index) {
                        final item = state.listCheckpoint[index];
                        final stage =
                            (item.stage ?? item.state ?? '')
                                .toLowerCase()
                                .trim();
                        final canSubmit = stage == 'draft';
                        final card = CheckpointListItem(
                          entity: item,
                          onTap: (_) {},
                        );

                        if (!canSubmit) return card;

                        return Slidable(
                          key: ValueKey(item.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.32,
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  final id = item.id;
                                  if (id == null) return;
                                  _showSubmitDialog(id);
                                },
                                backgroundColor: AppColors.colorCompliant,
                                foregroundColor: Colors.white,
                                icon: Icons.send_rounded,
                                label: 'Gửi duyệt',
                              ),
                            ],
                          ),
                          child: card,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
