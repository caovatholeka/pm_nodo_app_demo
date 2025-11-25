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
import 'package:pm_app/app/features/widgets/custom_dialog.dart';

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

  void _showDialog(String title, String message, {bool success = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (_) => CustomDialog(
            iconPath: success ? AppAssets.ic_done : AppAssets.ic_delete,
            title: title,
            content: message,
            success: success,
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  void _onSubmit() {
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();
    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showDialog(
        "Thiếu thông tin",
        "Vui lòng nhập đầy đủ các trường mật khẩu.",
        success: false,
      );
      return;
    }

    if (newPass != confirm) {
      _showDialog(
        "Không trùng khớp",
        "Mật khẩu mới và mật khẩu xác nhận không giống nhau.",
        success: false,
      );
      return;
    }

    final cubit = context.read<ChangePasswordCubit>();
    cubit.changePassword(
      currentPassword: current,
      newPassword: newPass,
      confirmPassword: confirm,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state.status == LoadStatus.SUCCESS) {
          _showDialog(
            "Thành công",
            state.message ?? "Đổi mật khẩu thành công!",
            success: true,
          );
        } else if (state.status == LoadStatus.FAILURE) {
          _showDialog("Lỗi", state.message ?? "Không thể đổi mật khẩu");
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
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status == LoadStatus.LOADING;
                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: PrimaryButton(
                                mainText:
                                    isLoading ? "Đang xử lý..." : "Xác nhận",
                                callback: isLoading ? null : _onSubmit,
                              ),
                            );
                          },
                        ),
                      ],
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
