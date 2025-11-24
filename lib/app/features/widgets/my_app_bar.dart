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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop ?? true,
      onPopInvoked: onPopInvoked,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 60,

        title: Text(
          titleAppbar,
          style: const TextStyle(
            color: AppColors.textBlack600,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        flexibleSpace: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.appbarBg),
              fit: BoxFit.fill,
            ),
          ),
        ),
        leading:
            haveBackButton!
                ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: GestureDetector(
                      onTap: backAction ?? () {Navigator.of(context).maybePop(); },
                      child: SvgPicture.asset(AppAssets.icBack,width: 30,height: 30,)
                  ),
                )
                : const SizedBox(),

        actions: [
          haveActionButton! && iconPathAsset != null
              ? _AppBarActionButton(
                  icon: iconPathAsset!,
                  onTap: actionCallBack,
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

class _AppBarBackButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;

  const _AppBarBackButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16), 
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 44,  
          height: 44,    
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), 
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            icon,
            width: 16, 
            height: 16,
            color: Colors.black, 
          ),
        ),
      ),
    );
  }
}

class _AppBarActionButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;

  const _AppBarActionButton({
    required this.icon,
    this.onTap,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            color: AppColors.themePrimaryDefault,
          ),
        ),
      ),
    );
  }
}
