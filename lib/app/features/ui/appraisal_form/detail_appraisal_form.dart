import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/evaluation_repository.dart';
import 'package:pm_app/app/features/ui/appraisal_form/apprasisal_progress_page.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/detail_apprasial_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/generated/l10n.dart';

class DetailAppraisalForm extends StatefulWidget {
  final bool isDetail;
  final bool isEdit;
  final int? evaluationId;

  const DetailAppraisalForm({
    super.key,
    this.isDetail = false,
    this.isEdit = false,
    this.evaluationId,
  });

  @override
  State<DetailAppraisalForm> createState() => _DetailAppraisalFormState();
}

class _DetailAppraisalFormState extends State<DetailAppraisalForm> {
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

    if (widget.isDetail) {
      _cubit.initDetail();

      if (widget.evaluationId != null) {
        _cubit.getEvaluationDetails(widget.evaluationId!);
      }
    } else if (widget.isEdit) {
      _cubit.initEdit();

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

  void _progressNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: _cubit,
              child: const ApprasisalProgressPage(),
            ),
      ),
    );
  }

  void _fillDetail(CreateAppraisalState state) {
    final e = state.detailEvaluation;
    if (e == null) return;

    _employeeCodeCtrl.text = e.employeeCode ?? "";
    _employeeNameCtrl.text = e.employeeName ?? "";
    _deprtmentCtrl.text = e.departmentName ?? "";

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
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: MyAppBar(
                      titleAppbar:
                          widget.isDetail == true
                              ? s.appraisal_form_title
                              : widget.isEdit
                              ? s.bt_updateTitle
                              : s.appraisal_create_title,
                      haveBackButton: true,
                      haveActionButton: true,
                      iconPathAsset: AppAssets.icNotificationBell,
                      actionCallBack: _goNotification,
                    ),
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 140),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          InputTextField(
                            title: s.appraisal_employee_code,
                            hintText: '',
                            isRequiredField: widget.isDetail != true,
                            controller: _employeeCodeCtrl,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          InputTextField(
                            title: s.appraisal_employee_name,
                            hintText: '',
                            isRequiredField: widget.isDetail != true,
                            controller: _employeeNameCtrl,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          InputTextField(
                            hintText: s.employee_card_department,
                            isRequiredField: widget.isDetail != true,
                            title: s.employee_card_department,
                            controller: _deprtmentCtrl,
                            readOnly: true,
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
                                  callback:
                                      state.isDetail == true
                                          ? null
                                          : _pickToDate,
                                ),
                              ),
                            ],
                          ),
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
                  bottomSheet: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        height: 48,
                        child: PrimaryButton(
                          mainText: s.appraisal_continue,
                          enable:
                              state.isDetail == true
                                  ? state.loadDetail == LoadStatus.SUCCESS
                                  : state.isFormValid,
                          isLoading: state.isSubmitting,
                          callback: _progressNext,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
