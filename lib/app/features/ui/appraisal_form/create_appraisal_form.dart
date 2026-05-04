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
import 'package:pm_app/app/features/ui/appraisal_form/cubit/create_apprasial_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/generated/l10n.dart';

class CreateAppraisalForm extends StatefulWidget {
  final bool isDetail;
  final bool isCreate;
  final int? evaluationId;

  const CreateAppraisalForm({
    super.key,
    this.isDetail = false,
    this.isCreate = false,
    this.evaluationId,
  });

  @override
  State<CreateAppraisalForm> createState() => _CreateAppraisalFormState();
}

class _CreateAppraisalFormState extends State<CreateAppraisalForm> {
  late final CreateAppraisalCubit _cubit;

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

  @override
  void initState() {
    super.initState();

    _cubit = CreateAppraisalCubit(repository: GetIt.I<EvaluationRepository>());

    if (widget.isDetail) {
      _cubit.initDetail();

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
    super.dispose();
  }

  void _pickFromDate() {
    DatePicker.showDatePicker(
      context,
      locale: _pickerLocale,
      onConfirm: (d) {
        _fromDateCtrl.text = DateFormat('dd/MM/yyyy').format(d);
        _toDateCtrl.clear();
        _cubit.setFromDate(d);
      },
    );
  }

  void _pickToDate() {
    DatePicker.showDatePicker(
      context,
      locale: _pickerLocale,
      onConfirm: (d) {
        _toDateCtrl.text = DateFormat('dd/MM/yyyy').format(d);
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
      );
      if (d != null) {
        _cubit.setFromDate(d);
      }
    }

    if (e.dateTo != null) {
      final d = AppDateUtils.parseFlexibleDate(e.dateTo);
      _toDateCtrl.text = AppDateUtils.formatFlexibleDateForDisplay(e.dateTo);
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
        listener: (context, state) {
          if (state.loadDetail == LoadStatus.SUCCESS) {
            _fillDetail(state);
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
