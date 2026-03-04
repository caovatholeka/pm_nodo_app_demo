import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/data/models/param/approve_ob_param.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/work_trip/request_new_trip_page.dart';
import 'package:pm_app/app/features/ui/work_trip/widget/work_trip_list_item.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_cubit.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_detail_page.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../data/models/enums/load_status.dart';
import '../../widgets/custom_calendar_range_sheet.dart';
import '../../widgets/input_text_field.dart';

class WorkTripPage extends StatefulWidget {
  final bool? isFromHome;
  const WorkTripPage({super.key, this.isFromHome});

  @override
  State<WorkTripPage> createState() => _WorkTripPageState();
}

class _WorkTripPageState extends State<WorkTripPage> {
  final _cubit = GetIt.I<WorkTripCubit>();

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
            (_) => WorkTripDetailPage(workEntity: entity, workId: entity.id),
      ),
    );

    if (result == true) {
      _onRefresh();
    }
  }

  Future<void> _requestNewTrip() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RequestNewTripPage()),
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
        if (state.deleteStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          AppSnackBar.showInfo(title: s.success, message: s.bt_delete_success);

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

          _selectedIds.clear();
          _cubit.onResetStatus();
          _cubit.getListWorkTrips();
          setState(() {});
          return;
        }

        if (state.cancelStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          AppSnackBar.showInfo(title: s.success, message: s.bt_confirm_deny);

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
          LoadingOverlay.show(context);
        } else {
          LoadingOverlay.hide(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bodyColor,
          appBar: MyAppBar(
            titleAppbar: s.bt_title,
            haveBackButton: widget.isFromHome ?? true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _filterWidget,
                if (_isDirector) _approveBar(state),
                _listWidget,
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget get _filterWidget {
    final currentLocale = Localizations.localeOf(context).toLanguageTag();
    return Row(
      children: [
        Expanded(
          flex: 8,
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

              return InputTextField(
                title: '',
                isRequiredField: false,
                hintText: '',
                disableTitle: true,
                readOnly: true,
                controller: _searchController..text = week,
                suffixIcon: AppAssets.icCalendar,
                callback: () async {
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
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: _requestNewTrip,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.mainPrimaryColor6,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
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
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  if (!isAllChecked) {
                    _selectedIds
                      ..clear()
                      ..addAll(approvableIds);
                  } else {
                    _selectedIds.clear();
                  }
                });
              },
              child: Row(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      checkboxTheme: CheckboxThemeData(
                        side: BorderSide(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Checkbox(
                      value: isAllChecked,
                      activeColor: AppColors.mainPrimaryColor6,
                      checkColor: Colors.white,
                      onChanged: (v) {
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
                    ),
                  ),
                  const SizedBox(width: 0.5),
                  Text(
                    s.choose_all,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _selectedIds.isEmpty ? null : _approveSelected,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainPrimaryColor6,
                disabledBackgroundColor: AppColors.mainPrimaryColor6
                    .withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                '${s.authorize} ${_selectedIds.length}',
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
  }

  Widget get _listWidget {
    final s = S.of(context);

    return BlocBuilder<WorkTripCubit, WorkTripState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.loadDataStatus == LoadStatus.LOADING) {
          return const Padding(
            padding: EdgeInsets.only(top: 40),
            child: CircularProgressIndicator(),
          );
        }

        final list = state.listWorkTrips ?? [];
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Center(child: Text(s.bt_empty)),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final entity = list[index];
              final stageName = entity.stage?.name ?? '';

              final isFinished = stageName == 'Hoàn thành';
              final isCanceled = stageName == 'Hủy';

              final canSwipe =
                  !isFinished && !isCanceled && _selectedIds.isEmpty;

              final card = WorkTripListItem(
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
