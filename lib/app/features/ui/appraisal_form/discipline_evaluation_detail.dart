import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/discipline_evaluation_detail_card.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

class DisciplineEvaluationDetail extends StatefulWidget {
  const DisciplineEvaluationDetail({super.key});

  @override
  State<DisciplineEvaluationDetail> createState() =>
      _DisciplineEvaluationDetailState();
}

class _DisciplineEvaluationDetailState extends State<DisciplineEvaluationDetail> {
  final _cubit = GetIt.I.get<DashboardCubit>();

  void _goNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
              child: const NotificationPage(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        backgroundColor: AppColors.bodyColor,
        extendBodyBehindAppBar: true,
        appBar: MyAppBar(
          titleAppbar: s.appraisal_discipline_title,
          haveBackButton: true,
          haveActionButton: true,
          iconPathAsset: AppAssets.icNotificationBell,
          actionCallBack: _goNotification,
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
                child: DisciplineEvaluationDetailCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
