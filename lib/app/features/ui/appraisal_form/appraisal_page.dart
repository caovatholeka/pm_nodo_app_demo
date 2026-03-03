import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/bloc/appraisal_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/appraisal_list_item.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';
import '../../../data/models/enums/load_status.dart';

class AppraisalPage extends StatefulWidget {
  final bool? isFromHome;
  const AppraisalPage({super.key, this.isFromHome});

  @override
  State<AppraisalPage> createState() => _AppraisalPageState();
}

class _AppraisalPageState extends State<AppraisalPage> {
  final _cubit = GetIt.I.get<AppraisalCubit>();
  final ScrollController controller = ScrollController();
  final TextEditingController filterController = TextEditingController();
  final _df = DateFormat('dd/MM/yyyy');
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    _cubit.getListAppraisals();
  }

  Future<void> _onRefresh() async {
    _cubit.getListAppraisals();
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
      builder: (_) => CalendarRangeSheet(
        initial: selectedRange ?? defaultRange,
        locale: Localizations.localeOf(context).toLanguageTag(),
      ),
    );

    if (res == null) {
      selectedRange = null;
      filterController.clear();
      _cubit.getListAppraisals();
      return;
    }

    selectedRange = res;
    filterController.text =
        "${_df.format(res.start)} - ${_df.format(res.end)}";

    _cubit.getListAppraisals();
  }

  void _goNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
          child: const NotificationPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<AppraisalCubit, AppraisalState>(
      bloc: _cubit,
      listener: (context, state) {},
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
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
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _openCalendar,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: filterController,
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.mainPrimaryColor6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AppraisalCubit, AppraisalState>(
                bloc: _cubit,
                buildWhen: (p, c) =>
                    p.loadStatus != c.loadStatus ||
                    p.listAppraisalEntities != c.listAppraisalEntities,
                builder: (context, state) {
                  if (state.loadStatus == LoadStatus.LOADING) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mainPrimaryColor6,
                      ),
                    );
                  }

                  if (state.listAppraisalEntities == null ||
                      state.listAppraisalEntities!.isEmpty) {
                    return Center(
                      child: Text(S.of(context).bt_empty),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      itemCount: state.listAppraisalEntities!.length,
                      itemBuilder: (_, i) {
                        final e = state.listAppraisalEntities![i];
                        return AppraisalListItem(entity: e);
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