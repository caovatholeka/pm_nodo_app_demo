import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/radio_box_icon.dart';
import 'package:pm_app/app/features/widgets/radio_box_selected_icon.dart';
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
    final langName = code == "vi" ? "Tiếng Việt" : "English";
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        titleAppbar: s.btn_langauge,
        haveBackButton: true,
      ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                      _buildLanguageItem("🇻🇳  Tiếng Việt", "vi"),
                      const SizedBox(height: 16),
                      _buildLanguageItem("🇬🇧  English", "en"),
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

  Widget _buildLanguageItem(String title, String code) {
    final bool isSelected = selectedLang == code;

    return InkWell(
      onTap: () => _changeLanguage(code),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadow.boxShadowNormal,
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 8, 4, 255)
                : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            isSelected
                ? const RadioBoxSelectedIcon()
                : const RadioBoxIcon(),
          ],
        ),
      ),
    );
  }
}
