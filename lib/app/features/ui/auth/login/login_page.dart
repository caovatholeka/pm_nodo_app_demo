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

  @override
  void dispose() {
    super.dispose();
  }

  void _login() {
    final username = _userNameController.text.trim();
    final password = _passwordController.text.trim();

    final isUserNameValid = _userNameKey.currentState?.validate() ?? false;
    final isPassValid = _passwordKey.currentState?.validate() ?? false;

    if(isUserNameValid &&
        isPassValid){
      _cubit.doLogin(username, password);
    }
    // if (username.isEmpty || password.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Vui lòng nhập đầy đủ tài khoản và mật khẩu"),
    //       backgroundColor: Colors.redAccent,
    //       behavior: SnackBarBehavior.floating,
    //     ),
    //   );
    //   return;
    // }
    //
    // _cubit.doLogin(username, password);
  }

  @override
  Widget build(BuildContext context) {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errMsg ?? "Đăng nhập thất bại. Vui lòng thử lại.",
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
                      height: ScreenSize.of(context).height*0.25,
                      color:  AppColors.colorPrimary50,
                    ),
                  ),
                  Positioned(
                    top: 16,//96,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SvgPicture.asset(AppAssets.appLogo, width: 96),
                    ),
                  ),

                  Positioned(
                    top: 210,
                    left: 16,
                    right: 16,
                    child: Text(
                      "Hãy đăng nhập vào tài khoản của bạn",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.whiteColor,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),

                  Positioned(
                    top: 286,
                    left: 16,
                    right: 16,
                    child: _bodyContent(state),
                  )

                  // Column(
                  //   children: [
                  //     _bannerWidget(),
                  //   ],
                  // ),
                  // Positioned(
                  //   top: 96,
                  //   left: 0,
                  //   right: 0,
                  //   bottom: 0,
                  //   child: _bodyContent(state),
                  // ),
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
      height: ScreenSize.of(context).height*0.7,
      child: SvgPicture.asset(AppAssets.blockBg1, fit: BoxFit.fill),
    );
  }

  Widget _bodyContent(LoginState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Center(
        //   child: SvgPicture.asset(AppAssets.appLogo, width: 110),
        // ),
        const SizedBox(height: 20),
        // Text(
        //   "Hãy đăng nhập vào tài khoản của bạn",
        //   style: TextStyle(
        //     fontSize: 24,
        //     fontWeight: FontWeight.w700,
        //     color: AppColors.whiteColor,
        //   ),
        //   textAlign: TextAlign.left,
        // ),
        // const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BlocBuilder<LogInCubit,LoginState>(
                  bloc: _cubit,
                  buildWhen: (prev,cur) => prev.userName != cur.userName,
                  builder: (context,state){
                    return Form(
                      key: _userNameKey,
                      child: InputTextField(
                        title: "Tên Đăng Nhập",
                        hintText: "",
                        isRequiredField: true,
                        enable: true,
                        maxLength: 255,
                        controller: _userNameController,
                        inputType: TextInputType.emailAddress,
                        onChange: (value){
                          _cubit.onChangeUSerName(value);
                          _userNameKey.currentState?.validate();
                        },
                        validator: (value)
                        => Validator().validateUserName(value?.trim()),
                      ),
                    );
                  }),
              const SizedBox(height: 16),
    
              BlocBuilder<LogInCubit,LoginState>(
                  bloc: _cubit,
                  buildWhen: (prev,cur) => prev.password != cur.password ||
                      prev.showPassword != cur.showPassword,
                  builder: (context,state){
                    return Form(
                      key: _passwordKey,
                      child: InputTextField(
                        title: "Mật khẩu",
                        hintText: "",
                        isRequiredField: true,
                        isObscured: (state.showPassword ?? false) ? false :  true,
                        enable: true,
                        maxLength: 16,
                        controller: _passwordController,
                        onChange: (value){
                          _cubit.onChangePassword(value);
                          _passwordKey.currentState?.validate();
                        },
                        suffixIcon: (state.showPassword ?? false) ? AppAssets.icEyeVisible : AppAssets.icEyeClose,
                        onSuffixAction: (){
                          _cubit.onShowHidePwd(state.showPassword ?? false);
                        },
                        validator: (value)
                        => Validator.validateEmpty(value, "Mật khẩu"),
                      ),
                    );
                  }),
    
              const SizedBox(height: 12),
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
            ],
          ),
        ),
      ],
    );
  }
}
