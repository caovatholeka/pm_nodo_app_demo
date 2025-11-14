import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _forgotPass() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPassSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.of(context).height;

    return Scaffold(
      backgroundColor: AppColors.colorPrimary50,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: screenHeight,      
        child: Stack(
          children: [
            SizedBox(
              height: screenHeight * 0.50,  
              child: SvgPicture.asset(AppAssets.blockBg1, fit: BoxFit.fill),
            ),

            Positioned(
              top: screenHeight * 0.06,
              left: 16,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset(AppAssets.icBack, width: 10),
              ),
            ),

            Positioned(
              top: screenHeight * 0.15,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SvgPicture.asset(AppAssets.appLogo, width: 88),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Quên mật khẩu",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    "Mật khẩu mới của bạn phải có tối thiểu 8 ký tự, "
                    "bao gồm CHỮ IN HOA, chữ thường, ký tự đặc biệt và số.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: screenHeight * 0.44 - 32,  
              left: 16,
              right: 16,
              bottom: 0,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      InputTextField(
                        title: "Tên đăng nhập",
                        hintText: "Nhập tên đăng nhập của bạn",
                        isRequiredField: true,
                        controller: _userNameController,
                        bgrColor: true,
                      ),
                      const SizedBox(height: 20),

                      InputTextField(
                        title: "Mật khẩu mới",
                        hintText: "Nhập mật khẩu mới",
                        bgrColor: true,
                        isRequiredField: true,
                        controller: _newPasswordController,
                        isObscured: true,
                      ),
                      const SizedBox(height: 20),

                      InputTextField(
                        title: "Xác nhận mật khẩu mới",
                        hintText: "Nhập lại mật khẩu mới",
                        bgrColor: true,
                        isRequiredField: true,
                        controller: _confirmPasswordController,
                        isObscured: true,
                      ),

                      const SizedBox(height: 24),

                      PrimaryButton(
                        mainText: "Xác nhận",
                        isLoading: false,
                        callback: _forgotPass,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
