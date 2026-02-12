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
import 'package:pm_app/generated/l10n.dart';

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
    final s = S.of(context);
    final regex =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');

    if (newPass.isEmpty) {
      return s.change_password_Empty;
    }

    if (!regex.hasMatch(newPass)) {
      return s.change_password_condistion;
    }

    return null;
  }

  String? _validateFields() {
    final s = S.of(context);
    final current = currentController.text.trim();
    final newPass = newController.text.trim();
    final confirm = confirmController.text.trim();

    if (current.isEmpty) {
      return s.change_password_Empty;
    }

    final newPassError = _validateNewPassword(newPass);
    if (newPassError != null) return newPassError;

    if (confirm.isEmpty) {
      return s.change_confirm_Empty;
    }

    if (confirm != newPass) {
      return s.change_password_NotMatch;
    }

    return null;
  }

  void _submit() {
    final error = _validateFields();
    if (error != null) {
      _showMessage(S.of(context).failed, error);
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
    final s = S.of(context);

    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state.status == LoadStatus.SUCCESS) {
          _showMessage(
            s.success,
            state.message ?? s.change_password_success,
            success: true,
          );
          _clearFields();
        }

        if (state.status == LoadStatus.FAILURE) {
          _showMessage(
            s.failed,
            (state.message != null && state.message!.trim().isNotEmpty)
                ? state.message!
                : s.cannot_change_password,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: MyAppBar(
            titleAppbar: s.change_password_title,
            haveBackButton: true,
            isTransparent: true,
            backAction: () {
              if (state.status == LoadStatus.LOADING) {
                _showMessage(s.inProgress, s.inProgressSub);
                return;
              }
              Navigator.pop(context);
            },
          ),
          body: Stack(
            children: [
              Container(
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
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: "* ",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: s
                                                      .change_password_condistion,
                                                  style: TextStyle(
                                                    color: AppColors.subtitle,
                                                    fontSize: 13,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      InputTextField(
                                        controller: currentController,
                                        hintText:
                                            s.change_password_current,
                                        title: s
                                            .change_password_current_hint,
                                        isRequiredField: true,
                                        isPasswordField: true,
                                        bgrColor: true,
                                      ),
                                      const SizedBox(height: 10),
                                      InputTextField(
                                        controller: newController,
                                        hintText: s.change_password_new,
                                        title:
                                            s.change_password_new_hint,
                                        isRequiredField: true,
                                        isPasswordField: true,
                                        bgrColor: true,
                                      ),
                                      const SizedBox(height: 10),
                                      InputTextField(
                                        controller: confirmController,
                                        hintText:
                                            s.change_password_confirm,
                                        title: s
                                            .change_password_confirm_hint,
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
                                  mainText:
                                      s.change_password_button,
                                  isLoading:
                                      state.status ==
                                          LoadStatus.LOADING,
                                  callback: () {
                                    if (state.status ==
                                        LoadStatus.LOADING) return;
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
              if (state.status == LoadStatus.LOADING)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
