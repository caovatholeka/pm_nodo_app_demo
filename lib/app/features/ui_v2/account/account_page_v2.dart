import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/account/account_cubit.dart';
import 'package:pm_app/app/features/ui/account/account_state.dart';
import 'package:pm_app/app/features/ui/account/change_languge/change_languge_page.dart';
import 'package:pm_app/app/features/ui/account/changepassword/change_password_page.dart';
import 'package:pm_app/app/features/ui/account/personal_info/personal_info_page.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Cá nhân — phiên bản giao diện tối (v2). Nội dung giữ nguyên như bản cũ:
/// header hồ sơ + 4 mục tiện ích + Đăng xuất. Tái dùng [AccountCubit].
class AccountPageV2 extends StatefulWidget {
  const AccountPageV2({super.key});
  @override
  State<AccountPageV2> createState() => _AccountPageV2State();
}

class _AccountPageV2State extends State<AccountPageV2> {
  final AccountCubit _cubit = GetIt.I<AccountCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.fetchUserProfile();
  }

  void _goInfo() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const PersonalInfoPage()));

  void _goNotification() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => GetIt.I<NotiCubit>()..loadNotifications('all'),
            child: const NotificationPage(),
          ),
        ),
      );

  void _goPassword() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));

  void _goLanguage() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const ChangeLanguagePage()));

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
            child: BlocBuilder<AccountCubit, AccountState>(
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
    required String? avatarUrl,
    required bool loading,
  }) {
    final s = S.of(context);
    final meta = [
      if (jobTitle.isNotEmpty) jobTitle,
      if (code.isNotEmpty) '${s.employee_card_id}: $code',
    ].join('  •  ');

    return GlassCardV2(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      child: Column(children: [
        _avatar(avatarUrl, name),
        const SizedBox(height: 14),
        if (loading && name.isEmpty)
          const SizedBox(
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
        decoration: const BoxDecoration(
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
        children.add(const Divider(
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

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    const dangerColor = AppTokensV2.danger;
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
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: AppTokensV2.fgMuted),
        ]),
      ),
    );
  }
}
