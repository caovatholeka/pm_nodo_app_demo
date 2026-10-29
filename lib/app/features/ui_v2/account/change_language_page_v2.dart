import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Ngôn ngữ — phiên bản giao diện tối (v2). Đổi ngôn ngữ qua
/// [AppCubit.changeAppLanguage]. Mục được chọn lấy theo ngôn ngữ app ĐANG hiển thị
/// (Localizations), nên luôn khớp với chữ trên màn — kể cả lúc mới mở (trước đây
/// mặc định "vi" rồi mới đọc SharedPrefs → app đang tiếng Anh vẫn thoáng hiện chọn
/// Tiếng Việt).
class ChangeLanguagePageV2 extends StatefulWidget {
  const ChangeLanguagePageV2({super.key});

  @override
  State<ChangeLanguagePageV2> createState() => _ChangeLanguagePageV2State();
}

class _ChangeLanguagePageV2State extends State<ChangeLanguagePageV2> {
  /// Ngôn ngữ vừa bấm chọn (hiện ngay, trong lúc app đổi locale); null = theo
  /// ngôn ngữ đang hiển thị.
  String? _pendingLang;

  String get _currentLang =>
      _pendingLang ?? Localizations.localeOf(context).languageCode;

  void _changeLanguage(String code) {
    if (_currentLang == code) return;
    HapticFeedback.selectionClick();
    setState(() => _pendingLang = code);
    context.read<AppCubit>().changeAppLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final selectedLang = _currentLang;

    return Scaffold(
      backgroundColor: AppTokensV2.bgDeep,
      body: AmbientBackgroundV2(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: StaggerRevealV2(index: 0, child: _topBar(s)),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
                  children: [
                    StaggerRevealV2(
                      index: 1,
                      child: GlassCardV2(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _langRow(
                              title: s.language_option1,
                              selected: selectedLang == "vi",
                              onTap: () => _changeLanguage("vi"),
                            ),
                            Divider(
                                height: 1,
                                thickness: 1,
                                color: AppTokensV2.border,
                                indent: 18),
                            _langRow(
                              title: s.language_option2,
                              selected: selectedLang == "en",
                              onTap: () => _changeLanguage("en"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(S s) {
    return Row(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          s.language_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  Widget _langRow({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTokensV2.body.copyWith(
                  color: selected ? AppTokensV2.accent : AppTokensV2.fg,
                  fontSize: 14,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: AppTokensV2.accent, size: 20)
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTokensV2.border, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
