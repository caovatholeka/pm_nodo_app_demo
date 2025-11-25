import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  MyAppBar({
    super.key,
    this.actionCallBack,
    this.backAction,
    required this.titleAppbar,
    this.iconPathAsset,
    this.haveActionButton = false,
    this.haveBackButton = false,
    this.bottom,
    this.onPopInvoked,
    this.canPop = true,
    this.isTransparent = false,
  });

  final String titleAppbar;
  String? iconPathAsset;
  VoidCallback? actionCallBack;
  VoidCallback? backAction;
  bool? haveActionButton;
  bool? haveBackButton;
  PopInvokedCallback? onPopInvoked;
  PreferredSizeWidget? bottom;
  bool? canPop;
  bool? isTransparent;

  @override
  Widget build(BuildContext context) {
    final bool transparent = isTransparent == true;

    return PopScope(
      canPop: canPop ?? true,
      onPopInvoked: onPopInvoked,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,

        title: Text(
          titleAppbar,
          style: TextStyle(
            color: transparent ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        flexibleSpace: transparent
            ? null
            : Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.appbarBg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),

        leading: haveBackButton!
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: GestureDetector(
                  onTap: backAction ??
                      () {
                        Navigator.of(context).maybePop();
                      },
                  child: SvgPicture.asset(
                    AppAssets.icBack,
                  ),
                ),
              )
            : const SizedBox(),

        actions: [
          haveActionButton! && iconPathAsset != null
              ? _AppBarActionButton(
                  icon: iconPathAsset!,
                  onTap: actionCallBack,
                  isWhite: transparent,
                )
              : const SizedBox(),
        ],

        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize =>
      (bottom != null)
          ? const Size.fromHeight(112.0)
          : const Size.fromHeight(kToolbarHeight);
}

class _AppBarActionButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;
  final bool isWhite;

  const _AppBarActionButton({
    required this.icon,
    this.onTap,
    this.isWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isWhite ? Colors.white.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isWhite
                ? Border.all(color: Colors.white, width: 1)
                : null,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            color: isWhite ? Colors.white : AppColors.themePrimaryDefault,
          ),
        ),
      ),
    );
  }
}
