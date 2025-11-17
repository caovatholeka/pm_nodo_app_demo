import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';

import 'forgot_pass_success_page.dart';
import 'forgot_cubit.dart';

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

  void _forgotPass() {
    final username = _userNameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên đăng nhập")),
      );
      return;
    }

    context.read<ForgotCubit>().sendForgotRequest(username);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.of(context).height;

    return BlocConsumer<ForgotCubit, ForgotState>(
      listener: (context, state) {
        if (state.forgotStatus == LoadStatus.SUCCESS) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPassSuccessPage()),
            );
          });
        }

        if (state.forgotStatus == LoadStatus.FAILURE) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? "Gửi yêu cầu thất bại")),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.colorPrimary50,
          body: Stack(
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
                top: 60,
                left: 16,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(AppAssets.icBack),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quên mật khẩu",
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Nhập tên đăng nhập để nhận mật khẩu tạm thời qua email.",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: screenHeight * 0.38,
                left: 16,
                right: 16,
                child: _formContent(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _formContent(ForgotState state) {
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
        children: [
          InputTextField(
            title: "Tên Đăng Nhập",
            hintText: "Nhập tên đăng nhập của bạn",
            isRequiredField: true,
            controller: _userNameController,
            bgrColor: true,
          ),

          const SizedBox(height: 20),

          PrimaryButton(
            mainText: "Xác nhận",
            isLoading: state.forgotStatus == LoadStatus.LOADING,
            callback: _forgotPass,
          ),
        ],
      ),
    );
  }

  Widget _bannerWidget() {
    return SizedBox(
      height: ScreenSize.of(context).height * 0.45,
      child: Image.asset(AppAssets.loginBG, fit: BoxFit.fill),
    );
  }

  Widget _bodyContent(ForgotState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: SvgPicture.asset(AppAssets.appLogo, width: 110)),
          const SizedBox(height: 20),

          Text(
            "Quên Mật Khẩu",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.whiteColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Nhập tên đăng nhập để nhận mật khẩu tạm thời qua email.",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                InputTextField(
                  title: "Tên Đăng Nhập",
                  hintText: "Nhập tên đăng nhập của bạn",
                  isRequiredField: true,
                  controller: _userNameController,
                  bgrColor: true,
                ),

                const SizedBox(height: 20),

                PrimaryButton(
                  mainText: "Xác nhận",
                  isLoading: state.forgotStatus == LoadStatus.LOADING,
                  callback: _forgotPass,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
