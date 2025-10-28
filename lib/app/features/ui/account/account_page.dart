import 'package:flutter/material.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../account/change_languge/change_languge_page.dart';
import '../account/changepassword/change_password_page.dart';
import '../account/personal_info/personal_info_page.dart';
import '../../widgets/primary_button.dart';
import '../auth/login/login_page.dart';
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  void _goLangague() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangeLanguagePage()),
    );
  }

  void _goPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
  }

  void _goInfo() {
   Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonalInfoPage()),
    );
  }

  void _logOut() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => LoginPage()
    ));
  }

  @override
  Widget build(BuildContext context) {
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
              _accountInfo,
              const SizedBox(height: 24),
              _menuItem(
                icon: AppAssets.ic_user,
                title: "Thông tin cá nhân",
                onTap: () {
                  _goInfo();
                },
              ),
              _menuItem(
                icon: AppAssets.ic_langague,
                title: "Ngôn ngữ",
                onTap: () {
                  _goLangague();
                },
              ),
              _menuItem(
                icon: AppAssets.ic_protect,
                title: "Đổi mật khẩu",
                onTap: () {
                  _goPassword();
                },
              ),
              _menuItem(
                icon: AppAssets.ic_setting,
                title: "Cài đặt chung",
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _logoutButton,
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  get _accountInfo {
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
              const Text(
                "NGUYỄN MINH DŨNG",
                style: TextStyle(
                  color: AppColors.colorPrimary50,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _InfoItem(title: "Ngày sinh", value: "03/01/2002"),
                  _InfoItem(title: "Staff profile code", value: "NV33656"),
                  _InfoItem(title: "Số điện thoại", value: "19001000"),
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
                image: AssetImage(AppAssets.img_df_avatar),
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

  get _logoutButton {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        mainText: "Đăng Xuất",
        callback: () => {
          _logOut()
        },
        )
    );
  }
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
