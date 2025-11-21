import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/on_leave/create_new_leave_page.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

import '../../../data/models/entities/on_leave_entity.dart';
import '../../../data/models/enums/load_status.dart';
import '../../widgets/custom_calendar_range_sheet.dart';
import 'bloc/on_leave_cubit.dart';
import 'on_leave_detail_page.dart';
import 'widget/on_leave_list_item.dart';

class OnLeavePage extends StatefulWidget {
  final bool? isFromHome;
  const OnLeavePage({super.key, this.isFromHome});

  @override
  State<OnLeavePage> createState() => _OnLeavePageState();
}

class _OnLeavePageState extends State<OnLeavePage> {
  final _cubit = GetIt.I.get<OnLeaveCubit>();
  ScrollController controller = ScrollController();

  @override
  void initState() {
    _cubit.getListOnLeaveTimes();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  DateTimeRange selectedWeek = _weekOf(DateTime.now());
  final _df = DateFormat('dd/MM/yyyy');

  Future _onRefresh() async {
    _cubit.getListOnLeaveTimes();
  }

  Future<void> _openDetail(OnLeaveEntity entity) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                OnLeaveDetailPage(detailEntity: entity, detailId: entity.id),
      ),
    );
    logger.d("result :: $result");
    if (result != null && result) {
      _onRefresh();
    }
  }

  Future<void> _createNewLeave() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateNewLeavePage()),
    );

    if (result != null && result) {
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        titleAppbar: "Quản lý nghỉ phép",
        haveActionButton: true,
        haveBackButton: (widget.isFromHome ?? false),
        iconPathAsset: AppAssets.icNotificationBell,
        actionCallBack: () {
          _goNotification();
        },
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.appBG2),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 120),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _filterWidget,
                        _listWidget,
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  get _filterWidget {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 8,
          child: InputTextField(
            title: "",
            hintText: "",
            isRequiredField: false,
            disableTitle: true,
            enable: true,
            readOnly: true,
            suffixIcon: AppAssets.icCalendar,
            callback: () async {
              // open custom calendar
              final res = await showModalBottomSheet<DateTimeRange>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                backgroundColor: Colors.white,
                builder:
                    (_) =>
                        CalendarRangeSheet(initial: selectedWeek, locale: "en"),
              );

              if (res != null) {
                selectedWeek = res;
                // String week = selectedWeek.toYmdLabel();
                String start = _df.format(selectedWeek.start);
                String end = _df.format(selectedWeek.end);
                if (start != end) {
                  _cubit.onChangeDateFilter(start, end);
                } else {
                  _cubit.onChangeDateFilter("", "");
                }
                // call api search
                _cubit.getListOnLeaveTimes();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              _createNewLeave();
            },
            child: Container(
              height: 44,
              width: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: AppColors.mainPrimaryColor6,
              ),
              child: Center(
                child: Icon(Icons.add, color: AppColors.whiteColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  get _listWidget {
    return BlocBuilder<OnLeaveCubit, OnLeaveState>(
      bloc: _cubit,
      buildWhen:
          (prev, cur) =>
              prev.loadStatus != cur.loadStatus ||
              prev.listLeaveEntities != cur.listLeaveEntities,
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.LOADING) {
          return Center(child: CircularProgressIndicator());
        }
        if ((state.listLeaveEntities ?? []).isEmpty) {
          return Center(child: Text("Không có dữ liệu").paddingOnly(top: 100));
        } else {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              shrinkWrap: true,
              controller: controller,
              itemCount: (state.listLeaveEntities ?? []).length,
              itemBuilder: (context, index) {
                OnLeaveEntity entity = (state.listLeaveEntities ?? [])[index];
                return OnLeaveListItem(
                  entity: entity,
                  onShowDetail: () {
                    _openDetail(entity);
                  },
                ).paddingOnly(bottom: 20);
              },
            ),
          );
        }
      },
    );
  }
}
