import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/on_leave/create_new_leave_page.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../data/models/entities/on_leave_entity.dart';
import '../../../data/models/enums/load_status.dart';
import '../../widgets/custom_calendar_range_sheet.dart';
import 'bloc/on_leave_cubit.dart';
import 'on_leave_detail_page.dart';
import 'widget/on_leave_list_item.dart';

const int kManagerApproveStatusId = 14;

class OnLeavePage extends StatefulWidget {
  final bool? isFromHome;
  const OnLeavePage({super.key, this.isFromHome});

  @override
  State<OnLeavePage> createState() => _OnLeavePageState();
}

class _OnLeavePageState extends State<OnLeavePage> {
  final _cubit = GetIt.I.get<OnLeaveCubit>();
  final Set<int> selectedIds = {};
  final ScrollController controller = ScrollController();

  final TextEditingController filterController = TextEditingController();

  DateTimeRange selectedWeek = _weekOf(DateTime.now());
  final _df = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _cubit.onChangeDateFilter("", "");
    _cubit.getListOnLeaveTimes();
    filterController.clear();
  }

  bool get isDirector {
    final jobTitle = context.read<AppCubit>().state.userProfile?.jobTitle ?? "";
    return jobTitle.toLowerCase().contains("giám đốc");
  }

  static DateTime _mondayOf(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return x.subtract(Duration(days: x.weekday - 1));
  }

  static DateTimeRange _weekOf(DateTime d) {
    final start = _mondayOf(d);
    return DateTimeRange(start: start, end: start.add(const Duration(days: 6)));
  }

  Future<void> _onRefresh() async {
    _cubit.getListOnLeaveTimes();
  }

  void _approveSelected() {
    logger.d("Approve leave ids: $selectedIds");
    // TODO: call approve API
    setState(() {
      selectedIds.clear();
    });
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

  Future<void> _openDetail(OnLeaveEntity entity) async {
    if (selectedIds.isNotEmpty) return;

    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => OnLeaveDetailPage(detailEntity: entity, detailId: entity.id),
      ),
    );

    if (result == true) {
      _onRefresh();
    }
  }

  Future<void> _createNewLeave() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateNewLeavePage()),
    );

    if (result == true) {
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<AppCubit, AppState>(
          buildWhen: (p, c) => p.totalUnread != c.totalUnread,
          builder: (context, appState) {
            return MyAppBar(
              titleAppbar: s.day_off_title,
              haveBackButton: widget.isFromHome ?? false,
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
            child: _filterWidget,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _bulkActionWidget,
          ),
          const SizedBox(height: 5,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _listWidget,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _filterWidget {
    return BlocBuilder<OnLeaveCubit, OnLeaveState>(
      bloc: _cubit,
      buildWhen:
          (p, c) =>
              p.startDateFilter != c.startDateFilter ||
              p.endDateFilter != c.endDateFilter,
      builder: (context, state) {
        final week =
            (state.startDateFilter ?? "").isNotEmpty
                ? "${state.startDateFilter} - ${state.endDateFilter}"
                : "";

        return Row(
          children: [
            Expanded(
              flex: 8,
              child: InputTextField(
                disableTitle: true,
                hintText: "",
                isRequiredField: false,
                readOnly: true,
                controller: filterController..text = week,
                suffixIcon: AppAssets.icCalendar,
                callback: () async {
                  final res = await showModalBottomSheet<DateTimeRange?>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder:
                        (_) => CalendarRangeSheet(
                          initial: selectedWeek,
                          locale: "en",
                        ),
                  );

                  if (res == null) {
                    filterController.clear();
                    _cubit.onChangeDateFilter("", "");
                  } else {
                    selectedWeek = res;
                    _cubit.onChangeDateFilter(
                      _df.format(res.start),
                      _df.format(res.end),
                    );
                  }

                  _cubit.getListOnLeaveTimes();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: _createNewLeave,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.mainPrimaryColor6,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget get _bulkActionWidget {
    if(!isDirector) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<OnLeaveCubit, OnLeaveState>(
      bloc: _cubit,
      builder: (context, state) {
        final list = state.listLeaveEntities ?? [];

        final approvableIds =
            list
                .where((e) => e.leaveStage?.id == kManagerApproveStatusId)
                .map((e) => e.id)
                .whereType<int>()
                .toSet();

        if (approvableIds.isEmpty) {
          return const SizedBox.shrink();
        }

        final isAllChecked =
            selectedIds.isNotEmpty && selectedIds.containsAll(approvableIds);

        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      checkboxTheme: CheckboxThemeData(
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.mainPrimaryColor6; 
                          }
                          return Colors.transparent;
                        }),
                        checkColor: WidgetStateProperty.all(Colors.white),
                        side: const BorderSide(color: Colors.grey, width: 1.2),
                      ),
                    ),
                    child: Checkbox(
                      value: isAllChecked,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedIds
                              ..clear()
                              ..addAll(approvableIds);
                          } else {
                            selectedIds.clear();
                          }
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text("Chọn tất cả"),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: selectedIds.isEmpty ? null : _approveSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainPrimaryColor6,
                  disabledBackgroundColor: AppColors.mainPrimaryColor6
                      .withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  "Duyệt (${selectedIds.length})",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget get _listWidget {
    return BlocBuilder<OnLeaveCubit, OnLeaveState>(
      bloc: _cubit,
      buildWhen:
          (p, c) =>
              p.loadStatus != c.loadStatus ||
              p.listLeaveEntities != c.listLeaveEntities,
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.LOADING) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = state.listLeaveEntities ?? [];
        if (list.isEmpty) {
          return Center(child: Text(S.of(context).bt_empty));
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 20),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final e = list[i];
              return OnLeaveListItem(
                entity: e,
                isChecked: selectedIds.contains(e.id),
                showCheckbox: false,
                onCheckedChanged: (v) {
                  setState(() {
                    if (v == true) {
                      selectedIds.add(e.id!);
                    } else {
                      selectedIds.remove(e.id);
                    }
                  });
                },
                onShowDetail: () => _openDetail(e),
              ).paddingOnly(bottom: 12);
            },
          ),
        );
      },
    );
  }
}
