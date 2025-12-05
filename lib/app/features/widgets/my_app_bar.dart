import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;

import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppbar;
  final String? iconPathAsset;
  final VoidCallback? actionCallBack;
  final VoidCallback? backAction;
  final bool haveActionButton;
  final bool haveBackButton;
  final PreferredSizeWidget? bottom;
  final PopInvokedWithResultCallback? onPopInvokedWithResult;
  final bool canPop;
  final bool isTransparent;
  final int? badgeCount;

  const MyAppBar({
    super.key,
    required this.titleAppbar,
    this.iconPathAsset,
    this.actionCallBack,
    this.backAction,
    this.haveActionButton = false,
    this.haveBackButton = false,
    this.bottom,
    this.onPopInvokedWithResult,
    this.canPop = true,
    this.isTransparent = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final transparent = isTransparent;
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
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
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.appbarBg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
        leading: haveBackButton
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: GestureDetector(
                  onTap: backAction ??
                      () {
                        Navigator.of(context).maybePop();
                      },
                  child: SvgPicture.asset(AppAssets.icBack),
                ),
              )
            : const SizedBox(),
        actions: [
          if (haveActionButton && iconPathAsset != null)
            badges.Badge(
              showBadge: (badgeCount ?? 0) > 0,
              badgeContent: Text(
                (badgeCount ?? 0) > 99 ? "99+" : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
              ),
              position: badges.BadgePosition.topEnd(top: 0, end: 8, ),
              child: _AppBarActionButton(
                icon: iconPathAsset!,
                onTap: actionCallBack,
                isWhite: transparent,
              ),
            ),
        ],
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize =>
      bottom != null ? const Size.fromHeight(112) : const Size.fromHeight(kToolbarHeight);
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
    final bg = isWhite ? Colors.white.withValues(alpha: 0.15) : Colors.white;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: isWhite ? Border.all(color: Colors.white, width: 1) : null,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              isWhite ? Colors.white : AppColors.themePrimaryDefault,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
