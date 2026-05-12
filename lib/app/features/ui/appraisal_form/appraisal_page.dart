import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/create_appraisal_page.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/apprasial_form_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/detail_appraisal_form.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/appraisal_list_item.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

class AppraisalPage extends StatefulWidget {
  final bool? isFromHome;

  const AppraisalPage({super.key, this.isFromHome});

  @override
  State<AppraisalPage> createState() => _AppraisalPageState();
}

class _AppraisalPageState extends State<AppraisalPage> {
  final _cubit = GetIt.I.get<ApprasialFormCubit>();
  final ScrollController controller = ScrollController();
  final TextEditingController filterController = TextEditingController();
  final _df = DateFormat('dd/MM/yyyy');
  bool _isHrApproveAction = false;

  DateTimeRange? selectedRange;

  bool get _isDirector {
    final jobTitle = context.read<AppCubit>().state.userProfile?.jobTitle ?? '';
    return jobTitle.toLowerCase().contains('giám đốc');
  }

  bool get _isHr {
    final profile = context.read<AppCubit>().state.userProfile;
    final jobTitle = profile?.jobTitle?.toLowerCase() ?? '';
    final departmentName = profile?.department?.name?.toLowerCase() ?? '';

    return jobTitle.contains('hr') ||
        jobTitle.contains('nhân sự') ||
        jobTitle.contains('hành chính nhân sự') ||
        departmentName.contains('nhân sự') ||
        departmentName.contains('hành chính nhân sự');
  }

  @override
  void initState() {
    super.initState();
    _cubit.getListEvaluation();
  }

  Future<void> _onRefresh() async {
    final state = _cubit.state;

    await _cubit.getListEvaluation(
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
            initial: selectedRange ?? defaultRange,
            locale: Localizations.localeOf(context).toLanguageTag(),
          ),
    );

    if (res == null) {
      selectedRange = null;
      filterController.clear();

      _cubit.onChangeDateFilter('', '');
      _cubit.getListEvaluation(dateFrom: '', dateTo: '');
      return;
    }

    selectedRange = res;

    final start = _df.format(res.start);
    final end = _df.format(res.end);

    filterController.text = '$start - $end';

    _cubit.onChangeDateFilter(start, end);
    _cubit.getListEvaluation(dateFrom: start, dateTo: end);
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

  Future<void> _openCreateAppraisal() async {
    final created = await Navigator.push<EvaluationEntity?>(
      context,
      MaterialPageRoute(builder: (_) => const CreateAppraisalPage()),
    );
    if (created != null) {
      if (created.id != null) {
        _cubit.upsertEvaluation(created);
        unawaited(_cubit.refreshEvaluationById(created.id!));
      } else {
        await _onRefresh();
      }
    }
  }

  Future<void> _openDetailAppraisal(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailAppraisalForm(isDetail: true, evaluationId: id),
      ),
    );
  }

  Future<void> _openManagerAssessAppraisal(int id) async {
    final updated = await Navigator.push<EvaluationEntity?>(
      context,
      MaterialPageRoute(
        builder:
            (_) => DetailAppraisalForm(
              isEdit: true,
              isManagerAssess: true,
              evaluationId: id,
            ),
      ),
    );

    if (updated == null) return;

    _cubit.upsertEvaluation(updated);
    if (updated.id != null) {
      unawaited(_cubit.refreshEvaluationById(updated.id!));
    }
  }

  Future<void> _showSubmitDialog(int id) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => CustomDialog(
            title: 'Xác nhận',
            content: 'Bạn có chắc muốn gửi phiếu đánh giá này không?',
            confirmText: 'Đồng ý',
            cancelText: 'Hủy',
            onConfirm: () {
              Navigator.pop(context);
              _isHrApproveAction = false;
              _cubit.sendforConfirm(id);
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  Future<void> _showApproveDialog(int id) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => CustomDialog(
            title: 'Xác nhận',
            content:
                'Bạn có chắc muốn duyệt hoàn thành phiếu đánh giá này không?',
            confirmText: 'Đồng ý',
            cancelText: 'Hủy',
            onConfirm: () {
              Navigator.pop(context);
              _isHrApproveAction = true;
              _cubit.approveEvaluation(id);
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: MyAppBar(
          titleAppbar: s.appraisal_list_title,
          haveBackButton: true,
          haveActionButton: true,
          iconPathAsset: AppAssets.icNotificationBell,
          actionCallBack: _goNotification,
        ),
      ),
      body: BlocListener<ApprasialFormCubit, ApprasialFormState>(
        bloc: _cubit,
        listenWhen:
            (previous, current) =>
                previous.loadSubmitStatus != current.loadSubmitStatus,
        listener: (context, state) {
          if (state.loadSubmitStatus == LoadStatus.SUCCESS) {
            Flushbar(
              message:
                  _isHrApproveAction
                      ? 'Duyệt hoàn thành thành công'
                      : 'Gửi phiếu thành công',
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.colorCompliant,
              flushbarPosition: FlushbarPosition.TOP,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              margin: const EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(8),
            ).show(context);
            _isHrApproveAction = false;
            unawaited(_onRefresh());
          }

          if (state.loadSubmitStatus == LoadStatus.FAILURE) {
            Flushbar(
              message:
                  _isHrApproveAction
                      ? 'Duyệt hoàn thành thất bại hoặc bạn không có quyền thực hiện'
                      : 'Gửi phiếu thất bại hoặc bạn không có quyền thực hiện',
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.colorCancel,
              flushbarPosition: FlushbarPosition.TOP,
              margin: const EdgeInsets.all(8),
              icon: const Icon(Icons.error, color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ).show(context);
            _isHrApproveAction = false;
          }
        },
        child: Column(
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
                  GestureDetector(
                    onTap: _openCreateAppraisal,
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
              child: BlocBuilder<ApprasialFormCubit, ApprasialFormState>(
                bloc: _cubit,
                buildWhen:
                    (p, c) =>
                        p.loadDataStatus != c.loadDataStatus ||
                        p.listEvaluations != c.listEvaluations,
                builder: (context, state) {
                  if (state.loadDataStatus == LoadStatus.LOADING) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mainPrimaryColor6,
                      ),
                    );
                  }

                  if (state.listEvaluations == null ||
                      state.listEvaluations!.isEmpty) {
                    return Center(child: Text(s.bt_empty));
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      itemCount: state.listEvaluations!.length,
                      itemBuilder: (_, i) {
                        final e = state.listEvaluations![i];
                        final canSlideDraft =
                            e.id != null && e.state == 'draft';
                        final canSlideManagerAssess =
                            e.id != null &&
                            e.state == 'director_confirm' &&
                            _isDirector;
                        final canSlideHrApprove =
                            e.id != null && e.state == 'hr_confirm' && _isHr;

                        final card = AppraisalListItem(
                          entity: e,
                          onTap: (entity) {
                            if (entity.id == null) return;
                            _openDetailAppraisal(entity.id!);
                          },
                        );

                        if (!canSlideDraft &&
                            !canSlideManagerAssess &&
                            !canSlideHrApprove) {
                          return card;
                        }

                        return Slidable(
                          key: ValueKey(e.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.24,
                            children: [
                              if (canSlideDraft)
                                SlidableAction(
                                  onPressed: (_) => _showSubmitDialog(e.id!),
                                  backgroundColor: AppColors.colorCompliant,
                                  foregroundColor: Colors.white,
                                  icon: Icons.send_rounded,
                                  label: 'Gửi',
                                ),
                              if (canSlideManagerAssess)
                                SlidableAction(
                                  onPressed:
                                      (_) => _openManagerAssessAppraisal(e.id!),
                                  backgroundColor: const Color(0xFF0A84FF),
                                  foregroundColor: Colors.white,
                                  icon: Icons.fact_check_rounded,
                                  label: 'Đánh giá',
                                ),
                              if (canSlideHrApprove)
                                SlidableAction(
                                  onPressed: (_) => _showApproveDialog(e.id!),
                                  backgroundColor: AppColors.colorApproved,
                                  foregroundColor: Colors.white,
                                  icon: Icons.verified_rounded,
                                  label: 'Duyệt',
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
