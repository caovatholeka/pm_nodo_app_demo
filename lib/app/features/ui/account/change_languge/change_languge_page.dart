import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/features/widgets/language_selector_item.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';

class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({super.key});

  @override
  State<ChangeLanguagePage> createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  String selectedLang = "vi";

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final lang = await SharedPrefsHelper.getAppLanguage();
    setState(() {
      selectedLang = lang;
    });
  }

  void _changeLanguage(String code) {
    setState(() => selectedLang = code);
    context.read<AppCubit>().changeAppLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(titleAppbar: s.language_title, haveBackButton: true, isTransparent: true,),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.appBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 120),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: AppShadow.pageBoxShadow,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      LanguageSelectorItem(
                        title: s.language_option1,
                        isSelected: selectedLang == "vi",
                        onTap: () => _changeLanguage("vi"),
                      ),

                      LanguageSelectorItem(
                        title: s.language_option2,
                        isSelected: selectedLang == "en",
                        onTap: () => _changeLanguage("en"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
