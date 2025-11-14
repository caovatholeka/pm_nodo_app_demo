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
    return BlocConsumer<ForgotCubit, ForgotState>(
      listener: (context, state) {
        print("STATE = ${state.forgotStatus}");

        if (state.forgotStatus == LoadStatus.SUCCESS) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPassSuccessPage(),
      ),
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
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.colorPrimary50,
          body: WillPopScope(
            onWillPop: () async => false,
            child: Stack(
              children: [
                Column(
                  children: [
                    _bannerWidget(),
                  ],
                ),

                Positioned(
                  top: 86,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: SvgPicture.asset(AppAssets.icBack),
                    ),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _bodyContent(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bannerWidget() {
    return SizedBox(
      height: ScreenSize.of(context).height * 0.45,
      child: SvgPicture.asset(
        AppAssets.blockBg1,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _bodyContent(ForgotState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              AppAssets.appLogo,
              width: 110,
            ),
          ),
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
                )
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
