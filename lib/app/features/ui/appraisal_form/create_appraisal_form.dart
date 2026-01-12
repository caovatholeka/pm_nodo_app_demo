import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/apprasisal_progress_page.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/create_apprasial_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

class CreateAppraisalForm extends StatefulWidget {
  const CreateAppraisalForm({super.key});

  @override
  State<CreateAppraisalForm> createState() => _CreateAppraisalFormState();
}

class _CreateAppraisalFormState extends State<CreateAppraisalForm> {
  late final CreateAppraisalCubit _cubit;

  final _createdDateCtrl = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  );
  final _fromDateCtrl = TextEditingController();
  final _toDateCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final Map<int, TextEditingController> _hourCtrls = {};

  @override
  void initState() {
    super.initState();
    _cubit = CreateAppraisalCubit();
  }

  @override
  void dispose() {
    _createdDateCtrl.dispose();
    _fromDateCtrl.dispose();
    _toDateCtrl.dispose();
    _noteCtrl.dispose();
    for (final c in _hourCtrls.values) {
      c.dispose();
    }
    _cubit.close();
    super.dispose();
  }

  void _pickFromDate() {
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      onConfirm: (d) {
        _fromDateCtrl.text = DateFormat('dd/MM/yyyy').format(d);
        _toDateCtrl.clear();
        _hourCtrls.clear();
        _cubit.setFromDate(d);
      },
    );
  }

  void _pickToDate() {
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      onConfirm: (d) {
        _toDateCtrl.text = DateFormat('dd/MM/yyyy').format(d);
        _hourCtrls.clear();
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
        builder: (context) => const ApprasisalProgressPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
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
                  child: BlocBuilder<AppCubit, AppState>(
                    buildWhen:
                        (prev, cur) => prev.totalUnread != cur.totalUnread,
                    builder: (context, appState) {
                      return MyAppBar(
                        titleAppbar: "Phiếu đánh giá kết quả CV",
                        haveBackButton: true,
                        haveActionButton: true,
                        iconPathAsset: AppAssets.icNotificationBell,
                        badgeCount: appState.totalUnread,
                        actionCallBack: () async {
                          _goNotification();
                        },
                      );
                    },
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
                          title: 'Mã nhân viên',
                          hintText: 'NV51',
                          isRequiredField: false,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),

                        InputTextField(
                          title: 'Chức danh',
                          hintText: 'Thực tập sinh',
                          isRequiredField: false,
                          readOnly: true,
                        ),

                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text: 'Thời gian thực tập ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                                children: [
                                  TextSpan(
                                    text: '(Từ ngày... Đến ngày...)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: InputTextField(
                                    title: '',
                                    hintText: 'Từ ngày',
                                    isRequiredField: false,
                                    controller: _fromDateCtrl,
                                    readOnly: true,
                                    suffixIcon: AppAssets.icCalendar,

                                    callback: _pickFromDate,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InputTextField(
                                    title: '',
                                    hintText: 'Đến ngày',
                                    isRequiredField: false,
                                    controller: _toDateCtrl,
                                    readOnly: true,
                                    suffixIcon: AppAssets.icCalendar,
                                    callback: _pickToDate,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        InputTextField(
                          title: 'Cấp trên trực tiếp',
                          hintText: 'Trần Xuân Trường',
                          isRequiredField: true,
                          controller: _noteCtrl,
                          onChange: _cubit.setNote,
                        ),

                        const SizedBox(height: 16),
                        InputTextField(
                          title: 'Chức danh cấp trên',
                          hintText: 'Giám đốc sản xuất',
                          isRequiredField: true,
                          controller: _noteCtrl,
                          onChange: _cubit.setNote,
                        ),
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
                        mainText: 'Gửi yêu cầu',
                        enable: state.isFormValid,
                        isLoading: state.isSubmitting,
                        callback: () {
                          _progressNext();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
