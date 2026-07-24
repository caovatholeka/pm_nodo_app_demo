import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/account/changepassword/change_password_cubit.dart';
import 'package:pm_app/di/di.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Đổi mật khẩu — phiên bản giao diện tối (v2). Hành vi giữ nguyên bản cũ
/// (`change_password_page.dart`): cùng validate (không rỗng, mật khẩu mới
/// khớp regex hoa/thường/số/ký tự đặc biệt tối thiểu 8 ký tự, xác nhận khớp
/// mật khẩu mới), cùng gọi [ChangePasswordCubit.changePassword], cùng thông
/// báo thành công/thất bại. Chỉ trình bày đổi.
class ChangePasswordPageV2 extends StatelessWidget {
  const ChangePasswordPageV2({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordCubit(userRepository: sl()),
      child: const _ChangePasswordViewV2(),
    );
  }
}

class _ChangePasswordViewV2 extends StatefulWidget {
  const _ChangePasswordViewV2();

  @override
  State<_ChangePasswordViewV2> createState() => _ChangePasswordViewV2State();
}

class _ChangePasswordViewV2State extends State<_ChangePasswordViewV2> {
  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _showMessage(String title, String message, {bool success = false}) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      backgroundColor: success ? AppTokensV2.success : AppTokensV2.danger,
      icon: Icon(
        success ? Icons.check_circle : Icons.error,
        color: Colors.white,
      ),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  String? _validateNewPassword(String newPass) {
    final s = S.of(context);
    final regex =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');

    if (newPass.isEmpty) {
      return s.change_password_Empty;
    }

    if (!regex.hasMatch(newPass)) {
      return s.change_password_condistion;
    }

    return null;
  }

  String? _validateFields() {
    final s = S.of(context);
    final current = currentController.text.trim();
    final newPass = newController.text.trim();
    final confirm = confirmController.text.trim();

    if (current.isEmpty) {
      return s.change_password_Empty;
    }

    final newPassError = _validateNewPassword(newPass);
    if (newPassError != null) return newPassError;

    if (confirm.isEmpty) {
      return s.change_confirm_Empty;
    }

    if (confirm != newPass) {
      return s.change_password_NotMatch;
    }

    return null;
  }

  void _submit() {
    final error = _validateFields();
    if (error != null) {
      _showMessage(S.of(context).failed, error);
      return;
    }

    context.read<ChangePasswordCubit>().changePassword(
          currentPassword: currentController.text.trim(),
          newPassword: newController.text.trim(),
          confirmPassword: confirmController.text.trim(),
        );
  }

  void _clearFields() {
    currentController.clear();
    newController.clear();
    confirmController.clear();
  }

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state.status == LoadStatus.SUCCESS) {
          _showMessage(
            s.success,
            state.message ?? s.change_password_success,
            success: true,
          );
          _clearFields();
        }

        if (state.status == LoadStatus.FAILURE) {
          _showMessage(
            s.failed,
            (state.message != null && state.message!.trim().isNotEmpty)
                ? state.message!
                : s.cannot_change_password,
          );
        }
      },
      builder: (context, state) {
        final loading = state.status == LoadStatus.LOADING;
        return Scaffold(
          backgroundColor: AppTokensV2.bgDeep,
          resizeToAvoidBottomInset: true,
          body: AmbientBackgroundV2(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: StaggerRevealV2(
                      index: 0,
                      child: _topBar(s, loading: loading),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
                      child: StaggerRevealV2(
                        index: 1,
                        child: GlassCardV2(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "* ",
                                      style: TextStyle(
                                        color: AppTokensV2.danger,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: s.change_password_condistion,
                                      style: AppTokensV2.caption
                                          .copyWith(height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _label(s.change_password_current_hint),
                              const SizedBox(height: 6),
                              _inputField(
                                controller: currentController,
                                hintText: s.change_password_current,
                                obscure: _obscureCurrent,
                                onToggleObscure: () => setState(
                                    () => _obscureCurrent = !_obscureCurrent),
                              ),
                              const SizedBox(height: 14),
                              _label(s.change_password_new_hint),
                              const SizedBox(height: 6),
                              _inputField(
                                controller: newController,
                                hintText: s.change_password_new,
                                obscure: _obscureNew,
                                onToggleObscure: () => setState(
                                    () => _obscureNew = !_obscureNew),
                              ),
                              const SizedBox(height: 14),
                              _label(s.change_password_confirm_hint),
                              const SizedBox(height: 6),
                              _inputField(
                                controller: confirmController,
                                hintText: s.change_password_confirm,
                                obscure: _obscureConfirm,
                                onToggleObscure: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                              const SizedBox(height: 24),
                              loading
                                  ? _loadingButton()
                                  : PrimaryButtonV2(
                                      label: s.change_password_button,
                                      onTap: _submit,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(S s, {required bool loading}) {
    return Row(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (loading) {
            _showMessage(s.inProgress, s.inProgressSub);
            return;
          }
          Navigator.maybePop(context);
        },
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          s.change_password_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  Widget _label(String text) => Text(text, style: AppTokensV2.captionStrong);

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokensV2.surfaceStrong,
        border: Border.all(color: AppTokensV2.border),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 18, color: AppTokensV2.fgMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: AppTokensV2.body,
              cursorColor: AppTokensV2.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: hintText,
                hintStyle: AppTokensV2.caption,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleObscure,
            child: Icon(
              obscure
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 18,
              color: AppTokensV2.fgMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        gradient: AppTokensV2.accentGradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTokensV2.glow,
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      ),
    );
  }
}
