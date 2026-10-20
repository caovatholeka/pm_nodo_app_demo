import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/evaluation_repository.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/detail_apprasial_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/apprasisal_progress_page_v2.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn hình thông tin chung (shell) của phiếu đánh giá — bản tối (v2). Chỉ
/// đổi trình bày: cùng cubit [CreateAppraisalCubit], cùng luồng init theo
/// [isManagerAssess]/[isHrReview]/[isDetail]/[isEdit], cùng payload validate.
/// Điều hướng sang [ApprasisalProgressPageV2] (bản tối) thay vì bản gốc.
class DetailAppraisalFormV2 extends StatefulWidget {
  final bool isDetail;
  final bool isEdit;
  final bool isHrReview;
  final bool isManagerAssess;
  final int? evaluationId;

  const DetailAppraisalFormV2({
    super.key,
    this.isDetail = false,
    this.isEdit = false,
    this.isHrReview = false,
    this.isManagerAssess = false,
    this.evaluationId,
  });

  @override
  State<DetailAppraisalFormV2> createState() => _DetailAppraisalFormV2State();
}

class _DetailAppraisalFormV2State extends State<DetailAppraisalFormV2> {
  late final CreateAppraisalCubit _cubit;
  bool _didFillDetail = false;
  final _displayDateFormat = DateFormat('MM/yyyy');

  final _createdDateCtrl = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  );

  final _employeeCodeCtrl = TextEditingController();
  final _employeeNameCtrl = TextEditingController();

  final _fromDateCtrl = TextEditingController();
  final _toDateCtrl = TextEditingController();

  final _noteCtrl = TextEditingController();
  final _managerNameCtrl = TextEditingController();
  final profile = GlobalData.instance.userProfile;
  final _deprtmentCtrl = TextEditingController();

  LocaleType get _pickerLocale =>
      Localizations.localeOf(context).languageCode == 'en'
          ? LocaleType.en
          : LocaleType.vi;

  DateTime _pickerDateOf(TextEditingController controller) {
    return AppDateUtils.parseFlexibleDate(controller.text) ?? DateTime.now();
  }

  Future<void> _showYearMonthPicker({
    required TextEditingController controller,
    required ValueChanged<DateTime> onConfirm,
  }) async {
    final initial = _pickerDateOf(controller);

    await DatePicker.showPicker(
      context,
      showTitleActions: true,
      locale: _pickerLocale,
      pickerModel: _YearMonthPicker(
        currentTime: DateTime(initial.year, initial.month, 1),
        minTime: DateTime(2015, 1, 1),
        maxTime: DateTime(2035, 12, 31),
        locale: _pickerLocale,
      ),
      onConfirm: onConfirm,
    );
  }

  @override
  void initState() {
    super.initState();

    _cubit = CreateAppraisalCubit(repository: GetIt.I<EvaluationRepository>());

    if (widget.isManagerAssess) {
      _cubit.initManagerAssess();
      _fillProfileDefaults();

      if (widget.evaluationId != null) {
        _cubit.getEvaluationDetails(widget.evaluationId!);
      }
    } else if (widget.isHrReview) {
      _cubit.initHrReview();
      _fillProfileDefaults();

      if (widget.evaluationId != null) {
        _cubit.getEvaluationDetails(widget.evaluationId!);
      }
    } else if (widget.isDetail) {
      _cubit.initDetail();
      _fillProfileDefaults();

      if (widget.evaluationId != null) {
        _cubit.getEvaluationDetails(widget.evaluationId!);
      }
    } else if (widget.isEdit) {
      _cubit.initEdit();
      _fillProfileDefaults();

      if (widget.evaluationId != null) {
        _cubit.getEvaluationDetails(widget.evaluationId!);
      }
    } else {
      _cubit.initCreate();

      final profile = GlobalData.instance.userProfile;

      if (profile != null) {
        _employeeCodeCtrl.text = profile.employeeCode ?? "";
        _employeeNameCtrl.text = profile.name ?? "";
        _deprtmentCtrl.text = profile.department?.name ?? "";
        _managerNameCtrl.text = profile.manager?.name ?? "";
      }
    }
  }

  @override
  void dispose() {
    _createdDateCtrl.dispose();
    _employeeCodeCtrl.dispose();
    _employeeNameCtrl.dispose();
    _fromDateCtrl.dispose();
    _toDateCtrl.dispose();
    _noteCtrl.dispose();
    _managerNameCtrl.dispose();
    _deprtmentCtrl.dispose();
    super.dispose();
  }

  void _pickFromDate() {
    _showYearMonthPicker(
      controller: _fromDateCtrl,
      onConfirm: (d) {
        _fromDateCtrl.text = _displayDateFormat.format(d);
        _toDateCtrl.clear();
        _cubit.setFromDate(d);
      },
    );
  }

  void _pickToDate() {
    _showYearMonthPicker(
      controller: _toDateCtrl,
      onConfirm: (d) {
        _toDateCtrl.text = _displayDateFormat.format(d);
        _cubit.setToDate(d);
      },
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

  void _fillProfileDefaults() {
    final userProfile = GlobalData.instance.userProfile;
    if (userProfile == null) return;

    if (_employeeCodeCtrl.text.trim().isEmpty) {
      _employeeCodeCtrl.text = userProfile.employeeCode ?? "";
    }
    if (_employeeNameCtrl.text.trim().isEmpty) {
      _employeeNameCtrl.text = userProfile.name ?? "";
    }
    if (_deprtmentCtrl.text.trim().isEmpty) {
      _deprtmentCtrl.text = userProfile.department?.name ?? "";
    }
    if (_managerNameCtrl.text.trim().isEmpty) {
      _managerNameCtrl.text = userProfile.manager?.name ?? "";
    }
  }

  void _progressNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: _cubit,
              child: const ApprasisalProgressPageV2(),
            ),
      ),
    );
  }

  void _fillDetail(CreateAppraisalState state) {
    final e = state.detailEvaluation;
    if (e == null) return;

    _employeeCodeCtrl.text =
        (e.employeeCode?.trim().isNotEmpty ?? false)
            ? e.employeeCode!
            : (GlobalData.instance.userProfile?.employeeCode ?? "");
    _employeeNameCtrl.text =
        (e.employeeName?.trim().isNotEmpty ?? false)
            ? e.employeeName!
            : (GlobalData.instance.userProfile?.name ?? "");
    _deprtmentCtrl.text =
        (e.departmentName?.trim().isNotEmpty ?? false)
            ? e.departmentName!
            : (GlobalData.instance.userProfile?.department?.name ?? "");

    _managerNameCtrl.text =
        GlobalData.instance.userProfile?.manager?.name ?? "";

    if (e.dateFrom != null) {
      final d = AppDateUtils.parseFlexibleDate(e.dateFrom);
      _fromDateCtrl.text = AppDateUtils.formatFlexibleDateForDisplay(
        e.dateFrom,
        datePattern: _displayDateFormat.pattern!,
      );
      if (d != null) {
        _cubit.setFromDate(d);
      }
    }

    if (e.dateTo != null) {
      final d = AppDateUtils.parseFlexibleDate(e.dateTo);
      _toDateCtrl.text = AppDateUtils.formatFlexibleDateForDisplay(
        e.dateTo,
        datePattern: _displayDateFormat.pattern!,
      );
      if (d != null) {
        _cubit.setToDate(d);
      }
    }

    _noteCtrl.text = e.note ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<CreateAppraisalCubit, CreateAppraisalState>(
        listenWhen: (prev, cur) => prev.loadDetail != cur.loadDetail,
        listener: (context, state) {
          if (state.loadDetail == LoadStatus.SUCCESS && !_didFillDetail) {
            _fillDetail(state);
            _didFillDetail = true;
          }
        },
        child: BlocBuilder<CreateAppraisalCubit, CreateAppraisalState>(
          builder: (context, state) {
            if (!_didFillDetail && state.detailEvaluation != null) {
              _fillDetail(state);
              _didFillDetail = true;
            } else if (widget.isDetail || widget.isEdit) {
              _fillProfileDefaults();
            }

            return Scaffold(
              backgroundColor: AppTokensV2.bgDeep,
              body: AmbientBackgroundV2(
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                        child: _topBarV2(s),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 140),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTokensV2.surfaceStrong,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTokensV2.border),
                            ),
                            child: Column(
                              children: [
                                InputTextField(
                                  title: s.appraisal_employee_code,
                                  hintText: '',
                                  isRequiredField: widget.isDetail != true,
                                  controller: _employeeCodeCtrl,
                                  readOnly: true,
                                  fillBgColor: AppTokensV2.surface,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppTokensV2.fg,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                InputTextField(
                                  title: s.appraisal_employee_name,
                                  hintText: '',
                                  isRequiredField: widget.isDetail != true,
                                  controller: _employeeNameCtrl,
                                  readOnly: true,
                                  fillBgColor: AppTokensV2.surface,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppTokensV2.fg,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                InputTextField(
                                  hintText: s.employee_card_department,
                                  isRequiredField: widget.isDetail != true,
                                  title: s.employee_card_department,
                                  controller: _deprtmentCtrl,
                                  readOnly: true,
                                  fillBgColor: AppTokensV2.surface,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppTokensV2.fg,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InputTextField(
                                        title: s.day_off_from,
                                        hintText: '',
                                        isRequiredField: widget.isDetail != true,
                                        controller: _fromDateCtrl,
                                        readOnly: true,
                                        suffixIcon: AppAssets.icCalendar,
                                        fillBgColor: AppTokensV2.surface,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppTokensV2.fg,
                                        ),
                                        callback:
                                            state.isDetail == true
                                                ? null
                                                : _pickFromDate,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: InputTextField(
                                        title: s.day_off_to,
                                        hintText: '',
                                        isRequiredField: widget.isDetail != true,
                                        controller: _toDateCtrl,
                                        readOnly: true,
                                        suffixIcon: AppAssets.icCalendar,
                                        fillBgColor: AppTokensV2.surface,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppTokensV2.fg,
                                        ),
                                        callback:
                                            state.isDetail == true
                                                ? null
                                                : _pickToDate,
                                      ),
                                    ),
                                  ],
                                ),
                                if (state.fromDate != null &&
                                    state.toDate != null &&
                                    !state.isDateRangeValid) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Text(
                                        'Từ ngày không được lớn hơn đến ngày',
                                        style: TextStyle(
                                          color: AppTokensV2.danger,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                // InputTextField(
                                //   title: s.appraisal_direct_manager,
                                //   hintText: '',
                                //   isRequiredField: widget.isDetail != true,
                                //   controller: _managerNameCtrl,
                                //   readOnly: true,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomSheet: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _ContinueButtonV2(
                    label: s.appraisal_continue,
                    enable:
                        state.isDetail == true
                            ? state.loadDetail == LoadStatus.SUCCESS
                            : state.isFormValid,
                    isLoading: state.isSubmitting,
                    onTap: _progressNext,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topBarV2(S s) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.maybePop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.isDetail == true
                ? "Chi tiết phiếu đánh giá"
                : (widget.isManagerAssess || widget.isEdit)
                ? "Cấp trên đánh giá"
                : s.appraisal_create_title,
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
}

/// Nút "Tiếp tục" — tái tạo trạng thái enable/disable/loading của
/// `PrimaryButton` gốc, tông màu tối.
class _ContinueButtonV2 extends StatelessWidget {
  final String label;
  final bool enable;
  final bool isLoading;
  final VoidCallback onTap;

  const _ContinueButtonV2({
    required this.label,
    required this.enable,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canPress = enable && !isLoading;

    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap:
              canPress
                  ? () {
                    HapticFeedback.selectionClick();
                    onTap();
                  }
                  : null,
          child: Container(
            decoration: BoxDecoration(
              gradient: canPress ? AppTokensV2.accentGradient : null,
              color: canPress ? null : AppTokensV2.surfaceStrong,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                      : Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: canPress ? Colors.white : AppTokensV2.fgMuted,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

class _YearMonthPicker extends CommonPickerModel {
  _YearMonthPicker({
    required DateTime currentTime,
    DateTime? minTime,
    DateTime? maxTime,
    super.locale,
  }) {
    this.currentTime = currentTime;
    this.minTime = minTime ?? DateTime(2000, 1, 1);
    this.maxTime = maxTime ?? DateTime(2100, 12, 31);

    setLeftIndex(currentTime.year - this.minTime.year);
    setMiddleIndex(currentTime.month - 1);
    setRightIndex(0);
  }

  late DateTime minTime;
  late DateTime maxTime;

  @override
  String? leftStringAtIndex(int index) {
    final year = minTime.year + index;
    if (year < minTime.year || year > maxTime.year) return null;
    return '$year';
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index < 0 || index > 11) return null;
    final month = index + 1;
    return month.toString().padLeft(2, '0');
  }

  @override
  String? rightStringAtIndex(int index) => '';

  @override
  List<int> layoutProportions() => [2, 2, 0];

  @override
  String leftDivider() => '/';

  @override
  String rightDivider() => '';

  @override
  DateTime finalTime() {
    final year = minTime.year + currentLeftIndex();
    final month = currentMiddleIndex() + 1;
    return DateTime(year, month, 1);
  }
}
