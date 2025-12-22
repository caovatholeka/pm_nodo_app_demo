import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/features/ui/justification/bloc/create_justification_cubit.dart';
import 'package:pm_app/app/features/widgets/dropdown_input_field.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

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
  late final TextEditingController _firstHourCtrl;
  late final TextEditingController _secondHourCtrl;

  @override
  void initState() {
    super.initState();

    final e = widget.initialData;

    _dateCtrl = TextEditingController(text: e?.date ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');

    if (e != null && e.exceptionLines != null) {
      _firstHourCtrl = TextEditingController(
        text:
            e.exceptionLines!.isNotEmpty
                ? e.exceptionLines![0].timeNumber?.toString()
                : '',
      );

      _secondHourCtrl = TextEditingController(
        text:
            e.exceptionLines!.length > 1
                ? e.exceptionLines![1].timeNumber?.toString()
                : '',
      );
    } else {
      _firstHourCtrl = TextEditingController();
      _secondHourCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _noteCtrl.dispose();
    _firstHourCtrl.dispose();
    _secondHourCtrl.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
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
                appBar: MyAppBar(
                  titleAppbar:
                      widget.isEdit
                          ? 'Cập nhật yêu cầu M/S'
                          : 'Tạo yêu cầu đi muộn về sớm',
                  haveBackButton: true,
                  haveActionButton: true,
                  iconPathAsset: AppAssets.icNotificationBell,
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
                        DropdownInputField(
                          title: 'Loại lý do',
                          hint: '',
                          isRequired: true,
                          items: const ['Việc cá nhân', 'Công việc'],
                          selectedValue:
                              state.reasonType == 'personal'
                                  ? 'Việc cá nhân'
                                  : state.reasonType == 'work'
                                  ? 'Công việc'
                                  : null,
                          onChanged: (v) {
                            cubit.changeReason(
                              v == 'Việc cá nhân' ? 'personal' : 'work',
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        InputTextField(
                          title: 'Ngày',
                          hintText: '',
                          isRequiredField: true,
                          readOnly: true,
                          controller: _dateCtrl,
                          suffixIcon: AppAssets.icCalendar,
                          callback: () => _showDatePicker(context, cubit),
                        ),
                        const SizedBox(height: 16),

                        _row(
                          state.firstFormType,
                          _firstHourCtrl,
                          cubit.changeFirstFormType,
                          cubit.changeFirstHours,
                        ),
                        const SizedBox(height: 16),

                        _row(
                          state.secondFormType,
                          _secondHourCtrl,
                          cubit.changeSecondFormType,
                          cubit.changeSecondHours,
                        ),
                        const SizedBox(height: 16),

                        InputTextField(
                          title: 'Ghi chú',
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
                        mainText: 'Lưu',
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

  Widget _row(
    String? formType,
    TextEditingController hourCtrl,
    Function(String) onTypeChanged,
    Function(String) onHourChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: DropdownInputField(
            title: 'Hình thức',
            isRequired: true,
            hint: '',
            items: const ['Đi muộn', 'Về sớm'],
            selectedValue:
                formType == 'late'
                    ? 'Đi muộn'
                    : formType == 'early'
                    ? 'Về sớm'
                    : null,
            onChanged: (v) => onTypeChanged(v == 'Đi muộn' ? 'late' : 'early'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InputTextField(
            title: 'Số giờ',
            hintText: '',
            isRequiredField: true,
            controller: hourCtrl,
            inputType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
            ],
            onChange: (v) {
              final value = double.tryParse(v);
              if (value == null) return;
              onHourChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
