import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/dashboard/widgets/total_project.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

class ProjectsDetail extends StatefulWidget {
  const ProjectsDetail({super.key});

  @override
  State<ProjectsDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectsDetail> {
  final _cubit = GetIt.I.get<DashboardCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getProjectTasks();
  }

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
            titleAppbar: s.appraisal_project_title,
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
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: ProjectTaskSection(showShadowlessCards: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
