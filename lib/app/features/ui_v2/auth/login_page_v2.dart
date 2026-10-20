import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/core/utils/validators.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/navigation/bottom_navigation.dart';
import 'package:pm_app/app/features/ui/auth/forgot_pass/forgot_cubit.dart';
import 'package:pm_app/app/features/ui/auth/forgot_pass/forgot_pass_page.dart';
import 'package:pm_app/app/features/ui/auth/login/login_cubit.dart';
import 'package:pm_app/di/di.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:another_flushbar/flushbar.dart';

/// Màn Đăng nhập — giao diện tối (v2). Hành vi giữ nguyên 100% bản cũ
/// (`lib/app/features/ui/auth/login/login_page.dart`): validate, đăng nhập,
/// nhớ tài khoản, quên mật khẩu, điều hướng khi thành công/thất bại.
/// Chỉ trình bày đổi. Tái dùng [LogInCubit].
class LoginPageV2 extends StatefulWidget {
  const LoginPageV2({super.key});

  @override
  State<LoginPageV2> createState() => _LoginPageV2State();
}

class _LoginPageV2State extends State<LoginPageV2> {
  final _userKey = GlobalKey<FormState>();
  final _passKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _cubit = sl<LogInCubit>();

  bool _obscurePwd = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    _cubit.resetState();
    _loadSavedUserName();
  }

  void _loadSavedUserName() async {
    final savedUser = await SharedPrefsHelper.getUsername();
    if (savedUser.isNotEmpty) {
      _userCtrl.text = savedUser;
      _cubit.onRememberMe(true);
    }
  }

  void _login() {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();
    if (username.isEmpty && password.isEmpty) {
      _showError(S.of(context).login_emptyUsernamePassword);
      return;
    }
    if (username.isEmpty) {
      _showError(S.of(context).login_emptyUsername);
      return;
    }
    if (password.isEmpty) {
      _showError(S.of(context).login_emptyPassword);
      return;
    }
    if (!(_userKey.currentState?.validate() ?? false) ||
        !(_passKey.currentState?.validate() ?? false)) {
      _showError(S.of(context).login_wrongUsernamePassword);
      return;
    }
    HapticFeedback.selectionClick();
    _cubit.doLogin(username, password);
  }

  void _showError(String msg) {
    Flushbar(
      message: msg,
      backgroundColor: AppTokensV2.danger,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(10),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocConsumer<LogInCubit, LoginState>(
      bloc: _cubit,
      listenWhen: (previous, current) =>
          previous.loginStatus != current.loginStatus &&
          (current.loginStatus == LoadStatus.SUCCESS ||
              current.loginStatus == LoadStatus.FAILURE),
      listener: (context, state) {
        if (state.loginStatus == LoadStatus.SUCCESS) {
          final pending = GlobalData.instance.quickActionPending;
          if (pending != null) {
            GlobalData.instance.isFromQuickAction = false;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavigation()),
          );
          return;
        }

        if (state.loginStatus == LoadStatus.FAILURE) {
          _showError(state.errMsg ?? s.login_Failed);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTokensV2.bgDeep,
          resizeToAvoidBottomInset: true,
          body: AmbientBackgroundV2(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final keyboard = MediaQuery.of(context).viewInsets.bottom;

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 18,
                      right: 18,
                      bottom: keyboard,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: keyboard == 0
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: [
                            StaggerRevealV2(
                              index: 0,
                              child: GlassCardV2(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 20,
                                ),
                                child: _buildLoginForm(context, state, s),
                              ),
                            ),
                            const SizedBox(height: 34),
                            if (keyboard == 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: StaggerRevealV2(
                                  index: 1,
                                  child: _buildFooter(s),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(BuildContext context, LoginState state, S s) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: AppTokensV2.accentGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTokensV2.glow,
                blurRadius: 26,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 18),
        Text(s.login_title, style: AppTokensV2.title.copyWith(fontSize: 20)),
        const SizedBox(height: 22),

        Form(
          key: _userKey,
          child: _inputField(
            controller: _userCtrl,
            hintText: s.username_hint,
            icon: Icons.person_outline_rounded,
            validator: (v) => Validator().validateUserName(v?.trim()),
          ),
        ),
        const SizedBox(height: 14),

        Form(
          key: _passKey,
          child: _inputField(
            controller: _passCtrl,
            hintText: s.password_hint,
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePwd,
            suffix: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _obscurePwd = !_obscurePwd),
              child: Icon(
                _obscurePwd
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
                color: AppTokensV2.fgMuted,
              ),
            ),
            validator: (v) => Validator.validateEmpty(v, s.password),
          ),
        ),
        const SizedBox(height: 16),

        _buildRememberForgot(state, s),
        const SizedBox(height: 24),

        state.loginStatus == LoadStatus.LOADING
            ? _loadingButton()
            : PrimaryButtonV2(label: s.login_button, onTap: _login),
        const SizedBox(height: 4),
      ],
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

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required FormFieldValidator<String> validator,
    bool obscure = false,
    Widget? suffix,
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
          Icon(icon, size: 18, color: AppTokensV2.fgMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              style: AppTokensV2.body,
              cursorColor: AppTokensV2.accent,
              validator: validator,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                errorStyle: const TextStyle(height: 0, fontSize: 0),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: hintText,
                hintStyle: AppTokensV2.caption,
              ),
            ),
          ),
          if (suffix != null) ...[const SizedBox(width: 8), suffix],
        ],
      ),
    );
  }

  Widget _buildRememberForgot(LoginState state, S s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            _cubit.onRememberMe(!(state.rememberMe ?? false));
          },
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  gradient: (state.rememberMe ?? false)
                      ? AppTokensV2.accentGradient
                      : null,
                  color: (state.rememberMe ?? false)
                      ? null
                      : AppTokensV2.surfaceStrong,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppTokensV2.border, width: 1.2),
                ),
                child: (state.rememberMe ?? false)
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(s.remember_me, style: AppTokensV2.captionStrong),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: sl<ForgotCubit>(),
                  child: const ForgotPassPage(),
                ),
              ),
            );
          },
          child: Text(
            s.forgot_password,
            style: AppTokensV2.captionStrong.copyWith(
              color: AppTokensV2.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(S s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16, color: AppTokensV2.fgMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            s.smallHint,
            style: AppTokensV2.caption,
          ),
        ),
      ],
    );
  }
}
