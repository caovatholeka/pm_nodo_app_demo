import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/ui/justification/bloc/create_justification_cubit.dart';
import 'package:pm_app/app/features/ui/justification/bloc/create_justification_state.dart';
import 'package:pm_app/app/features/ui/justification/widgets/dashed_border_box.dart';
import 'package:pm_app/app/features/widgets/dropdown_input_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';

class CreateJustificationPage extends StatelessWidget {
  const CreateJustificationPage({super.key});

  void _showDatePicker(BuildContext context, CreateJustificationCubit cubit) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      currentTime: DateTime.now(),
      locale: LocaleType.vi,
      onConfirm: (date) {
        cubit.changeDate(DateFormat('dd/MM/yyyy').format(date));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateJustificationCubit(),
      child: BlocBuilder<CreateJustificationCubit, CreateJustificationState>(
        builder: (context, state) {
          final cubit = context.read<CreateJustificationCubit>();

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                appBar: MyAppBar(
                  titleAppbar: "Tạo yêu cầu đi muộn về sớm",
                  haveBackButton: true,
                  haveActionButton: true,
                  iconPathAsset: AppAssets.icNotificationBell,
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 140),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              DropdownInputField(
                                title: "Loại lý do",
                                hint: "Chọn loại lý do",
                                items:
                                    state.reasons.map((e) => e.name).toList(),
                                selectedValue: state.selectedReason?.name,
                                onChanged: (value) {
                                  final item = state.reasons.firstWhere(
                                    (e) => e.name == value,
                                  );
                                  cubit.selectReason(item);
                                },
                              ),

                              const SizedBox(height: 16),

                              InputTextField(
                                title: "Ngày",
                                hintText: "Chọn ngày",
                                isRequiredField: true,
                                suffixIcon: AppAssets.icCalendar,
                                readOnly: true,
                                controller: TextEditingController(
                                  text: state.date,
                                ),
                                callback: () => _showDatePicker(context, cubit),
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownInputField(
                                      title: "Hình thức",
                                      hint: "Chọn hình thức",
                                      items:
                                          state.methods
                                              .map((e) => e.name)
                                              .toList(),
                                      selectedValue: state.selectedMethod?.name,
                                      onChanged: (value) {
                                        final item = state.methods.firstWhere(
                                          (e) => e.name == value,
                                        );
                                        cubit.selectMethod(item);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InputTextField(
                                      title: "Số giờ",
                                      hintText: "Nhập số giờ",
                                      isRequiredField: true,
                                      inputType: TextInputType.number,
                                      onChange: cubit.changeHours,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownInputField(
                                      title: "Hình thức",
                                      hint: "Chọn hình thức",
                                      items:
                                          state.methods
                                              .map((e) => e.name)
                                              .toList(),
                                      selectedValue: state.selectedMethod?.name,
                                      onChanged: (value) {
                                        final item = state.methods.firstWhere(
                                          (e) => e.name == value,
                                        );
                                        cubit.selectMethod(item);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InputTextField(
                                      title: "Số giờ",
                                      hintText: "Nhập số giờ",
                                      isRequiredField: true,
                                      inputType: TextInputType.number,
                                      onChange: cubit.changeHours,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              InputTextField(
                                title: "Ghi chú",
                                hintText: "Nhập lý do",
                                isRequiredField: true,
                                maxLine: 6,
                                onChange: cubit.changeNote,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottomSheet: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 48,
                      child: PrimaryButton(
                        mainText: "Lưu",
                        enable: state.isFormValid,
                        isLoading: state.isSubmitting,
                        callback: state.isFormValid ? cubit.submit : null,
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

  Widget _blueDashedBox(
    BuildContext context,
    CreateJustificationCubit cubit,
    CreateJustificationState state,
  ) {
    return DashedBorderBox(
      radius: 12,
      color: AppColors.themePrimaryDefault,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownInputField(
                    title: "Hình thức",
                    hint: "Chọn hình thức",
                    items: state.methods.map((e) => e.name).toList(),
                    selectedValue: state.selectedMethod?.name,
                    onChanged: (value) {
                      final item = state.methods.firstWhere(
                        (e) => e.name == value,
                      );
                      cubit.selectMethod(item);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputTextField(
                    title: "Số giờ",
                    hintText: "Nhập số giờ",
                    isRequiredField: true,
                    inputType: TextInputType.number,
                    onChange: cubit.changeHours,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  backgroundColor: AppColors.themePrimaryDefault.withOpacity(
                    0.15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.themePrimaryDefault,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
