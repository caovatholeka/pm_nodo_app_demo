import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/ui/justification/bloc/create_justification_cubit.dart';
import 'package:pm_app/app/features/ui/justification/justification_detail.dart';
import 'package:pm_app/app/features/widgets/dropdown_input_field.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

class CreateJustificationPage extends StatelessWidget {
  const CreateJustificationPage({super.key});

  void _showDatePicker(BuildContext context, CreateJustificationCubit cubit) {
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      currentTime: DateTime.now(),
      onConfirm: (date) {
        cubit.changeDate(DateFormat('yyyy-MM-dd').format(date));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateJustificationCubit(context.read()),
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
              message: 'Tạo yêu cầu thành công',
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
                  titleAppbar: 'Tạo yêu cầu đi muộn về sớm',
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
                          items: const ['Việc cá nhân', 'Công việc'],
                          selectedValue:
                              state.reasonType == 'personal'
                                  ? 'Việc cá nhân'
                                  : state.reasonType == 'work'
                                  ? 'Công việc'
                                  : null,
                          onChanged:
                              (v) => cubit.changeReason(
                                v == 'Việc cá nhân' ? 'personal' : 'work',
                              ),
                        ),
                        const SizedBox(height: 16),
                        InputTextField(
                          title: 'Ngày',
                          hintText: '',
                          isRequiredField: true,
                          readOnly: true,
                          suffixIcon: AppAssets.icCalendar,
                          controller: TextEditingController(text: state.date),
                          callback: () => _showDatePicker(context, cubit),
                        ),
                        const SizedBox(height: 16),
                        _row(
                          state.firstFormType,
                          cubit.changeFirstFormType,
                          cubit.changeFirstHours,
                        ),
                        const SizedBox(height: 16),
                        _row(
                          state.secondFormType,
                          cubit.changeSecondFormType,
                          cubit.changeSecondHours,
                        ),
                        const SizedBox(height: 16),
                        InputTextField(
                          title: 'Ghi chú',
                          hintText: '',
                          isRequiredField: true,
                          maxLine: 6,
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
    String? value,
    Function(String) onTypeChanged,
    Function(String) onHourChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: DropdownInputField(
            title: 'Hình thức',
            hint: '',
            items: const ['Đi muộn', 'Về sớm'],
            selectedValue:
                value == 'late'
                    ? 'Đi muộn'
                    : value == 'early'
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
            inputType: TextInputType.number,
            onChange: onHourChanged,
          ),
        ),
      ],
    );
  }
}
