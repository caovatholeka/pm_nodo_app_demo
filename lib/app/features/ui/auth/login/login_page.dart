import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/utils/validators.dart';
import 'package:pm_app/app/features/ui/auth/forgot_pass/forgot_cubit.dart';
import 'package:pm_app/app/features/ui/auth/login/login_cubit.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../core/commons/app_assets.dart';
import '../../../../core/commons/app_colors.dart';
import '../../../navigation/bottom_navigation.dart';
import '../../../widgets/input_text_field.dart';
import '../../../widgets/primary_button.dart';
import '../forgot_pass/forgot_pass_page.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:pm_app/di/di.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userKey = GlobalKey<FormState>();
  final _passKey = GlobalKey<FormState>();

  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _cubit = sl<LogInCubit>();

  void _login() {
    if ((_userKey.currentState?.validate() ?? false) &&
        (_passKey.currentState?.validate() ?? false)) {
      _cubit.doLogin(_userCtrl.text.trim(), _passCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogInCubit, LoginState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state.loginStatus == LoadStatus.SUCCESS) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavigation()),
          );
        }

        if (state.loginStatus == LoadStatus.FAILURE) {
          Flushbar(
            message: "Đăng nhập thất bại. Vui lòng thử lại.",
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
            flushbarPosition: FlushbarPosition.TOP,
            margin: const EdgeInsets.all(12),
          ).show(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.appBG2),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 140),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.fromLTRB(22, 28, 22, 36),
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
                                      width: 90,
                                      height: 90,
                                    ),
                                    const SizedBox(height: 4),

                                    const Text(
                                      "Đăng nhập",
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "Enter your email and password to log in",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),

                                    const SizedBox(height: 28),

                                    Form(
                                      key: _userKey,
                                      child: InputTextField(
                                        title: "Tên đăng nhập",
                                        hintText:
                                            "Nhập tên đăng nhập của bạn",
                                        isRequiredField: true,
                                        bgrColor: true,
                                        controller: _userCtrl,
                                        validator: (v) => Validator()
                                            .validateUserName(v?.trim()),
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    Form(
                                      key: _passKey,
                                      child: InputTextField(
                                        title: "Mật khẩu",
                                        hintText: "Nhập mật khẩu",
                                        isRequiredField: true,
                                        bgrColor: true,
                                        isObscured:
                                            !(state.showPassword ?? false),
                                        controller: _passCtrl,
                                        suffixIcon: (state.showPassword ?? false)
                                            ? AppAssets.icEyeVisible
                                            : AppAssets.icEyeClose,
                                        onSuffixAction: () =>
                                            _cubit.onShowHidePwd(
                                                state.showPassword ?? false),
                                        validator: (v) =>
                                            Validator.validateEmpty(
                                                v, "Mật khẩu"),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => _cubit.onRememberMe(
                                                !(state.rememberMe ?? false),
                                              ),
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color:
                                                      (state.rememberMe ??
                                                              false)
                                                          ? AppColors
                                                              .themePrimaryDefault
                                                          : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color:
                                                        Colors.grey.shade400,
                                                    width: 1.4,
                                                  ),
                                                ),
                                                child: (state.rememberMe ??
                                                        false)
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 16,
                                                        color: Colors.white,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text("Nhớ tài khoản"),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    BlocProvider.value(
                                                  value: sl<ForgotCubit>(),
                                                  child:
                                                      const ForgotPassPage(),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Quên mật khẩu?",
                                            style: TextStyle(
                                              color: AppColors
                                                  .themePrimaryDefault,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 26),

                                    PrimaryButton(
                                      mainText: "Đăng nhập",
                                      buttonWidth: double.infinity,
                                      isLoading: state.loginStatus ==
                                          LoadStatus.LOADING,
                                      callback: _login,
                                    ),

                                    const SizedBox(height: 20),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Don't have an account? ",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          "Sign Up",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors
                                                .themePrimaryDefault,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 30),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline,
                                      size: 16, color: Color(0xFFB5BBC6)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Nếu bạn gặp vấn đề, vui lòng liên hệ với phòng nhân sự của công ty để được hỗ trợ.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFB5BBC6),
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
