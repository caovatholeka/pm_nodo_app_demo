import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/justification/bloc/create_justification_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/multiple_choice.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/generated/l10n.dart';

class CreateJustificationPage extends StatefulWidget {
  final JustificationEntity? initialData;

  const CreateJustificationPage({super.key, this.initialData});

  bool get isEdit => initialData != null;

  @override
  State<CreateJustificationPage> createState() =>
      _CreateJustificationPageState();
}

class _CreateJustificationPageState extends State<CreateJustificationPage> {
  late final TextEditingController _dateCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _reasonTypeCtrl;
  final Map<String, TextEditingController> _hourControllers = {};

  @override
  void initState() {
    super.initState();

    final e = widget.initialData;

    _dateCtrl = TextEditingController(text: e?.date ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _reasonTypeCtrl = TextEditingController(
      text:
          e?.reasonType == 'personal'
              ? 'Việc cá nhân'
              : e?.reasonType == 'work'
              ? 'Công việc'
              : '',
    );

    if (e != null && e.exceptionLines != null) {
      for (var line in e.exceptionLines!) {
        if (line.formType != null && line.timeNumber != null) {
          _hourControllers[line.formType!] = TextEditingController(
            text: line.timeNumber!.toString(),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _noteCtrl.dispose();
    _reasonTypeCtrl.dispose();
    for (var ctrl in _hourControllers.values) {
      ctrl.dispose();
    }
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

  void _showDatePicker(BuildContext context, CreateJustificationCubit cubit) {
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      currentTime: DateTime.now(),
      onConfirm: (date) {
        final value = DateFormat('yyyy-MM-dd').format(date);
        _dateCtrl.text = value;
        cubit.changeDate(value);
      },
    );
  }

  TextEditingController _getHourController(String formType) {
    if (!_hourControllers.containsKey(formType)) {
      _hourControllers[formType] = TextEditingController();
    }
    return _hourControllers[formType]!;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create:
          (context) =>
              CreateJustificationCubit(context.read())
                ..initFromDetail(widget.initialData),
      child: BlocConsumer<CreateJustificationCubit, CreateJustificationState>(
        listenWhen:
            (p, c) =>
                p.errorMessage != c.errorMessage || p.isSuccess != c.isSuccess,
        listener: (context, state) async {
          if (state.errorMessage != null) {
            await Flushbar(
              message: state.errorMessage!,
              flushbarPosition: FlushbarPosition.TOP,
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ).show(context);
            return;
          }

          if (state.isSuccess == true) {
            Navigator.of(context).pop(true);
            await Flushbar(
              message:
                  widget.isEdit
                      ? 'Cập nhật yêu cầu thành công'
                      : 'Tạo yêu cầu thành công',
              flushbarPosition: FlushbarPosition.TOP,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ).show(context);
          }
        },
        builder: (context, state) {
          final cubit = context.read<CreateJustificationCubit>();

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
                        titleAppbar: widget.isEdit
                            ? s.justification_update_title
                            : s.justification_create_title,
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
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 140),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        InputTextField(
                          title: s.justification_create_reasonType,
                          hintText: '',
                          isRequiredField: true,
                          readOnly: true,
                          controller: _reasonTypeCtrl,
                          suffixIcon: AppAssets.icArrowDown,
                          callback: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (_) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 12),
                                      Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        s.justification_create_reasonType,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(
                                        height: 1,
                                        thickness: 0.8,
                                        color: Colors.black12,
                                      ),
                                      ListTile(
                                        title: const Text('Việc cá nhân'),
                                        onTap: () {
                                          _reasonTypeCtrl.text = 'Việc cá nhân';
                                          cubit.changeReason('personal');
                                          Navigator.pop(context);
                                        },
                                      ),
                                      const Divider(
                                        height: 1,
                                        thickness: 0.8,
                                        color: Colors.black12,
                                      ),
                                      ListTile(
                                        title: const Text('Công việc'),
                                        onTap: () {
                                          _reasonTypeCtrl.text = 'Công việc';
                                          cubit.changeReason('work');
                                          Navigator.pop(context);
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        InputTextField(
                          title: s.justification_create_date,
                          hintText: '',
                          isRequiredField: true,
                          readOnly: true,
                          controller: _dateCtrl,
                          suffixIcon: AppAssets.icCalendar,
                          callback: () => _showDatePicker(context, cubit),
                        ),
                        const SizedBox(height: 16),
                        MultipleChoiceField<String>(
                          title: s.justification_create_form,
                          hint: '',
                          isRequired: true,
                          type: ChoiceType.multiple,
                          options: const [
                            {"value": "late", "label": "Đi muộn"},
                            {"value": "early", "label": "Về sớm"},
                          ],
                          selectedValues: state.selectedFormTypes,
                          onMultiChanged: (values) {
                            cubit.changeSelectedFormTypes(values);
                          },
                        ),
                        const SizedBox(height: 16),
                        if (state.selectedFormTypes != null &&
                            state.selectedFormTypes!.isNotEmpty)
                          ...state.selectedFormTypes!.map((formType) {
                            final label =
                                formType == 'late' ? 'Đi muộn' : 'Về sớm';
                            final controller = _getHourController(formType);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InputTextField(
                                      title: 'Hình thức',
                                      hintText: '',
                                      isRequiredField: true,
                                      readOnly: true,
                                      controller: TextEditingController(
                                        text: label,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InputTextField(
                                      title: s.justification_create_hours,
                                      hintText: '',
                                      isRequiredField: true,
                                      controller: controller,
                                      inputType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d{0,2}$'),
                                        ),
                                      ],
                                      onChange: (v) {
                                        final value = double.tryParse(v);
                                        if (value != null) {
                                          cubit.changeFormHours(
                                            formType,
                                            value,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        InputTextField(
                          title: s.justification_create_notes,
                          hintText: '',
                          isRequiredField: true,
                          maxLine: 6,
                          controller: _noteCtrl,
                          onChange: cubit.changeNote,
                        ),
                      ],
                    ),
                  ),
                ),
                bottomSheet: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: PrimaryButton(
                        mainText: s.justification_create_savebtn,
                        enable: state.isFormValid,
                        isLoading: state.isSubmitting,
                        callback: cubit.submit,
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
