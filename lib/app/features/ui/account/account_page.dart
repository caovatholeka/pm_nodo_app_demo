import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../data/models/enums/load_status.dart';

import '../../widgets/custom_dialog.dart';
import '../../widgets/primary_button.dart';
import '../auth/login/login_page.dart';
import '../account/change_languge/change_languge_page.dart';
import '../account/personal_info/personal_info_page.dart';
import '../account/changepassword/change_password_page.dart';
import '../account/changepassword/change_password_cubit.dart';

import 'account_cubit.dart';
import 'account_state.dart';

import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _cubit = GetIt.I<AccountCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.fetchUserProfile();
  }

  void _logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return CustomDialog(
          iconPath: AppAssets.ic_delete,
          title: "Xác nhận đăng xuất",
          content: "Bạn có chắc muốn đăng xuất không?",
          confirmText: "Đăng xuất",
          cancelText: "Hủy",
          onConfirm: () async {
            Navigator.pop(context);

            try {
              final api = GetIt.I<ApiClient>();
              final token = await SharedPrefsHelper.getToken();
              if (token?.accessToken != null) {
                final dio = GetIt.I<Dio>();
                dio.options.headers['Authorization'] =
                    'Bearer ${token!.accessToken}';
                await api.logOut({});
              }
            } catch (_) {}

            await SharedPrefsHelper.clearAll();

            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (r) => false,
            );
          },
          success: false,
          onCancel: () => Navigator.pop(context),
        );
      },
    );
  }

  void _goInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
    );
  }

  void _goLanguge() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangeLanguagePage()),
    );
  }

  void _goPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      bloc: _cubit,
      builder: (context, state) {
        final profile = state.profile;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0,
                pinned: true,
                expandedHeight: 240,
                centerTitle: true,
                title: const Text(
                  "Cá nhân",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),

                flexibleSpace: FlexibleSpaceBar(
                  background: _header(profile, state.loadStatus),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF4F6F8),
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 240,
                  ),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text(
                          "General",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      _roundedMenuContainer(
                        children: [
                          _menuItem(
                            icon: AppAssets.icUser,
                            title: "Thông tin cá nhân",
                            onTap: () {
                              _goInfo();
                            },
                          ),
                          _menuItem(
                            icon: AppAssets.ic_notification,
                            title: "Thông báo",
                            onTap: () {},
                          ),
                          _menuItem(
                            icon: AppAssets.icProtect,
                            title: "Thiết lập mật khẩu",
                            onTap: () {
                              _goPassword();
                            },
                          ),
                          _menuItem(
                            icon: AppAssets.icLangague,
                            title: "Ngôn ngữ",
                            onTap: () {
                              _goLanguge();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text(
                          "About",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      _roundedMenuContainer(
                        children: [
                          _menuItem(
                            icon: AppAssets.icHelpCenter,
                            title: "Help Center",
                            onTap: () {},
                          ),
                          _menuItem(
                            icon: AppAssets.icUser,
                            title: "Privacy Policy",
                            onTap: () {},
                          ),
                          _menuItem(
                            icon: AppAssets.icLogout,
                            title: "Logout",
                            onTap: _logout,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(profile, LoadStatus status) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          child: SvgPicture.asset(AppAssets.profileBG, fit: BoxFit.cover),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child:
              status == LoadStatus.LOADING
                  ? const CircularProgressIndicator(color: Colors.white)
                  : profile != null
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          image: DecorationImage(
                            image:
                                profile.avatarUrl != null
                                    ? NetworkImage(profile.avatarUrl!)
                                    : AssetImage(AppAssets.img_df_avatar)
                                        as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        profile.name ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Padding(
                        padding: const EdgeInsets.only(
                          right: 30,
                        ),
                        child: Text(
                          "${profile.jobTitle ?? ''}  •  NV: ${profile.employeeCode ?? ''}  •  ${profile.phone ?? ''}",
                          textAlign:
                              TextAlign.left, 
                          style: const TextStyle(
                            color: AppColors.colorPrimary50,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  )
                  : const Text(""),
        ),
      ],
    );
  }

  Widget _title(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _roundedMenuContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _menuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              child: Center(
                child: SvgPicture.asset(icon, width: 20, height: 20),
              ),
            ),

            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: textColor ?? Colors.black,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
