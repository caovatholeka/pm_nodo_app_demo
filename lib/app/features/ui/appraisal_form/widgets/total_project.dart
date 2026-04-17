import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/data/models/entities/tasks_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/projects_param.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:pm_app/generated/l10n.dart';

class TotalProject extends StatelessWidget {
  final VoidCallback? onTap;

  const TotalProject({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.appraisal_project_title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  s.to_do_all,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ProjectTaskSection(),
        ],
      ),
    );
  }
}

class ProjectTaskSection extends StatelessWidget {
  final bool showShadowlessCards;

  const ProjectTaskSection({
    super.key,
    this.showShadowlessCards = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final visibleTasks = state.projectTasks;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProjectPicker(
              selectedProjectName:
                  state.selectedProjectName ?? state.projectTaskProjectName,
              projects: state.projects,
              isLoading: state.projectStatus == LoadStatus.LOADING,
            ),
            const SizedBox(height: 16),
            if (state.projectStatus == LoadStatus.LOADING)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              )
            else if (state.projectStatus == LoadStatus.FAILURE)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    s.appraisal_load_failed,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (visibleTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(s.appraisal_no_task),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleTasks.length,
                itemBuilder: (context, index) {
                  return ProjectTaskCard(
                    task: visibleTasks[index],
                    compactTopSpacing: showShadowlessCards,
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class ProjectPicker extends StatelessWidget {
  final String? selectedProjectName;
  final List<ProjectsParam> projects;
  final bool isLoading;

  const ProjectPicker({
    super.key,
    required this.selectedProjectName,
    required this.projects,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: isLoading ? null : () => _showProjectBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EEF6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedProjectName ?? s.appraisal_no_project_available,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              )
            else
              const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  void _showProjectBottomSheet(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    final s = S.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      s.appraisal_project_list,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (projects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(s.appraisal_no_projects),
                  )
                else
                  ...projects.map(
                    (project) => ProjectSheetTile(project: project),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectSheetTile extends StatelessWidget {
  final ProjectsParam project;

  const ProjectSheetTile({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardCubit>().state;
    final isSelected = state.selectedProjectId == project.projectID;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            state.projectStatus == LoadStatus.LOADING
                ? null
                : () async {
                  final cubit = context.read<DashboardCubit>();
                  cubit.selectProject(project);
                  Navigator.pop(context);
                  await cubit.getProjectTasks(projectId: project.projectID);
                },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  project.projectName ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Color(0xFF2563EB),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectTaskCard extends StatelessWidget {
  final TasksEntity task;
  final bool compactTopSpacing;

  const ProjectTaskCard({
    super.key,
    required this.task,
    this.compactTopSpacing = false,
  });

  String _formatDeadline(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final tag =
        (task.tags != null && task.tags!.isNotEmpty) ? task.tags!.first : '';
    final isFavorite = task.isFavorite == true;

    return Container(
      margin: EdgeInsets.only(bottom: compactTopSpacing ? 10 : 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isFavorite ? Icons.star : Icons.star,
                color: const Color(0xFFF4C542),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskName ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: Color(0xFF262626),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.appraisal_deadline}: ${_formatDeadline(task.deadline)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF808080),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _InfoColumn(
                  title: s.appraisal_assigned_employee,
                  value: task.assignedEmployeeName ?? '',
                  valueColor: const Color(0xFF1677FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: _InfoColumn(
                  title: s.appraisal_stage,
                  value: task.stage ?? '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _InfoColumn(
                  title: s.appraisal_tag,
                  value: tag,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoColumn({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8A8A8A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? const Color(0xFF3F3F46),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
