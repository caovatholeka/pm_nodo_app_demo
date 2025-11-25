import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/auth/otp_confirm/otp_verify_cubit.dart';
import 'package:pm_app/app/features/ui/auth/otp_confirm/otp_verify_page.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:pm_app/di/di.dart';

import 'forgot_cubit.dart';
import '../../../../core/commons/app_assets.dart';
import '../../../widgets/input_text_field.dart';
import '../../../widgets/primary_button.dart';
import 'package:pm_app/app/core/utils/validators.dart';

class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _showError(String msg) {
    Flushbar(
      message: msg,
      backgroundColor: Colors.redAccent,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      icon: const Icon(Icons.error, color: Colors.white),
    ).show(context);
  }

  void _submit() {
    final username = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (username.isEmpty && pass.isEmpty && confirm.isEmpty) {
      _showError("Vui lòng nhập đầy đủ thông tin!");
    } else if (username.isEmpty) {
      _showError("Vui lòng nhập tên đăng nhập!");
    } else if (pass.isEmpty) {
      _showError("Vui lòng nhập mật khẩu!");
    } else if (confirm.isEmpty) {
      _showError("Vui lòng xác nhận mật khẩu");
    } else if(pass != confirm) {
      _showError("Vui lòng xác nhận đúng mật khẩu bạn đã nhập!");
    }
     else if (!(_formKey.currentState?.validate() ?? false)) {
      _showError("Thông tin chưa hợp lệ. Vui lòng kiểm tra lại!");
      return;
    }
    context.read<ForgotCubit>().submitForgotRequest(
      email: username,
      password: pass,
      confirmPassword: confirm,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotCubit, ForgotState>(
      listener: (context, state) {
        if (state.forgotStatus == LoadStatus.FAILURE) {
          Flushbar(
            message: "Sai tên tài khoản. Vui lòng thử lại!",
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
            flushbarPosition: FlushbarPosition.TOP,
            margin: const EdgeInsets.all(12),
          ).show(context);
        }

        if (state.forgotStatus == LoadStatus.SUCCESS) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider(
                    create: (_) => sl<OtpVerifyCubit>(),
                    child: OtpVerifyPage(
                      email: _userCtrl.text.trim(),
                      password: _passCtrl.text.trim(),
                      confirmPassword: _confirmCtrl.text.trim(),
                    ),
                  ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.92,
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(AppAssets.appLogo2, width: 120),

                          const SizedBox(height: 16),

                          const Text(
                            "Quên mật khẩu",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: RichText(
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "*",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.red,
                                        height: 1.35,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          " Mật khẩu mới của bạn phải có tối thiểu 8 ký tự, bao gồm CHỮ IN HOA, chữ thường, ký tự đặc biệt và số.",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          InputTextField(
                            title: "Tên đăng nhập",
                            hintText: "Nhập tên đăng nhập của bạn",
                            isRequiredField: true,
                            controller: _userCtrl,
                            bgrColor: true,
                            validator:
                                (v) => Validator().validateEmail(v?.trim()),
                          ),
                          const SizedBox(height: 10),
                          InputTextField(
                            title: "Mật khẩu mới",
                            hintText: "Nhập mật khẩu mới của bạn",
                            isRequiredField: true,
                            controller: _passCtrl,
                            isPasswordField: true,
                            bgrColor: true,
                            validator:
                                (v) => Validator().validatePassword(
                                  v?.trim(),
                                  "Mật khẩu",
                                ),
                          ),
                          const SizedBox(height: 10),
                          InputTextField(
                            title: "Xác nhận mật khẩu mới",
                            hintText: "Xác nhận mật khẩu mới của bạn",
                            isRequiredField: true,
                            controller: _confirmCtrl,
                            isPasswordField: true,
                            bgrColor: true,
                            validator:
                                (v) => Validator().validateConfirmPassword(
                                  _passCtrl.text.trim(),
                                  v?.trim(),
                                ),
                          ),

                          const SizedBox(height: 26),

                          PrimaryButton(
                            mainText: "Xác nhận",
                            buttonWidth: double.infinity,
                            isLoading: state.forgotStatus == LoadStatus.LOADING,
                            callback: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
