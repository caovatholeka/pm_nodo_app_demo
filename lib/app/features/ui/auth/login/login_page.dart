import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/features/ui/auth/login/login_cubit.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../config/app_config.dart';
import '../../../../core/commons/app_assets.dart';
import '../../../../core/commons/app_colors.dart';
import '../../../../core/commons/screen_size.dart';
import '../../../../core/logger/logger.dart';
import '../../../navigation/bottom_navigation.dart';
import '../../../widgets/input_text_field.dart';
import '../../../widgets/primary_button.dart';
import '../forgot_pass/forgot_pass_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _cubit = GetIt.I.get<LogInCubit>();

  @override
  void initState() {
    // remove splash
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _login(){
    _cubit.doLogin(_userNameController.text, _passwordController.text);

  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogInCubit,LoginState>(
        bloc: _cubit,
        listener: (context,state){
          if(state.loginStatus == LoadStatus.SUCCESS){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigation()),
            );
          }
        },
        builder: (context,state){
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: AppColors.colorPrimary50,
            key: _scaffoldKey,
            body: WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      _bannerWidget(),
                    ],
                  ),
                  Positioned(
                    top: 140,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _bodyContent(),
                  ),
                ],
              ),
            ),
          );
        });

  }

  Widget _bannerWidget() {
    return SizedBox(
      height: ScreenSize.of(context).height*0.45,
      child:  SvgPicture.asset(AppAssets.blockBg1,fit: BoxFit.fill,),
    );
  }

  Widget _bodyContent(){
    return Padding(padding: const EdgeInsets.only(left: 16,right: 16),
      child: Column(
        children: [
          Center(
            child: SvgPicture.asset(AppAssets.appLogo,width: 110,),
          ),
          const SizedBox(height: 20,),
          Text("Hãy đăng nhập vào tài khoản của bạn",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteColor
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20,),
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
                InputTextField(
                  title:"Tên Đăng Nhập",
                  hintText: "",
                  isRequiredField: false,
                  enable: true,
                  controller: _userNameController,
                  maxLength: 255,
                  onChange: (value){
                  },
                ),
                const SizedBox(height: 20,),
                InputTextField(
                  title:"Mật khẩu",
                  hintText: "",
                  isRequiredField: false,
                  enable: true,
                  controller: _passwordController,
                  maxLength: 255,
                  onChange: (value){
                  },
                ),
                const SizedBox(height: 12,),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForgotPassPage()),
                      );
                    },
                    child: Text(
                      "Quên mật khẩu?",//S.current.forgot_password,
                      style: TextStyle(
                        fontFamily: AppConfig.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.themePrimaryDefault,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                PrimaryButton(
                  mainText:"Đăng Nhập", //S.current.login,
                  isLoading: false,
                  callback:(){
                    _login();
                  }
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
