import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/utils/validators.dart';
import 'package:pm_app/app/features/ui/auth/forgot_pass/forgot_cubit.dart';
import 'package:pm_app/app/features/ui/auth/login/login_cubit.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../config/app_config.dart';
import '../../../../core/commons/app_assets.dart';
import '../../../../core/commons/app_colors.dart';
import '../../../../core/commons/screen_size.dart';
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
  final _userNameKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _cubit = sl<LogInCubit>();

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  void _login() {
    final username = _userNameController.text.trim();
    final password = _passwordController.text.trim();

    final isUserValid = _userNameKey.currentState?.validate() ?? false;
    final isPassValid = _passwordKey.currentState?.validate() ?? false;

    if (isUserValid && isPassValid) {
      _cubit.doLogin(username, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.of(context).height;

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
            duration: const Duration(seconds: 3),
            flushbarPosition: FlushbarPosition.TOP,
            margin: const EdgeInsets.all(12),
          ).show(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.colorPrimary50,
          body: SizedBox(
            height: screenHeight,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: screenHeight * 0.45,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppAssets.loginBG),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SvgPicture.asset(AppAssets.appLogo, width: 90),
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.28,
                  left: 16,
                  right: 16,
                  child: const Text(
                    "Hãy đăng nhập vào tài khoản\ncủa bạn",
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.37,
                  left: 16,
                  right: 16,
                  child: _formContent(screenHeight, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _formContent(double screenHeight, LoginState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _userNameKey,
            child: InputTextField(
              title: "Tên đăng nhập",
              hintText: "Nhập tên đăng nhập của bạn",
              isRequiredField: true,
              bgrColor: true,
              controller: _userNameController,
              maxLength: 255,
              onChange: (v) => _userNameKey.currentState?.validate(),
              validator: (v) => Validator().validateUserName(v?.trim()),
            ),
          ),

          const SizedBox(height: 16),

          Form(
            key: _passwordKey,
            child: InputTextField(
              title: "Mật khẩu",
              hintText: "Nhập mật khẩu",
              isRequiredField: true,
              bgrColor: true,
              maxLength: 16,
              enable: true,
              isObscured: !(state.showPassword ?? false),
              controller: _passwordController,
              onChange: (v) => _passwordKey.currentState?.validate(),
              suffixIcon:
                  (state.showPassword ?? false)
                      ? AppAssets.icEyeVisible
                      : AppAssets.icEyeClose,
              onSuffixAction:
                  () => _cubit.onShowHidePwd(state.showPassword ?? false),
              validator: (v) => Validator.validateEmpty(v, "Mật khẩu"),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      checkboxTheme: CheckboxThemeData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFBFC6D0),
                          width: 1.4,
                        ),
                        visualDensity: const VisualDensity(
                          horizontal: -3,
                          vertical: -3,
                        ),
                      ),
                    ),
                    child: Checkbox(
                      value: state.rememberMe ?? false,
                      onChanged: (v) => _cubit.onRememberMe(v ?? false),
                      activeColor: AppColors.themePrimaryDefault,
                      checkColor: Colors.white,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                  Text(
                    "Nhớ tài khoản",
                    style: TextStyle(
                      color: AppColors.textNormal,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppConfig.fontFamily,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider.value(
                            value: sl<ForgotCubit>(),
                            child: const ForgotPassPage(),
                          ),
                    ),
                  );
                },
                child: Text(
                  "Quên mật khẩu?",
                  style: TextStyle(
                    color: AppColors.themePrimaryDefault,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppConfig.fontFamily,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          BlocBuilder<LogInCubit, LoginState>(
            bloc: _cubit,
            builder: (context, state) {
              final loading = state.loginStatus == LoadStatus.LOADING;
              return PrimaryButton(
                mainText: "Đăng nhập",
                isLoading: loading,
                buttonWidth: double.infinity,
                callback: loading ? null : _login,
              );
            },
          ),
        ],
      ),
    );
  }
}
