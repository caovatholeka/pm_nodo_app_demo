import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/entities/tasks_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/project_task_card_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn "Dự án" — chi tiết Dashboard, giao diện tối (v2).
///
/// Bản gốc: `lib/app/features/ui/dashboard/projects_detail.dart`
/// (+ `ProjectTaskSection` trong `widgets/total_project.dart`).
/// Giữ nguyên [DashboardCubit] qua GetIt, gọi `getProjectTasks()` ở
/// initState như bản gốc.
class ProjectsDetailV2 extends StatefulWidget {
  const ProjectsDetailV2({super.key});

  @override
  State<ProjectsDetailV2> createState() => _ProjectsDetailV2State();
}

class _ProjectsDetailV2State extends State<ProjectsDetailV2> {
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
        backgroundColor: AppTokensV2.bgDeep,
        body: AmbientBackgroundV2(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: StaggerRevealV2(index: 0, child: _topBar(s)),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: StaggerRevealV2(
                      index: 1,
                      child: GlassCardV2(
                        child: BlocBuilder<DashboardCubit, DashboardState>(
                          builder: (context, state) {
                            final visibleTasks = state.projectTasks;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProjectPickerV2(
                                  selectedProjectName:
                                      state.selectedProjectName ??
                                          state.projectTaskProjectName,
                                  projects: state.projects,
                                  isLoading:
                                      state.projectStatus == LoadStatus.LOADING,
                                ),
                                const SizedBox(height: 16),
                                if (state.projectStatus == LoadStatus.LOADING)
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 28),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          color: AppTokensV2.accent,
                                          strokeWidth: 2.2),
                                    ),
                                  )
                                else if (state.projectStatus ==
                                    LoadStatus.FAILURE)
                                  _emptyState(s.appraisal_load_failed)
                                else if (visibleTasks.isEmpty)
                                  _emptyState(s.appraisal_no_task)
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: visibleTasks.length,
                                    itemBuilder: (context, index) {
                                      final TasksEntity task =
                                          visibleTasks[index];
                                      return ProjectTaskCardV2(task: task);
                                    },
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(S s) {
    return Row(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          s.appraisal_project_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.folder_off_outlined,
                size: 36, color: AppTokensV2.fgMuted),
            const SizedBox(height: 10),
            Text(message, style: AppTokensV2.captionStrong),
          ],
        ),
      ),
    );
  }
}
