import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/features/ui/auth/login/login_page.dart';

import '../../../../core/commons/app_assets.dart';
import '../../../../core/commons/app_colors.dart';
import '../../../../core/commons/screen_size.dart';
import '../../../widgets/primary_button.dart';

class ForgotPassSuccessPage extends StatelessWidget {
  const ForgotPassSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.of(context).height;

    return Scaffold(
      backgroundColor: AppColors.colorPrimary50,
      body: Stack(
        children: [
          SizedBox(
            height: screenHeight,
            width: double.infinity,
            child: Image.asset(
              AppAssets.loginBG,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: screenHeight * 0.06,
            left: 16,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: SvgPicture.asset(AppAssets.icBack, width: 10),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppAssets.appLogo,
                    width: 90,
                  ),

                  const SizedBox(height: 25),
                  Image.asset(
                    AppAssets.bgForgotPassword,
                    width: screenHeight * 0.40,
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Congratulations!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Your new password has been set.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 20),

      GestureDetector(
       onTap: () {
        Navigator.pushAndRemoveUntil(
       context,
       MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
          );
        },
            child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
             ),
              child: const Center(
                child: Text(
                  "Đăng nhập",
                  style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E6CF6),
                  ),
                      ),
                  ),
                ),
              ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
