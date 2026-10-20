import 'dart:async';

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
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/apprasial_form_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/detail_appraisal_form_v2.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/generated/l10n.dart';

import 'widget/appraisal_list_item_v2.dart';

/// Màn Đánh giá — phiên bản giao diện tối (v2). Giữ nguyên nội dung/hành vi
/// bản cũ [AppraisalPage]: lọc theo khoảng ngày, tạo phiếu, gửi/duyệt/đánh
/// giá theo trạng thái + quyền (Giám đốc/HR), mở chi tiết. Tái dùng
/// [ApprasialFormCubit] qua GetIt y hệt bản cũ (không tạo mới, không đóng).
///
/// Điều hướng tạo/sửa/xem chi tiết/đánh giá đã được nối sang
/// [DetailAppraisalFormV2] (bản tối, thay cho `CreateAppraisalPage`/
/// `DetailAppraisalForm` gốc) — `CreateAppraisalPage` gốc chỉ là wrapper trả
/// về `DetailAppraisalForm()` nên được thay trực tiếp bằng
/// `const DetailAppraisalFormV2()`.
class AppraisalPageV2 extends StatefulWidget {
  final bool? isFromHome;

  const AppraisalPageV2({super.key, this.isFromHome});

  @override
  State<AppraisalPageV2> createState() => _AppraisalPageV2State();
}

class _AppraisalPageV2State extends State<AppraisalPageV2> {
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

  @override
  void dispose() {
    filterController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final state = _cubit.state;

    await _cubit.getListEvaluation(
      dateFrom: state.startDateFilter,
      dateTo: state.endDateFilter,
    );
  }

  Future<void> _openCalendar() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final defaultRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );

    final res = await showModalBottomSheet<DateTimeRange?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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
    HapticFeedback.selectionClick();
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
    HapticFeedback.selectionClick();
    final created = await Navigator.push<EvaluationEntity?>(
      context,
      MaterialPageRoute(builder: (_) => const DetailAppraisalFormV2()),
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
        builder:
            (_) => DetailAppraisalFormV2(isDetail: true, evaluationId: id),
      ),
    );
  }

  Future<void> _openEditAppraisal(int id) async {
    final updated = await Navigator.push<EvaluationEntity?>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailAppraisalFormV2(isEdit: true, evaluationId: id),
      ),
    );

    if (updated == null) return;

    _cubit.upsertEvaluation(updated);
    if (updated.id != null) {
      unawaited(_cubit.refreshEvaluationById(updated.id!));
    }
  }

  Future<void> _openManagerAssessAppraisal(int id) async {
    final updated = await Navigator.push<EvaluationEntity?>(
      context,
      MaterialPageRoute(
        builder:
            (_) => DetailAppraisalFormV2(
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

    return BlocListener<ApprasialFormCubit, ApprasialFormState>(
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
            backgroundColor: AppTokensV2.success,
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
            backgroundColor: AppTokensV2.danger,
            flushbarPosition: FlushbarPosition.TOP,
            margin: const EdgeInsets.all(8),
            icon: const Icon(Icons.error, color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
          _isHrApproveAction = false;
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
                const SizedBox(height: 6),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _listWidget(s),
                  ),
                ),
              ],
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
            s.appraisal_list_title,
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
            child: Icon(
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
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 17,
                      color: AppTokensV2.fgMuted,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: filterController,
                        builder: (context, value, _) {
                          final hasFilter = value.text.isNotEmpty;
                          return Text(
                            hasFilter ? value.text : S.of(context).calendar_title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                hasFilter
                                    ? AppTokensV2.body.copyWith(fontSize: 13)
                                    : AppTokensV2.caption,
                          );
                        },
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
          onTap: _openCreateAppraisal,
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

  Widget _listWidget(S s) {
    return BlocBuilder<ApprasialFormCubit, ApprasialFormState>(
      bloc: _cubit,
      buildWhen:
          (p, c) =>
              p.loadDataStatus != c.loadDataStatus ||
              p.listEvaluations != c.listEvaluations,
      builder: (context, state) {
        if (state.loadDataStatus == LoadStatus.LOADING) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppTokensV2.accent,
            ),
          );
        }

        if (state.listEvaluations == null || state.listEvaluations!.isEmpty) {
          return Center(
            child: Text(s.bt_empty, style: AppTokensV2.captionStrong),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTokensV2.accent,
          backgroundColor: AppTokensV2.bgTop,
          child: ListView.builder(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 16, bottom: 120),
            itemCount: state.listEvaluations!.length,
            itemBuilder: (_, i) {
              final e = state.listEvaluations![i];
              final canSlideDraft = e.id != null && e.state == 'draft';
              final canSlideManagerAssess =
                  e.id != null &&
                  e.state == 'director_confirm' &&
                  _isDirector;
              final canSlideHrApprove =
                  e.id != null && e.state == 'hr_confirm' && _isHr;

              final card = StaggerRevealV2(
                index: i < 6 ? i : 0,
                child: AppraisalListItemV2(
                  entity: e,
                  onTap: (entity) {
                    if (entity.id == null) return;
                    _openDetailAppraisal(entity.id!);
                  },
                ),
              );

              if (!canSlideDraft && !canSlideManagerAssess && !canSlideHrApprove) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: card,
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Slidable(
                  key: ValueKey(e.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: canSlideDraft ? 0.48 : 0.24,
                    children: [
                      if (canSlideDraft)
                        SlidableAction(
                          onPressed: (_) => _openEditAppraisal(e.id!),
                          backgroundColor: AppTokensV2.accent,
                          foregroundColor: Colors.white,
                          icon: Icons.edit_rounded,
                          label: 'Sửa',
                        ),
                      if (canSlideDraft)
                        SlidableAction(
                          onPressed: (_) => _showSubmitDialog(e.id!),
                          backgroundColor: AppTokensV2.success,
                          foregroundColor: Colors.white,
                          icon: Icons.send_rounded,
                          label: 'Gửi',
                        ),
                      if (canSlideManagerAssess)
                        SlidableAction(
                          onPressed: (_) => _openManagerAssessAppraisal(e.id!),
                          backgroundColor: AppTokensV2.accent,
                          foregroundColor: Colors.white,
                          icon: Icons.fact_check_rounded,
                          label: 'Đánh giá',
                        ),
                      if (canSlideHrApprove)
                        SlidableAction(
                          onPressed: (_) => _showApproveDialog(e.id!),
                          backgroundColor: AppTokensV2.success,
                          foregroundColor: Colors.white,
                          icon: Icons.verified_rounded,
                          label: 'Duyệt',
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
