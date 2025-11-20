import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/auth/otp_confirm/otp_verify_cubit.dart';
import 'package:pm_app/app/features/ui/auth/otp_confirm/otp_verify_page.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/di/di.dart';

import 'forgot_cubit.dart';
import '../../../../core/commons/app_assets.dart';
import '../../../widgets/input_text_field.dart';
import '../../../widgets/primary_button.dart';

class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  void _submit() {
    context.read<ForgotCubit>().submitForgotRequest(
          email: _userCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          confirmPassword: _confirmCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<ForgotCubit, ForgotState>(
      listener: (context, state) {
        if (state.validationMessage != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => CustomDialog(
              title: "Lỗi",
              content: state.validationMessage!,
              iconPath: AppAssets.ic_delete,
            ),
          );
          return;
        }

        if (state.forgotStatus == LoadStatus.FAILURE) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => CustomDialog(
              title: "Thất bại",
              content: state.message ?? "Gửi yêu cầu thất bại",
              iconPath: AppAssets.ic_delete,
            ),
          );
          return;
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
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AppAssets.appBG2,
                  fit: BoxFit.cover,
                ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.appLogo2,
                          width: 120,
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Quên mật khẩu",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.star,
                                size: 10, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Mật khẩu mới của bạn phải có tối thiểu 8 ký tự, bao gồm CHỮ IN HOA...",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        InputTextField(
                          title: "Tên đăng nhập",
                          hintText: "Nhập tên đăng nhập của bạn",
                          isRequiredField: true,
                          controller: _userCtrl,
                          bgrColor: true,
                        ),

                        InputTextField(
                          title: "Mật khẩu mới",
                          hintText: "Nhập mật khẩu mới của bạn",
                          isRequiredField: true,
                          controller: _passCtrl,
                          isPasswordField: true,
                          bgrColor: true,
                        ),

                        InputTextField(
                          title: "Xác nhận mật khẩu mới",
                          hintText: "Xác nhận mật khẩu mới của bạn",
                          isRequiredField: true,
                          controller: _confirmCtrl,
                          isPasswordField: true,
                          bgrColor: true,
                        ),

                        const SizedBox(height: 26),

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

              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline,
                        size: 16, color: Color(0xFFB5BBC6)),
                    SizedBox(width: 6),
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
