import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';

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

        title: Text(
          titleAppbar,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        leading: haveBackButton!
            ? IconButton(
                onPressed: backAction ??
                    () {
                      Navigator.of(context).maybePop();
                    },
                icon: Image.asset(
                  AppAssets.ic_arrowB,
                  width: 30,
                  height: 30,
                ),
              )
            : const SizedBox(),

        actions: [
          haveActionButton! && iconPathAsset != null
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: actionCallBack,
                    borderRadius: BorderRadius.circular(30),
                    child: SvgPicture.asset(
                      iconPathAsset!,
                      width: 30,
                      height: 30,
                    ),
                  ),
                )
              : const SizedBox()
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
