import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/dashboard/widgets/birthday_card.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

class BirthdayListDetail extends StatefulWidget {
  const BirthdayListDetail({super.key});

  @override
  State<BirthdayListDetail> createState() => _BirthdayListDetailState();
}

class _BirthdayListDetailState extends State<BirthdayListDetail> {
  final _cubit = GetIt.I.get<DashboardCubit>();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        backgroundColor: AppColors.bodyColor,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: MyAppBar(
            titleAppbar: s.appraisal_birthday_month_title,
            haveBackButton: true,
            haveActionButton: true,
            iconPathAsset: AppAssets.icNotificationBell,
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                AppAssets.appbarBg,
                height: 170,
                fit: BoxFit.cover,
              ),
            ),
            const SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 24),
                child: BirthdayDetailSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
