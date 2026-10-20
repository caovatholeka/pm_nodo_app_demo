import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/approve_ob_param.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_cubit.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

import 'request_new_trip_page_v2.dart';
import 'widget/work_trip_list_item_v2.dart';
import 'work_trip_detail_page_v2.dart';

/// Màn Công tác — phiên bản giao diện tối (v2). Nội dung/hành vi giữ nguyên
/// bản cũ [WorkTripPage]: lọc theo tuần/khoảng ngày, tạo phiếu, duyệt hàng
/// loạt (chỉ Giám đốc), vuốt để gửi duyệt/xoá phiếu nháp, mở chi tiết.
/// Tái dùng [WorkTripCubit] qua GetIt (không tạo mới, không close) — đúng
/// như bản cũ.
class WorkTripPageV2 extends StatefulWidget {
  final bool? isFromHome;
  const WorkTripPageV2({super.key, this.isFromHome});

  @override
  State<WorkTripPageV2> createState() => _WorkTripPageV2State();
}

class _WorkTripPageV2State extends State<WorkTripPageV2> {
  final _cubit = GetIt.I<WorkTripCubit>();
  bool _handlingAction = false;

  final ScrollController controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedIds = {};

  DateTimeRange selectedWeek = _weekOf(DateTime.now());
  final _df = DateFormat('dd/MM/yyyy');

  bool get _isDirector {
    final jobTitle = context.read<AppCubit>().state.userProfile?.jobTitle ?? '';
    return jobTitle.toLowerCase().contains('giám đốc');
  }

  static DateTime _mondayOf(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    final delta = x.weekday - 1;
    return x.subtract(Duration(days: delta));
  }

  static DateTimeRange _weekOf(DateTime d) {
    final start = _mondayOf(d);
    final end = start.add(const Duration(days: 6));
    return DateTimeRange(start: start, end: end);
  }

  @override
  void initState() {
    _cubit.getListWorkTrips();
    super.initState();
  }

  @override
  void dispose() {
    _cubit.onResetStatus();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _cubit.getListWorkTrips();
  }

  Future<void> _openDetail(WorkTripEntity entity) async {
    if (_selectedIds.isNotEmpty) return;

    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                WorkTripDetailPageV2(workEntity: entity, workId: entity.id),
      ),
    );

    if (result == true) {
      _onRefresh();
    }
  }

  Future<void> _requestNewTrip() async {
    HapticFeedback.selectionClick();
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RequestNewTripPageV2()),
    );

    if (result == true) {
      _onRefresh();
    }
  }

  void _approveSelected() {
    final s = S.of(context);
    if (_selectedIds.isEmpty) return;

    final ids = _selectedIds.toList();
    logger.d("Bulk approve IDs: $ids");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: s.bt_confirm_approve,
            content: s
                .bt_confirm_sub_confirm_approve("{count}")
                .replaceFirst('{count}', ids.length.toString()),
            success: true,
            confirmText: s.authorize,
            cancelText: s.cancel,
            onConfirm: () {
              Navigator.pop(context);

              final param = ApproveObParam(businessIds: ids);
              _handlingAction = true;

              _cubit.onApproveWorkTrip(param);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocConsumer<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      listenWhen:
          (prev, cur) =>
              prev.loadDataStatus != cur.loadDataStatus ||
              prev.submitStatus != cur.submitStatus ||
              prev.deleteStatus != cur.deleteStatus ||
              prev.approveStatus != cur.approveStatus ||
              prev.cancelStatus != cur.cancelStatus,
      listener: (context, state) {
        final isOwnerAction = _handlingAction;

        if (!isOwnerAction) {
          final shouldRefreshSilently =
              state.submitStatus == LoadStatus.SUCCESS ||
              state.deleteStatus == LoadStatus.SUCCESS ||
              state.approveStatus == LoadStatus.SUCCESS ||
              state.cancelStatus == LoadStatus.SUCCESS;

          if (shouldRefreshSilently) {
            _selectedIds.clear();
            _cubit.onResetStatus();
            _cubit.getListWorkTrips();
            setState(() {});
            return;
          }

          if (state.submitStatus == LoadStatus.FAILURE ||
              state.deleteStatus == LoadStatus.FAILURE ||
              state.approveStatus == LoadStatus.FAILURE ||
              state.cancelStatus == LoadStatus.FAILURE) {
            _cubit.onResetStatus();
            return;
          }
        }

        if (state.deleteStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          AppSnackBar.showInfo(title: s.success, message: s.bt_delete_success);
          _handlingAction = false;

          _selectedIds.clear();
          _cubit.onResetStatus();
          _cubit.getListWorkTrips();
          setState(() {});
          return;
        }

        if (state.submitStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          AppSnackBar.showInfo(
            title: s.success,
            message: s.justification_sendApproval,
          );
          _handlingAction = false;

          _selectedIds.clear();
          _cubit.onResetStatus();
          _cubit.getListWorkTrips();
          setState(() {});
          return;
        }

        if (state.approveStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          AppSnackBar.showInfo(
            title: s.success,
            message: s.bt_confirm_susscess,
          );
          _handlingAction = false;

          _selectedIds.clear();
          _cubit.onResetStatus();
          _cubit.getListWorkTrips();
          setState(() {});
          return;
        }

        if (state.cancelStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          AppSnackBar.showInfo(title: s.success, message: s.bt_confirm_deny);
          _handlingAction = false;

          _selectedIds.clear();
          _cubit.onResetStatus();
          _cubit.getListWorkTrips();
          setState(() {});
          return;
        }
        if (state.submitStatus == LoadStatus.FAILURE ||
            state.deleteStatus == LoadStatus.FAILURE ||
            state.approveStatus == LoadStatus.FAILURE ||
            state.cancelStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);

          AppSnackBar.showError(
            title: s.warning,
            message: state.errMsg ?? s.to_do_failed,
          );
          _handlingAction = false;

          _cubit.onResetStatus();
          return;
        }

        final isLoading =
            state.loadDataStatus == LoadStatus.LOADING ||
            state.submitStatus == LoadStatus.LOADING ||
            state.deleteStatus == LoadStatus.LOADING ||
            state.approveStatus == LoadStatus.LOADING ||
            state.cancelStatus == LoadStatus.LOADING;

        if (isLoading) {
          if (isOwnerAction) {
            LoadingOverlay.show(context);
          }
        } else {
          if (isOwnerAction) {
            LoadingOverlay.hide(context);
          }
        }
      },
      builder: (context, state) {
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          StaggerRevealV2(index: 1, child: _filterWidget),
                          if (_isDirector) _approveBar(state),
                          const SizedBox(height: 6),
                          _listWidget,
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Bản cũ [WorkTripPage] hiện nút back trên [MyAppBar] mặc định (kể cả khi
  /// [isFromHome] là null) và không có nút chuông thông báo — giữ nguyên.
  Widget _topBar(S s) {
    final showBack = widget.isFromHome ?? true;
    return Row(
      children: [
        if (showBack) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.maybePop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTokensV2.fg,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            s.bt_title,
            style: AppTokensV2.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget get _filterWidget {
    final currentLocale = Localizations.localeOf(context).toLanguageTag();
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<WorkTripCubit, WorkTripState>(
            bloc: _cubit,
            buildWhen:
                (p, c) =>
                    p.startDateFilter != c.startDateFilter ||
                    p.endDateFilter != c.endDateFilter,
            builder: (context, state) {
              String week = '';
              if ((state.startDateFilter ?? '').isNotEmpty) {
                week = '${state.startDateFilter} - ${state.endDateFilter}';
              }
              _searchController.text = week;
              final hasFilter = week.isNotEmpty;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final res = await showModalBottomSheet<DateTimeRange?>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    backgroundColor: Colors.white,
                    builder:
                        (_) => CalendarRangeSheet(
                          initial: selectedWeek,
                          locale: currentLocale,
                        ),
                  );

                  if (res == null) {
                    _searchController.clear();
                    _cubit.onChangeDateFilter('', '');
                    _cubit.getListWorkTrips();
                    return;
                  }

                  selectedWeek = res;
                  _cubit.onChangeDateFilter(
                    _df.format(res.start),
                    _df.format(res.end),
                  );
                  _cubit.getListWorkTrips();
                },
                child: GlassCardV2(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  radius: 15,
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 17,
                          color: AppTokensV2.fgMuted,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            hasFilter ? week : '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                hasFilter
                                    ? AppTokensV2.body.copyWith(fontSize: 13)
                                    : AppTokensV2.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _requestNewTrip,
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

  Widget _approveBar(WorkTripState state) {
    final s = S.of(context);
    final approvableIds =
        (state.listWorkTrips ?? [])
            .where((e) => e.stage?.name == 'Trưởng phòng duyệt')
            .map((e) => e.id)
            .whereType<int>()
            .toSet();

    if (approvableIds.isEmpty) return const SizedBox.shrink();

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
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppTokensV2.accent;
                          }
                          return Colors.transparent;
                        }),
                        checkColor: WidgetStateProperty.all(Colors.white),
                        side: BorderSide(
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
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  '${s.authorize} ${_selectedIds.length}',
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
  }

  Widget get _listWidget {
    final s = S.of(context);

    return BlocBuilder<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.loadDataStatus == LoadStatus.LOADING) {
          return Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppTokensV2.accent,
              ),
            ),
          );
        }

        final list = state.listWorkTrips ?? [];
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Center(
              child: Text(s.bt_empty, style: AppTokensV2.captionStrong),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTokensV2.accent,
          backgroundColor: AppTokensV2.bgTop,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final entity = list[index];
              final stageName = entity.stage?.name ?? '';

              final canSwipe = stageName == 'Nháp' && _selectedIds.isEmpty;

              final card = StaggerRevealV2(
                index: index < 6 ? index : 0,
                child: WorkTripListItemV2(
                  entity: entity,
                  canApprove: _isDirector,
                  isChecked: _selectedIds.contains(entity.id),
                  onCheckedChange:
                      _isDirector
                          ? (v) {
                            setState(() {
                              if (v == true) {
                                _selectedIds.add(entity.id!);
                              } else {
                                _selectedIds.remove(entity.id);
                              }
                            });
                          }
                          : null,
                  onShowDetail: () => _openDetail(entity),
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
                  key: ValueKey(entity.id),
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
                                      "Bạn có muốn gửi duyệt chuyến công tác này không?",
                                  cancelText: "Không",
                                  confirmText: "Ok",
                                  onCancel: () => Navigator.pop(context),
                                  onConfirm: () {
                                    Navigator.pop(context);
                                    _handlingAction = true;
                                    _cubit.onSubmitWorkTrip(entity.id!);
                                  },
                                ),
                          );
                        },
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.send,
                        label: "Gửi duyệt",
                      ),
                      SlidableAction(
                        onPressed: (_) {
                          showDialog(
                            context: context,
                            builder:
                                (_) => CustomDialog(
                                  title: "Xác nhận",
                                  content:
                                      "Bạn có chắc muốn xóa chuyến công tác này?",
                                  cancelText: "Không",
                                  confirmText: "Ok",
                                  onCancel: () => Navigator.pop(context),
                                  onConfirm: () {
                                    Navigator.pop(context);
                                    _handlingAction = true;
                                    _cubit.onDeleteWorkTrip(entity.id!);
                                  },
                                ),
                          );
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: "Xóa",
                      ),
                    ],
                  ),
                  child: card,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
