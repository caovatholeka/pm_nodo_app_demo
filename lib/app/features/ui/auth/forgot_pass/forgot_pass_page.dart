import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pm_app/app/features/ui/auth/forgot_pass/forgot_pass_success_page.dart';

import '../../../../core/commons/app_assets.dart';
import '../../../../core/commons/app_colors.dart';
import '../../../../core/commons/screen_size.dart';
import '../../../widgets/input_text_field.dart';
import '../../../widgets/primary_button.dart';

class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _forgotPass(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPassSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.colorPrimary50,
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
              top: 86,
              height: 16,
              child: InkWell(
                onTap: (){
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(AppAssets.icBack),
                ),
              ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(AppAssets.appLogo,width: 110,),
          ),
          const SizedBox(height: 20,),
          Text("Quên Mật Khẩu",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteColor
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 4,),
          Text("Mật khẩu mới của bạn phải có tối thiểu 8 ký , bao gồm "
              "CHỮ IN HOA, chữ thường ,ký tự đặc biệt và số",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
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
                  hintText: "Nhập tên đăng nhập của bạn",
                  isRequiredField: false,
                  enable: true,
                  controller: _userNameController,
                  maxLength: 255,
                  onChange: (value){
                  },
                ),
                const SizedBox(height: 20,),
                InputTextField(
                  title:"Mật khẩu mới",
                  hintText: "Nhập mật khẩu mới",
                  isRequiredField: true,
                  enable: true,
                  controller: _userNameController,
                  maxLength: 255,
                  onChange: (value){
                  },
                ),
                const SizedBox(height: 20,),
                InputTextField(
                  title:"Xác nhận mật khẩu mới",
                  hintText: "Nhập mật khẩu mới",
                  isRequiredField: true,
                  enable: true,
                  controller: _userNameController,
                  maxLength: 255,
                  onChange: (value){
                  },
                ),

                const SizedBox(height: 20,),
                PrimaryButton(
                    mainText:"Xác nhận", //S.current.login,
                    isLoading: false,
                    callback:(){
                      _forgotPass();
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
