import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        titleAppbar: "Đổi mật khẩu",
        haveBackButton: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.appBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 120),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: AppShadow.pageBoxShadow,
                  ),
                  child: Column(
                    children: [
                      InputTextField(
                        controller: currentPasswordController,
                        hintText: "Nhập mật khẩu hiện tại",
                        title: "Mật khẩu hiện tại",
                        style: TextStyle(color: AppColors.searchText),
                        isRequiredField: true,
                        bgrColor: true,
                      ),
                      const SizedBox(height: 10),

                      InputTextField(
                        controller: newPasswordController,
                        hintText: "Nhập mật khẩu mới",
                        title: "Mật khẩu mới",
                        style: TextStyle(color: AppColors.searchText),
                        isRequiredField: true,
                        bgrColor: true,
                      ),
                      const SizedBox(height: 10),
                      InputTextField(
                        controller: confirmPasswordController,
                        style: TextStyle(color: AppColors.searchText),
                        hintText: "Nhập lại mật khẩu mới",
                        title: "Xác nhận mật khẩu mới",
                        isRequiredField: true,
                        bgrColor: true,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: PrimaryButton(
                          mainText: "Xác nhận",
                          callback: () {
                            print("No event yet");
                          },
                        )
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