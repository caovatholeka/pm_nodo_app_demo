import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

class NotiScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool haveBackButton;
  final bool haveActionButton;
  final String? iconPathAsset;
  final VoidCallback? onActionTap;
  final bool enableUnread;

  const NotiScaffold({
    super.key,
    required this.title,
    required this.body,
    this.haveBackButton = false,
    this.haveActionButton = false,
    this.iconPathAsset,
    this.onActionTap,
    this.enableUnread = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableUnread) {
      return Scaffold(
        appBar: MyAppBar(
          titleAppbar: title,
          haveBackButton: haveBackButton,
          haveActionButton: haveActionButton,
          iconPathAsset: iconPathAsset,
          actionCallBack: onActionTap,
        ),
        body: body,
      );
    }

    return BlocBuilder<NotiCubit, NotiState>(
      buildWhen: (p, c) => p.totalUnread != c.totalUnread,
      builder: (context, state) {
        return Scaffold(
          appBar: MyAppBar(
            titleAppbar: title,
            haveBackButton: haveBackButton,
            haveActionButton: haveActionButton,
            iconPathAsset: iconPathAsset,
            actionCallBack: onActionTap,
            badgeCount: state.totalUnread,
          ),
          body: body,
        );
      },
    );
  }
}
