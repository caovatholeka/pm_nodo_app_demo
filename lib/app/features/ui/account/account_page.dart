import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/commons/screen_size.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/generated/l10n.dart';

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

  @override
  void dispose() {
    _cubit.onResetStatus();
    super.dispose();
  }

  void _logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return CustomDialog(
          title: "Xác nhận đăng xuất",
          content: "Bạn có chắc muốn đăng xuất không?",
          confirmText: "Đăng xuất",
          cancelText: "Hủy",
          onConfirm: () async {
            Navigator.pop(context);

            // await _cubit.doLogout();
            String deviceType = await SharedPrefsHelper.getDeviceType();
            try {
              ApiClient api = ApiUtil.instance.createApiClient();
              final token = await SharedPrefsHelper.getToken();
              if (token?.accessToken != null) {
                final dio = GetIt.I<Dio>();
                dio.options.headers['Authorization'] =
                    'Bearer ${token!.accessToken}';
                await api.logOut({ "device_type" : deviceType,});
              }
            } catch (_) {}

            await SharedPrefsHelper.saveToken(null);
            await SharedPrefsHelper.setIsLoginApp(false);
            GlobalData.instance.bottomNavIndex.value = 0;

            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (_) => false,
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
    final s = S.of(context);
    return BlocConsumer<AccountCubit, AccountState>(
        bloc: _cubit,
        listener: (context,state) async{
          // if(state.logoutStatus == LoadStatus.LOADING){
          //   LoadingOverlay.show(context);
          // }else if(state.logoutStatus == LoadStatus.SUCCESS) {
          //   LoadingOverlay.hide(context);
          //   await SharedPrefsHelper.saveToken(null);
          //   await SharedPrefsHelper.setIsLoginApp(false);
          //   _cubit.onResetStatus();
          //   GlobalData.instance.bottomNavIndex.value = 0;
          //
          //   Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(builder: (_) => const LoginPage()),
          //         (r) => false,
          //   );
          // }else{
          //   _cubit.onResetStatus();
          //   LoadingOverlay.hide(context);
          // }
        },
        builder: (context,state){
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
                              s.account_page_title1,
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
                                title: s.account_page_util1,
                                onTap: _goInfo,
                              ),
                              _menuItem(
                                icon: AppAssets.icNotificationPF,
                                title: s.account_page_util2,
                                onTap: _goNotification,
                              ),
                              _menuItem(
                                icon: AppAssets.icProtect,
                                title: s.account_page_util3,
                                onTap: _goPassword,
                              ),
                              _menuItem(
                                icon: AppAssets.icLangague,
                                title: s.account_page_util4,
                                onTap: _goLanguge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left:10),
                            child: Text(
                              s.account_page_title2,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          _roundedMenuContainer(
                            children: [
                              // _menuItem(
                              //   icon: AppAssets.icHelpCenter,
                              //   title: "Help Center",
                              //   onTap: () {},
                              // ),
                              // _menuItem(
                              //   icon: AppAssets.icUser,
                              //   title: "Privacy Policy",
                              //   onTap: () {},
                              // ),
                              _menuItem(
                                icon: AppAssets.icLogout,
                                title: s.account_page_util5,
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
        });
  }

  Widget _header(profile, LoadStatus status) {
    final screen = ScreenSize.of(context);

    final avatarSize = screen.width * 0.18;
    final cameraSize = avatarSize * 0.28;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
            child: SvgPicture.asset(
              AppAssets.profileBG,
              fit: BoxFit.cover,
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(bottom: screen.height * 0.032),
          child: status == LoadStatus.LOADING
              ? const CircularProgressIndicator(
                  color: AppColors.appBarGradientStart,
                )
              : profile == null
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            _buildAvatar(
                              profile.avatarUrl,
                              avatarSize,
                            ),
                            // Container(
                            //   width: cameraSize,
                            //   height: cameraSize,
                            //   decoration: const BoxDecoration(
                            //     color: Colors.white,
                            //     shape: BoxShape.circle,
                            //   ),
                            //   child: Icon(
                            //     Icons.camera_alt,
                            //     size: cameraSize * 0.55,
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.name ?? "",
                          style: TextStyle(
                            fontSize: screen.width * 0.045,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${profile.jobTitle ?? ''}  •  ${S.of(context).employee_card_id}: ${profile.employeeCode ?? ''}  •  ${profile.phone ?? ''}",
                          style: TextStyle(
                            color: AppColors.colorPrimary50,
                            fontSize: screen.width * 0.028,
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? url, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size * 0.05),
      ),
      child: ClipOval(
        child: Image.network(
          url ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Image.asset(
              AppAssets.img_df_avatar,
              fit: BoxFit.cover,
            );
          },
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
        ),
      ),
    );
  }

    // Widget _sectionTitle(String text) {
    //   return Padding(
    //     padding: const EdgeInsets.only(left: 10, bottom: 4),
    //     child: Text(
    //       text,
    //       style: TextStyle(
    //         fontSize: 13,
    //         fontWeight: FontWeight.w700,
    //         color: Colors.grey.shade600,
    //       ),
    //     ),
    //   );
    // }

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
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
