import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:pm_app/app/core/commons/screen_size.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../core/network/api_util.dart';
import '../../../data/models/enums/load_status.dart';

import '../../widgets/custom_dialog.dart';
import '../auth/login/login_page.dart';
import '../account/change_languge/change_languge_page.dart';
import '../account/personal_info/personal_info_page.dart';
import '../account/changepassword/change_password_page.dart';

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
              // final api = GetIt.I<ApiClient>();
              ApiClient  api = ApiUtil.instance.createApiClient();
              final token = await SharedPrefsHelper.getToken();
              if (token?.accessToken != null) {
                final dio = GetIt.I<Dio>();
                dio.options.headers['Authorization'] =
                    'Bearer ${token!.accessToken}';
                await api.logOut({});
              }
            } catch (_) {}

            await SharedPrefsHelper.saveToken(null);
            await SharedPrefsHelper.setIsLoginApp(false);

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

  void _goNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
          child: const NotificationPage(),
        ),
      ),
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
        final screen = ScreenSize.of(context);
        final appBarHeight = screen.height * 0.24;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: appBarHeight,
                flexibleSpace: FlexibleSpaceBar(
                  background: _header(profile, state.loadStatus),
                ),
              ),

              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
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
                          onTap: _goInfo,
                        ),
                        _menuItem(
                          icon: AppAssets.icNotificationPF,
                          title: "Thông báo",
                          onTap: _goNotification,
                        ),
                        _menuItem(
                          icon: AppAssets.icProtect,
                          title: "Thiết lập mật khẩu",
                          onTap: _goPassword,
                        ),
                        _menuItem(
                          icon: AppAssets.icLangague,
                          title: "Ngôn ngữ",
                          onTap: _goLanguge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left:10),
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(profile, LoadStatus status) {
    final screen = ScreenSize.of(context);

    final avatarSize = screen.width * 0.18;
    final cameraSize = avatarSize * 0.28;
    final nameFontSize = screen.width * 0.045;
    final subInfoFontSize = screen.width * 0.028;
    final spacing12 = screen.width * 0.03;
    final spacing6 = screen.width * 0.015;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
            child: SvgPicture.asset(AppAssets.profileBG, fit: BoxFit.cover),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: screen.height * 0.032),
          child: status == LoadStatus.LOADING
              ? const CircularProgressIndicator(
                  color: AppColors.appBarGradientStart)
              : profile != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: avatarSize * 0.05,
                                ),
                                image: DecorationImage(
                                  image: profile.avatarUrl != null
                                      ? NetworkImage(profile.avatarUrl!)
                                      : AssetImage(AppAssets.img_df_avatar)
                                          as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              width: cameraSize,
                              height: cameraSize,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: cameraSize * 0.55,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing12),
                        Text(
                          profile.name ?? "",
                          style: TextStyle(
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: spacing6),
                        Padding(
                          padding:
                              EdgeInsets.only(right: screen.width * 0.09),
                          child: Text(
                            "${profile.jobTitle ?? ''}  •  NV: ${profile.employeeCode ?? ''}  •  ${profile.phone ?? ''}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.colorPrimary50,
                              fontSize: subInfoFontSize,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _roundedMenuContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.all(5),
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          children: [
            SizedBox(
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
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(
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
