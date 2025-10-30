import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:pm_app/app/data/models/entities/profile_entity.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/di/di.dart';
import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../data/models/enums/load_status.dart';
import '../../widgets/primary_button.dart';
import '../auth/login/login_page.dart';
import '../account/change_languge/change_languge_page.dart';
import '../account/changepassword/change_password_page.dart';
import '../account/changepassword/change_password_cubit.dart';
import '../account/personal_info/personal_info_page.dart';
import 'account_cubit.dart';
import 'account_state.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _cubit = sl<AccountCubit>();


  @override
  void initState() {
    super.initState();
    // _cubit.fetchUserProfile();
  }

  void _goLangague() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangeLanguagePage()),
    );
  }

  void _showDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Cảnh báo!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Đang phát triển chức năng này!!!',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Đóng',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
    );
  }

  void _goPassword() {
   Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
      create: (_) => sl<ChangePasswordCubit>(),
      child: const ChangePasswordPage(),
    ),
    ),
  );
  }

  void _goInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonalInfoPage()),
    );
  }

  void _logOut() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      bloc: _cubit,
      builder: (context, state) {
        final profile = state.profile;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: MyAppBar(
            titleAppbar: "Cá nhân",
            haveBackButton: true,
            backAction: () => Navigator.pop(context),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.imgBg2),
                fit: BoxFit.fill,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),
                  if (state.loadStatus == LoadStatus.LOADING)
                    const Center(child: CircularProgressIndicator())
                  else if (profile != null)
                    _accountInfo(profile)
                  else
                    const Center(
                      child: Text(
                        "Không thể tải thông tin người dùng",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _menuItem(
                    icon: AppAssets.ic_user,
                    title: "Thông tin cá nhân",
                    onTap: _goInfo,
                  ),
                  _menuItem(
                    icon: AppAssets.ic_langague,
                    title: "Ngôn ngữ",
                    onTap: _goLangague,
                  ),
                  _menuItem(
                    icon: AppAssets.ic_protect,
                    title: "Đổi mật khẩu",
                    onTap: _goPassword,
                  ),
                  _menuItem(
                    icon: AppAssets.ic_setting,
                    title: "Cài đặt chung",
                    onTap: _showDialog,
                  ),
                  const SizedBox(height: 24),
                  _logoutButton,
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _accountInfo(ProfileEntity profile) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.profileContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                profile.name ?? "Chưa có tên",
                style: const TextStyle(
                  color: AppColors.colorPrimary50,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(title: "Ngày sinh", value: profile.birthdayDate ?? "Null"),
                  _InfoItem(
                      title: "Staff profile code",
                      value: profile.code ?? "Null"),
                  _InfoItem(
                      title: "Số điện thoại",
                      value: (profile.phone == true ? "Có" : "Không"),
                  )
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.avatarFrame, width: 3),
              image: DecorationImage(
                image: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!) as ImageProvider
                    : AssetImage(AppAssets.img_df_avatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Image.asset(icon, width: 22, height: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget get _logoutButton => SizedBox(
        width: double.infinity,
        child: PrimaryButton(
          mainText: "Đăng Xuất",
          callback: _logOut,
        ),
      );
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.avatarText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.colorPrimary50,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
