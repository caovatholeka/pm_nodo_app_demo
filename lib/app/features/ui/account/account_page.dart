import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import 'package:pm_app/app/features/widgets/development_alert_dialog.dart';
import 'package:pm_app/generated/l10n.dart';
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
    _cubit.fetchUserProfile();
  }

  void _goLangague() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeLanguagePage(
        ),
      ),
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

  void _logOut() async {
  final shouldLogout = await showGeneralDialog<bool>(
  context: context,
  barrierLabel: "Logout",
  barrierDismissible: true,
  barrierColor: Colors.black54,
  transitionDuration: const Duration(milliseconds: 250),
  pageBuilder: (_, __, ___) => const SizedBox(),
  transitionBuilder: (_, anim, __, ___) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xác nhận đăng xuất", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Bạn có chắc muốn đăng xuất khỏi tài khoản này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, 
            MaterialPageRoute(builder: (context) => const LoginPage())),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  },
);

  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<AccountCubit, AccountState>(
      bloc: _cubit,
      builder: (context, state) {
        final profile = state.profile;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: MyAppBar(
            titleAppbar: s.bottomtab_personal,
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
                    Center(
                      child: Text(
                        'Failed to load data',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _menuItem(
                    icon: AppAssets.ic_user,
                    title: s.expenable_personal_profile,
                    onTap: _goInfo,
                  ),
                  _menuItem(
                    icon: AppAssets.ic_langague,
                    title: s.btn_langauge,
                    onTap: _goLangague,
                  ),
                  _menuItem(
                    icon: AppAssets.ic_protect,
                    title: s.btn_changepassword,
                    onTap: _goPassword,
                  ),
                  _menuItem(
                    icon: AppAssets.ic_setting,
                    title: s.btn_setting,
                    onTap: (){DevelopmentAlertDialog.show(context);},
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
    final s = S.of(context);
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
                  _InfoItem(title: s.dob , value: profile.birthdayDate ?? "-"),
                  _InfoItem(
                      title: s.input_employee_code,
                      value: profile.code ?? "-"),
                  _InfoItem(
                      title: s.phone_number,
                      value: (profile.phone == true ? "-" : "-"),
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
