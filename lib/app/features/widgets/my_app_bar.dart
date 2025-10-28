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
        centerTitle: true,
        title: Text(
          titleAppbar,
          style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            icon: Image.asset(AppAssets.ic_arrowB)
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