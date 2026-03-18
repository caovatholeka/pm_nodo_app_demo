import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;

import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  final bool autoLoadUnreadCount;

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
    this.autoLoadUnreadCount = true,
  });

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize =>
      bottom != null
          ? const Size.fromHeight(112)
          : const Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  bool _hasRequestedUnreadCount = false;

  bool get _shouldHandleUnreadCount =>
      widget.autoLoadUnreadCount &&
      widget.iconPathAsset == AppAssets.icNotificationBell;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestUnreadCountIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MyAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_shouldHandleUnreadCount) {
      _hasRequestedUnreadCount = false;
      return;
    }

    final oldShouldHandleUnreadCount =
        oldWidget.autoLoadUnreadCount &&
        oldWidget.iconPathAsset == AppAssets.icNotificationBell;

    if (!oldShouldHandleUnreadCount || oldWidget.iconPathAsset != widget.iconPathAsset) {
      _hasRequestedUnreadCount = false;
      _requestUnreadCountIfNeeded();
    }
  }

  void _requestUnreadCountIfNeeded() {
    if (_hasRequestedUnreadCount || !_shouldHandleUnreadCount) return;
    _hasRequestedUnreadCount = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        context.read<AppCubit>().countUnreadNoti();
      } catch (_) {
        _hasRequestedUnreadCount = false;
      }
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {int? resolvedBadgeCount}) {
    final transparent = widget.isTransparent;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text(
        widget.titleAppbar,
        style: TextStyle(
          color: transparent ? Colors.white : Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      flexibleSpace:
          transparent
              ? null
              : Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.appbarBg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
      leading:
          widget.haveBackButton
              ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: GestureDetector(
                  onTap:
                      widget.backAction ??
                      () {
                        final data = GlobalData.instance;
                        if (data.isFromQuickAction) {
                          data.isFromQuickAction = false;
                          data.navigatorKey.currentState?.popUntil(
                            (route) => route.isFirst,
                          );
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },

                  child: SvgPicture.asset(AppAssets.icBack),
                ),
              )
              : const SizedBox(),
      actions: [
        if (widget.haveActionButton && widget.iconPathAsset != null)
          badges.Badge(
            showBadge: (resolvedBadgeCount ?? 0) > 0,
            badgeContent: Text(
              (resolvedBadgeCount ?? 0) > 99
                  ? "99+"
                  : resolvedBadgeCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 8),
            ),
            position: badges.BadgePosition.topEnd(top: 0, end: 8),
            child: _AppBarActionButton(
              icon: widget.iconPathAsset!,
              onTap: widget.actionCallBack,
              isWhite: transparent,
            ),
          ),
      ],
      bottom: widget.bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canPop,
      onPopInvokedWithResult: widget.onPopInvokedWithResult,
      child:
          _shouldHandleUnreadCount
              ? BlocBuilder<AppCubit, AppState>(
                buildWhen: (prev, cur) => prev.totalUnread != cur.totalUnread,
                builder: (context, state) {
                  return _buildAppBar(
                    context,
                    resolvedBadgeCount: widget.badgeCount ?? state.totalUnread,
                  );
                },
              )
              : _buildAppBar(context, resolvedBadgeCount: widget.badgeCount),
    );
  }
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
