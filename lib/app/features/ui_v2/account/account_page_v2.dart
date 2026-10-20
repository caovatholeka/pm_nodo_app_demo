import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/theme_controller_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/account/account_cubit.dart';
import 'package:pm_app/app/features/ui/account/account_state.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui_v2/account/change_language_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/account/change_password_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/account/personal_info_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/notification/noti_page_v2.dart';
import 'package:pm_app/app/features/ui/auth/login/login_page.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Màn Cá nhân — phiên bản giao diện tối (v2). Nội dung giữ nguyên như bản cũ:
/// header hồ sơ + 4 mục tiện ích + Đăng xuất. Tái dùng [AccountCubit].
class AccountPageV2 extends StatefulWidget {
  const AccountPageV2({super.key});
  @override
  State<AccountPageV2> createState() => _AccountPageV2State();
}

class _AccountPageV2State extends State<AccountPageV2> {
  final AccountCubit _cubit = GetIt.I<AccountCubit>();
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _cubit.fetchUserProfile();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = info.version);
  }

  /// Như AccountPage v1: đăng xuất xong thì về màn đăng nhập.
  void _onLogoutStatus(BuildContext context, AccountState state) {
    if (state.logoutStatus == LoadStatus.LOADING) {
      LoadingOverlay.show(context);
      return;
    }
    LoadingOverlay.hide(context);
    if (state.logoutStatus == LoadStatus.SUCCESS) {
      _cubit.onResetStatus();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } else if (state.logoutStatus == LoadStatus.FAILURE) {
      _cubit.onResetStatus();
    }
  }

  void _goInfo() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const PersonalInfoPageV2()));

  void _goNotification() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => GetIt.I<NotiCubit>()..loadNotifications('all'),
            child: const NotificationPageV2(),
          ),
        ),
      );

  void _goPassword() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const ChangePasswordPageV2()));

  void _goLanguage() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const ChangeLanguagePageV2()));

  static String _themeLabel(ThemeModeV2 m) {
    switch (m) {
      case ThemeModeV2.system:
        return 'Theo hệ thống';
      case ThemeModeV2.dark:
        return 'Tối';
      case ThemeModeV2.light:
        return 'Sáng';
    }
  }

  void _pickTheme() {
    final ctrl = ThemeControllerV2.instance;
    const options = [
      (ThemeModeV2.system, Icons.brightness_auto_outlined),
      (ThemeModeV2.light, Icons.light_mode_outlined),
      (ThemeModeV2.dark, Icons.dark_mode_outlined),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: ValueListenableBuilder<ThemeModeV2>(
            valueListenable: ctrl.mode,
            builder: (_, current, __) => Container(
              decoration: BoxDecoration(
                color: AppTokensV2.bgTop,
                borderRadius: BorderRadius.circular(AppTokensV2.radius),
                border: Border.all(color: AppTokensV2.border),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Giao diện', style: AppTokensV2.section),
                  ),
                ),
                for (final (m, icon) in options)
                  ListTile(
                    leading: Icon(icon, color: AppTokensV2.accent),
                    title: Text(_themeLabel(m), style: AppTokensV2.body),
                    trailing: current == m
                        ? Icon(Icons.check_rounded, color: AppTokensV2.accent)
                        : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ctrl.setMode(m);
                      Navigator.pop(sheetCtx);
                    },
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _logout() {
    if (_cubit.state.logoutStatus == LoadStatus.LOADING) return;
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomDialog(
        title: s.dialog_logout_title,
        content: s.dialog_logout_subtitle,
        confirmText: s.dialog_logout_btn1,
        cancelText: s.dialog_logout_btn2,
        success: false,
        onConfirm: () async {
          Navigator.of(context, rootNavigator: true).pop();
          await _cubit.logout();
        },
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTokensV2.bgDeep,
        body: AmbientBackgroundV2(
          child: SafeArea(
            bottom: false,
            child: BlocConsumer<AccountCubit, AccountState>(
              listenWhen: (prev, cur) => prev.logoutStatus != cur.logoutStatus,
              listener: _onLogoutStatus,
              builder: (context, state) {
                final p = state.profile;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
                  children: [
                    StaggerRevealV2(
                      index: 0,
                      child: _profileCard(
                        name: p?.name ?? '',
                        jobTitle: p?.jobTitle ?? '',
                        code: p?.employeeCode ?? '',
                        phone: p?.phone ?? '',
                        avatarUrl: p?.avatarUrl,
                        loading: state.loadStatus == LoadStatus.LOADING,
                      ),
                    ),
                    const SizedBox(height: 22),
                    StaggerRevealV2(
                      index: 1,
                      child: _menuGroup([
                        _MenuRow(
                            icon: Icons.person_outline_rounded,
                            title: s.account_page_util1,
                            onTap: _goInfo),
                        _MenuRow(
                            icon: Icons.notifications_none_rounded,
                            title: s.account_page_util2,
                            onTap: _goNotification),
                        _MenuRow(
                            icon: Icons.lock_outline_rounded,
                            title: s.account_page_util3,
                            onTap: _goPassword),
                        _MenuRow(
                            icon: Icons.language_rounded,
                            title: s.account_page_util4,
                            onTap: _goLanguage),
                        _MenuRow(
                            icon: AppTokensV2.isDark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            title: 'Giao diện',
                            trailing: _themeLabel(
                                ThemeControllerV2.instance.mode.value),
                            onTap: _pickTheme),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    StaggerRevealV2(
                      index: 2,
                      child: _menuGroup([
                        _MenuRow(
                          icon: Icons.logout_rounded,
                          title: s.account_page_util5,
                          onTap: _logout,
                          danger: true,
                        ),
                      ]),
                    ),
                    if (_appVersion.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Center(
                        child: Text('App Version: $_appVersion',
                            style: AppTokensV2.caption),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileCard({
    required String name,
    required String jobTitle,
    required String code,
    required String phone,
    required String? avatarUrl,
    required bool loading,
  }) {
    final s = S.of(context);
    final meta = [
      if (jobTitle.isNotEmpty) jobTitle,
      if (code.isNotEmpty) '${s.employee_card_id}: $code',
      if (phone.isNotEmpty) phone,
    ].join('  •  ');

    return GlassCardV2(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      child: Column(children: [
        _avatar(avatarUrl, name),
        const SizedBox(height: 14),
        if (loading && name.isEmpty)
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTokensV2.accent),
          )
        else ...[
          Text(name,
              style: AppTokensV2.title.copyWith(fontSize: 19),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(meta,
                style: AppTokensV2.captionStrong,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ]),
    );
  }

  Widget _avatar(String? url, String name) {
    final raw = url?.trim();
    final uri = (raw == null || raw.isEmpty) ? null : Uri.tryParse(raw);
    final valid = uri != null && uri.hasScheme && uri.host.isNotEmpty;

    Widget fallback() {
      final parts = name.trim().split(RegExp(r'\s+'));
      String initials = 'U';
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        initials = parts.length == 1
            ? parts.first.characters.first.toUpperCase()
            : (parts.first.characters.first + parts.last.characters.first)
                .toUpperCase();
      }
      return Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: AppTokensV2.accentGradient, shape: BoxShape.circle),
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTokensV2.border, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppTokensV2.glow, blurRadius: 26, offset: const Offset(0, 8))
        ],
      ),
      child: ClipOval(
        child: valid
            ? CachedNetworkImage(
                imageUrl: raw!,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback(),
                errorWidget: (_, __, ___) => fallback(),
              )
            : fallback(),
      ),
    );
  }

  Widget _menuGroup(List<_MenuRow> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(Divider(
            height: 1, thickness: 1, color: AppTokensV2.border, indent: 58));
      }
    }
    return GlassCardV2(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;
  final String? trailing;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final dangerColor = AppTokensV2.danger;
    final tint = danger ? dangerColor : AppTokensV2.accent;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: AppTokensV2.body.copyWith(
                    color: danger ? dangerColor : AppTokensV2.fg,
                    fontSize: 13.5)),
          ),
          if (trailing != null) ...[
            Text(trailing!, style: AppTokensV2.caption),
            const SizedBox(width: 8),
          ],
          Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: AppTokensV2.fgMuted),
        ]),
      ),
    );
  }
}
