import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/utils/validators.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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

    final isUserNameValid = _userNameKey.currentState?.validate() ?? false;
    final isPassValid = _passwordKey.currentState?.validate() ?? false;

    if (isUserNameValid && isPassValid) {
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
            MaterialPageRoute(builder: (context) => const BottomNavigation()),
          );
        }
        if (state.loginStatus == LoadStatus.FAILURE) {
          Flushbar(
          message: "Đăng nhập thất bại. Vui lòng thử lại.",
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
          flushbarPosition: FlushbarPosition.TOP,
          margin: EdgeInsets.all(12),
        ).show(context);
    }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.colorPrimary50,
          key: _scaffoldKey,
          body: WillPopScope(
            onWillPop: () async => false,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  _bannerWidget(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      height: screenHeight * 0.25,
                      color: AppColors.colorPrimary50,
                    ),
                  ),

                  Positioned(
                    top: screenHeight * 0.10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SvgPicture.asset(AppAssets.appLogo, width: 96),
                    ),
                  ),

                  Positioned(
                    top: screenHeight * 0.28, 
                    left: 16,
                    right: 16,
                    child: Text(
                      "Hãy đăng nhập vào tài khoản của bạn",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.36, 
                    left: 16,
                    right: 16,
                    child: _bodyContent(state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bannerWidget() {
    return SizedBox(
      height: ScreenSize.of(context).height * 0.7,
      child: SvgPicture.asset(AppAssets.blockBg1, fit: BoxFit.fill),
    );
  }

  Widget _bodyContent(LoginState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              BlocBuilder<LogInCubit, LoginState>(
                bloc: _cubit,
                buildWhen: (prev, cur) => prev.userName != cur.userName,
                builder: (context, state) {
                  return Form(
                    key: _userNameKey,
                    child: InputTextField(
                      title: "Tên Đăng Nhập",
                      hintText:"Nhập tên đăng nhập",
                      isRequiredField: true,
                      controller: _userNameController,
                      maxLength: 255,
                      inputType: TextInputType.emailAddress,
                      onChange: (value) {
                        _cubit.onChangeUSerName(value);
                        _userNameKey.currentState?.validate();
                      },
                      validator: (value) =>
                          Validator().validateUserName(value?.trim()),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              BlocBuilder<LogInCubit, LoginState>(
                bloc: _cubit,
                buildWhen: (prev, cur) =>
                    prev.password != cur.password || prev.showPassword != cur.showPassword,
                builder: (context, state) {
                  return Form(
                    key: _passwordKey,
                    child: InputTextField(
                      title: "Mật khẩu",
                      hintText: "Nhập mật khẩu",
                      isRequiredField: true,
                      maxLength: 16,
                      isObscured: !(state.showPassword ?? false),
                      controller: _passwordController,
                      onChange: (value) {
                        _cubit.onChangePassword(value);
                        _passwordKey.currentState?.validate();
                      },
                      suffixIcon: (state.showPassword ?? false)
                          ? AppAssets.icEyeVisible
                          : AppAssets.icEyeClose,
                      onSuffixAction: () {
                        _cubit.onShowHidePwd(state.showPassword ?? false);
                      },
                      validator: (value) =>
                          Validator.validateEmpty(value, "Mật khẩu"),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPassPage()),
                    );
                  },
                  child: Text(
                    "Quên mật khẩu?",
                    style: TextStyle(
                      fontFamily: AppConfig.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.themePrimaryDefault,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              BlocBuilder<LogInCubit, LoginState>(
                bloc: _cubit,
                buildWhen: (prev, cur) =>
                    prev.loginStatus != cur.loginStatus,
                builder: (context, state) {
                  final isLoading = state.loginStatus == LoadStatus.LOADING;
                  return PrimaryButton(
                    mainText: "Đăng Nhập",
                    isLoading: isLoading,
                    callback: isLoading ? null : _login,
                  );
                },
              ),
              const SizedBox(height: 16)
            ],
          ),
        ),
      ],
    );
  }
}
