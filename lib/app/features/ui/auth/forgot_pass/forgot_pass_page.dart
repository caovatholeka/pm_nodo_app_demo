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

  void _submit() {
    context.read<ForgotCubit>().submitForgotRequest(
          email: _userCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          confirmPassword: _confirmCtrl.text.trim(),
        );
  }

  void _showError(ForgotState state) {
    final msg = state.validationMessage;
    if (msg == null || msg.isEmpty) return;
    Flushbar(
      message: msg,
      backgroundColor: Colors.redAccent,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(10),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<ForgotCubit, ForgotState>(
      listener: (context, state) {
        if (state.forgotStatus == LoadStatus.FAILURE) {
          _showError(state);
        }

        if (state.forgotStatus == LoadStatus.SUCCESS) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
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
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
              ),

              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: keyboard),
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: keyboard == 0
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(22, 32, 22, 36),
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
                                      children: [
                                        Image.asset(
                                          AppAssets.appLogo2,
                                          width: 120,
                                          height: 120,
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          "Quên mật khẩu",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 18),

                                        InputTextField(
                                          title: "Tên đăng nhập",
                                          hintText: "Nhập tên đăng nhập",
                                          isRequiredField: true,
                                          controller: _userCtrl,
                                          bgrColor: true,
                                          validator: (v) =>
                                              Validator().validateEmail(v?.trim()),
                                        ),
                                        const SizedBox(height: 16),
                                        InputTextField(
                                          title: "Mật khẩu mới",
                                          hintText: "Nhập mật khẩu mới",
                                          isRequiredField: true,
                                          controller: _passCtrl,
                                          isPasswordField: true,
                                          bgrColor: true,
                                          validator: (v) =>
                                              Validator().validatePassword(
                                                    v?.trim(),
                                                    "Mật khẩu",
                                                  ),
                                        ),
                                        const SizedBox(height: 16),
                                        InputTextField(
                                          title: "Xác nhận mật khẩu mới",
                                          hintText: "Xác nhận mật khẩu mới",
                                          isRequiredField: true,
                                          controller: _confirmCtrl,
                                          isPasswordField: true,
                                          bgrColor: true,
                                          validator: (v) =>
                                              Validator().validateConfirmPassword(
                                                _passCtrl.text.trim(),
                                                v?.trim(),
                                              ),
                                        ),
                                        const SizedBox(height: 24),
                                        PrimaryButton(
                                          mainText: "Xác nhận",
                                          buttonWidth: double.infinity,
                                          isLoading:
                                              state.forgotStatus == LoadStatus.LOADING,
                                          callback: _submit,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                left: 10,
                right: 10,
                bottom: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFB5BBC6),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Nếu bạn gặp vấn đề, vui lòng liên hệ với phòng nhân sự của công ty để được hỗ trợ.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB5BBC6),
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
