import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/overtime_cubit.dart';
import 'package:pm_app/app/features/ui_v2/overtime/create_overtime_v2.dart';
import 'package:pm_app/app/features/ui_v2/overtime/overtime_detail_v2.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

import 'widget/overtime_list_item_v2.dart';

/// Màn Tăng ca — phiên bản giao diện tối (v2). Nội dung/hành vi giữ nguyên
/// bản cũ [OvertimePage]: lọc theo khoảng ngày, tạo đơn, duyệt hàng loạt
/// (chỉ Giám đốc), vuốt để gửi duyệt đơn nháp, mở chi tiết.
/// Tạo mới [OvertimeCubit] giống bản cũ (không lấy từ GetIt), đóng khi dispose.
class OvertimePageV2 extends StatefulWidget {
  final bool? isFromHome;
  const OvertimePageV2({super.key, this.isFromHome});

  @override
  State<OvertimePageV2> createState() => _OvertimePageV2State();
}

class _OvertimePageV2State extends State<OvertimePageV2> {
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
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final defaultRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );

    final currentLocal = Localizations.localeOf(context).toLanguageTag();

    final res = await showModalBottomSheet<DateTimeRange?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder:
          (_) => CalendarRangeSheet(
            initial: _selectedRange ?? defaultRange,
            locale: currentLocal,
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
    final s = S.of(context);
    if (_selectedIds.isEmpty) return;

    final ids = _selectedIds.toList();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: s.confirm_authorize,
            content: s
                .sub_confirm_authorize("{count}")
                .replaceFirst("{count}", ids.length.toString()),
            confirmText: s.authorize,
            cancelText: s.cancel,
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
    HapticFeedback.selectionClick();
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

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<OvertimeCubit, OvertimeState>(
        listenWhen:
            (prev, cur) =>
                prev.loadStatus != cur.loadStatus ||
                prev.approveStatus != cur.approveStatus ||
                prev.submitStatus != cur.submitStatus,
        listener: (context, state) {
          if (state.loadStatus == LoadStatus.LOADING ||
              state.approveStatus == LoadStatus.LOADING ||
              state.submitStatus == LoadStatus.LOADING) {
            LoadingOverlay.show(context);
          }

          if (state.loadStatus == LoadStatus.SUCCESS ||
              state.loadStatus == LoadStatus.FAILURE ||
              state.approveStatus == LoadStatus.SUCCESS ||
              state.approveStatus == LoadStatus.FAILURE ||
              state.submitStatus == LoadStatus.SUCCESS ||
              state.submitStatus == LoadStatus.FAILURE) {
            LoadingOverlay.hide(context);
          }

          if (state.approveStatus == LoadStatus.SUCCESS) {
            AppSnackBar.showInfo(
              title: s.success,
              message: s.ot_approve_success,
            );

            _selectedIds.clear();
            _cubit.resetApproveStatus();

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

          if (state.submitStatus == LoadStatus.LOADING) {
            LoadingOverlay.show(context);
          }
          if (state.submitStatus == LoadStatus.SUCCESS) {
            LoadingOverlay.hide(context);

            Flushbar(
              message: "Gửi duyệt thành công",
              backgroundColor: Colors.green,
              flushbarPosition: FlushbarPosition.TOP,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(8),
            ).show(context);

            _cubit.resetSubmitStatus();
          }

          if (state.submitStatus == LoadStatus.FAILURE) {
            LoadingOverlay.hide(context);

            Flushbar(
              message: state.error ?? "Gửi duyệt thất bại",
              backgroundColor: Colors.red,
              flushbarPosition: FlushbarPosition.TOP,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(8),
            ).show(context);
          }

          if (state.approveStatus == LoadStatus.FAILURE) {
            LoadingOverlay.hide(context);

            AppSnackBar.showError(
              title: s.warning,
              message: state.error ?? s.ot_approve_failed,
            );
          }
        },
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
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: StaggerRevealV2(index: 1, child: _filterWidget),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _bulkActionWidget,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: _listWidget,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(S s) {
    final showBack = widget.isFromHome ?? false;
    return Row(
      children: [
        if (showBack) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.maybePop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTokensV2.fg,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            s.ot_pageTitle,
            style: AppTokensV2.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _goNotification,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              border: Border.all(color: AppTokensV2.border),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: AppTokensV2.fgSoft,
            ),
          ),
        ),
      ],
    );
  }

  Widget get _filterWidget {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openCalendar,
            child: GlassCardV2(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              radius: 15,
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 17,
                      color: AppTokensV2.fgMuted,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _filterCtrl.text.isNotEmpty ? _filterCtrl.text : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            _filterCtrl.text.isNotEmpty
                                ? AppTokensV2.body.copyWith(fontSize: 13)
                                : AppTokensV2.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            HapticFeedback.selectionClick();
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateOTPageV2()),
            );
            _refreshList();
          },
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppTokensV2.accentGradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppTokensV2.glow,
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget get _bulkActionWidget {
    final s = S.of(context);
    return BlocBuilder<OvertimeCubit, OvertimeState>(
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
            _selectedIds.isNotEmpty && _selectedIds.containsAll(approvableIds);

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: GlassCardV2(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            radius: 15,
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
                              if (states.contains(WidgetState.selected)) {
                                return AppTokensV2.accent;
                              }
                              return Colors.transparent;
                            }),
                            checkColor: WidgetStateProperty.all(Colors.white),
                            side: const BorderSide(
                              color: AppTokensV2.fgMuted,
                              width: 1.2,
                            ),
                          ),
                        ),
                        child: Checkbox(
                          value: isAllChecked,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (v == true) {
                                _selectedIds
                                  ..clear()
                                  ..addAll(approvableIds);
                              } else {
                                _selectedIds.clear();
                              }
                            });
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(s.choose_all, style: AppTokensV2.captionStrong),
                    ],
                  ),
                ),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed:
                        _selectedIds.isEmpty
                            ? null
                            : () {
                              HapticFeedback.selectionClick();
                              _approveSelected();
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokensV2.accent,
                      disabledBackgroundColor: AppTokensV2.accent.withValues(
                        alpha: 0.35,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      "${s.authorize} ${_selectedIds.length}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget get _listWidget {
    final s = S.of(context);
    return BlocBuilder<OvertimeCubit, OvertimeState>(
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.LOADING) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppTokensV2.accent,
            ),
          );
        }

        if (state.loadStatus == LoadStatus.FAILURE) {
          return Center(
            child: Text(
              state.error ?? s.to_do_failed,
              style: AppTokensV2.captionStrong,
            ),
          );
        }

        if (state.list.isEmpty) {
          return Center(
            child: Text(s.ot_emptyData, style: AppTokensV2.captionStrong),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          itemCount: state.list.length,
          itemBuilder: (context, index) {
            final item = state.list[index];
            final stageName = item.stage?.name ?? '';

            final canSwipe = stageName == 'Nháp' && _selectedIds.isEmpty;

            final card = StaggerRevealV2(
              index: index < 6 ? index : 0,
              child: OvertimeListItemV2(
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
                      builder: (_) => OvertimeDetailV2(id: item.id),
                    ),
                  );
                  _refreshList();
                },
              ),
            );

            if (!canSwipe) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: card,
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Slidable(
                key: ValueKey(item.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 0.45,
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        showDialog(
                          context: context,
                          builder:
                              (_) => CustomDialog(
                                title: "Xác nhận",
                                content:
                                    "Bạn có muốn gửi duyệt đơn OT này không?",
                                cancelText: "Không",
                                confirmText: "Ok",
                                onCancel: () => Navigator.pop(context),
                                onConfirm: () {
                                  Navigator.pop(context);
                                  _cubit.submitApproval(item.id!);
                                },
                              ),
                        );
                      },
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.send,
                      label: "Gửi duyệt",
                    ),
                  ],
                ),
                child: card,
              ),
            );
          },
        );
      },
    );
  }
}
