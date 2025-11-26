import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/account/changepassword/change_password_cubit.dart';
import 'package:pm_app/di/di.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:pm_app/app/core/utils/validators.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChangePasswordCubit>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _showFlushbar(String title, String? message, {bool success = false}) {
    final safeMessage =
        (message == null || message.trim().isEmpty)
            ? "Có lỗi xảy ra. Vui lòng thử lại!"
            : message;

    Flushbar(
      title: title,
      message: safeMessage,
      duration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      backgroundColor: success ? Colors.green : Colors.red,
      icon: Icon(
        success ? Icons.check_circle : Icons.error,
        color: Colors.white,
      ),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  void _onSubmit() {
    final formValid = _formKey.currentState?.validate() ?? false;

    if (!formValid) {
      final msg = _getFirstValidatorError() ?? "Thông tin chưa hợp lệ!";
      _showFlushbar("Thất bại", msg);
      return;
    }

    final cubit = context.read<ChangePasswordCubit>();
    cubit.changePassword(
      currentPassword: currentPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );
  }

  String? _getFirstValidatorError() {
    final validators = [
      Validator().validatePassword(
        currentPasswordController.text.trim(),
        "Mật khẩu hiện tại",
      ),
      Validator().validatePassword(
        newPasswordController.text.trim(),
        "Mật khẩu mới",
      ),
      Validator().validateConfirmPassword(
        newPasswordController.text.trim(),
        confirmPasswordController.text.trim(),
      ),
    ];

    for (final e in validators) {
      if (e != null) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state.status == LoadStatus.SUCCESS) {
          _showFlushbar(
            "Thành công",
            state.message ?? "Đổi mật khẩu thành công!",
            success: true,
          );

          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        } else if (state.status == LoadStatus.FAILURE) {
          _showFlushbar(
            "Thất bại",
            state.message?.trim().isNotEmpty == true
                ? state.message!
                : "Không thể đổi mật khẩu",
            success: false,
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: MyAppBar(
          titleAppbar: "Đổi mật khẩu",
          haveBackButton: true,
          isTransparent: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.appBg),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 120),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: AppShadow.pageBoxShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  InputTextField(
                                    controller: currentPasswordController,
                                    hintText: "Nhập mật khẩu hiện tại",
                                    title: "Mật khẩu hiện tại",
                                    isPasswordField: true,
                                    style: const TextStyle(
                                      color: AppColors.themeBlackDefault,
                                    ),
                                    isRequiredField: true,
                                    bgrColor: true,
                                    validator:
                                        (v) => Validator().validatePassword(
                                          v?.trim(),
                                          "Mật khẩu hiện tại",
                                        ),
                                  ),
                                  const SizedBox(height: 10),

                                  InputTextField(
                                    controller: newPasswordController,
                                    hintText: "Nhập mật khẩu mới",
                                    isPasswordField: true,
                                    title: "Mật khẩu mới",
                                    style: const TextStyle(
                                      color: AppColors.themeBlackDefault,
                                    ),
                                    isRequiredField: true,
                                    bgrColor: true,
                                    validator:
                                        (v) => Validator().validatePassword(
                                          v?.trim(),
                                          "Mật khẩu mới",
                                        ),
                                  ),
                                  const SizedBox(height: 10),

                                  InputTextField(
                                    controller: confirmPasswordController,
                                    hintText: "Nhập lại mật khẩu mới",
                                    isPasswordField: true,
                                    title: "Xác nhận mật khẩu mới",
                                    style: const TextStyle(
                                      color: AppColors.themeBlackDefault,
                                    ),
                                    isRequiredField: true,
                                    bgrColor: true,
                                    validator:
                                        (v) =>
                                            Validator().validateConfirmPassword(
                                              newPasswordController.text.trim(),
                                              v?.trim(),
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _onSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.mainPrimaryColor6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Xác nhận",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
