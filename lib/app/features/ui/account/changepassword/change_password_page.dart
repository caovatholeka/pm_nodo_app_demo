import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/account/changepassword/change_password_cubit.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/di/di.dart';
import 'package:another_flushbar/flushbar.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordCubit(userRepository: sl()),
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
  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Hiển thị thông báo popup
  void _showMessage(String title, String message, {bool success = false}) {
    Flushbar(
      title: title,
      message: message,
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

  String? _validateNewPassword(String newPass) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');

    if (newPass.isEmpty) {
      return "Mật khẩu mới không được để trống";
    }

    if (!regex.hasMatch(newPass)) {
      return "Mật khẩu mới phải có tối thiểu 8 ký tự, gồm chữ IN HOA, chữ thường, số và ký tự đặc biệt";
    }

    return null;
  }

  String? _validateFields() {
    final current = currentController.text.trim();
    final newPass = newController.text.trim();
    final confirm = confirmController.text.trim();
    if (current.isEmpty) {
      return "Mật khẩu hiện tại không được để trống";
    }

    final newPassError = _validateNewPassword(newPass);
    if (newPassError != null) return newPassError;

    if (confirm.isEmpty) {
      return "Vui lòng nhập lại mật khẩu để xác nhận";
    }
    if (confirm != newPass) {
      return "Xác nhận mật khẩu không khớp";
    }

    return null;
  }

  void _submit() {
    final error = _validateFields();
    if (error != null) {
      _showMessage("Thất bại", error);
      return;
    }

    context.read<ChangePasswordCubit>().changePassword(
      currentPassword: currentController.text.trim(),
      newPassword: newController.text.trim(),
      confirmPassword: confirmController.text.trim(),
    );
  }

  void _clearFields() {
    currentController.clear();
    newController.clear();
    confirmController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state.status == LoadStatus.SUCCESS) {
          _showMessage(
            "Thành công",
            state.message ?? "Đổi mật khẩu thành công!",
            success: true,
          );
          _clearFields();
        }

        if (state.status == LoadStatus.FAILURE) {
          _showMessage(
            "Thất bại",
            (state.message != null && state.message!.trim().isNotEmpty)
                ? state.message!
                : "Không thể đổi mật khẩu",
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: MyAppBar(
          titleAppbar: "Đổi mật khẩu",
          haveBackButton: true,
          isTransparent: true,
          backAction: () {
            final state = context.read<ChangePasswordCubit>().state;
            if (state.status == LoadStatus.LOADING) {
              _showMessage("Đang xử lý", "Vui lòng đợi hoàn tất");
              return;
            }
            Navigator.pop(context);
          },
        ),

        body: Container(
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
                child: Container(
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
                                  controller: currentController,
                                  hintText: "Nhập mật khẩu hiện tại",
                                  title: "Mật khẩu hiện tại",
                                  isRequiredField: true,
                                  isPasswordField: true,
                                  bgrColor: true,
                                ),
                                const SizedBox(height: 10),

                                InputTextField(
                                  controller: newController,
                                  hintText: "Nhập mật khẩu mới",
                                  title: "Mật khẩu mới",
                                  isRequiredField: true,
                                  isPasswordField: true,
                                  bgrColor: true,
                                ),
                                const SizedBox(height: 10),

                                InputTextField(
                                  controller: confirmController,
                                  hintText: "Nhập lại mật khẩu mới",
                                  title: "Xác nhận mật khẩu mới",
                                  isRequiredField: true,
                                  isPasswordField: true,
                                  bgrColor: true,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: PrimaryButton(
                            mainText: "Xác nhận",
                            callback: () {
                              _submit();
                            },
                          ),
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
