import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  BasicAppbar({
    super.key,
    this.actionCallBack,
    this.backAction,
    required this.titleAppbar,
    this.iconPathAsset,
    this.haveActionButton = false,
    this.haveBackButton = false,
    this.bottom,
    // this.onWillPop,
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

  // WillPopCallback? onWillPop;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop ?? true, // false : dismiss pop
      onPopInvoked: onPopInvoked,
      child: AppBar(
        title: Text(
          titleAppbar,
          style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        leading: haveBackButton!
            ? InkWell(
          child: IconButton(
            onPressed: () {
              if (backAction != null) {
                backAction!();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(AppAssets.icBack,width: 18,),
              ),
            ),
          ),
        )
            : const SizedBox(),
        actions: [
          haveActionButton! && iconPathAsset != null
              ? Container(
              margin: const EdgeInsets.only(right: 16),
              child: InkWell(
                onTap: actionCallBack,
                child: SvgPicture.asset(
                  iconPathAsset!,
                  width: 24,
                  height: 24,
                ),
              ))
              : const SizedBox()
        ],
        bottom: bottom,
      ),);
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => (bottom != null) ? const Size.fromHeight(112.0) :
  const Size.fromHeight(kToolbarHeight);
}