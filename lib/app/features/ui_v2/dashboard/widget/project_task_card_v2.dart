import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/data/models/entities/tasks_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/projects_param.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/generated/l10n.dart';

/// Bản v2 (dark) của `ProjectPicker`
/// (lib/app/features/ui/dashboard/widgets/total_project.dart).
/// Cùng contract dữ liệu/callback: mở bottom sheet chọn dự án, gọi
/// [DashboardCubit.selectProject] + `getProjectTasks(projectId:)`.
class ProjectPickerV2 extends StatelessWidget {
  final String? selectedProjectName;
  final List<ProjectsParam> projects;
  final bool isLoading;

  const ProjectPickerV2({
    super.key,
    required this.selectedProjectName,
    required this.projects,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading
          ? null
          : () {
              HapticFeedback.selectionClick();
              _showProjectBottomSheet(context);
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppTokensV2.surfaceStrong,
          border: Border.all(color: AppTokensV2.border),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedProjectName ?? s.appraisal_no_project_available,
                style: AppTokensV2.body.copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: AppTokensV2.accent),
              )
            else
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: AppTokensV2.fgMuted),
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
      backgroundColor: AppTokensV2.bgTop,
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
                    color: AppTokensV2.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(s.appraisal_project_list, style: AppTokensV2.section),
                  ],
                ),
                const SizedBox(height: 12),
                if (projects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(s.appraisal_no_projects,
                        style: AppTokensV2.captionStrong),
                  )
                else
                  ...projects.map(
                    (project) => _ProjectSheetTileV2(project: project),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectSheetTileV2 extends StatelessWidget {
  final ProjectsParam project;

  const _ProjectSheetTileV2({required this.project});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardCubit>().state;
    final isSelected = state.selectedProjectId == project.projectID;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: state.projectStatus == LoadStatus.LOADING
          ? null
          : () async {
              HapticFeedback.selectionClick();
              final cubit = context.read<DashboardCubit>();
              cubit.selectProject(project);
              Navigator.pop(context);
              await cubit.getProjectTasks(projectId: project.projectID);
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTokensV2.accent.withValues(alpha: 0.16)
              : AppTokensV2.surfaceStrong,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? AppTokensV2.accent : AppTokensV2.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                project.projectName ?? '',
                style: AppTokensV2.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppTokensV2.accent : AppTokensV2.fg,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  size: 20, color: AppTokensV2.accent),
          ],
        ),
      ),
    );
  }
}

/// Bản v2 (dark) của `ProjectTaskCard` (cùng file).
class ProjectTaskCardV2 extends StatelessWidget {
  final TasksEntity task;

  const ProjectTaskCardV2({super.key, required this.task});

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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppTokensV2.surfaceStrong,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokensV2.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.star_rounded,
                  color: AppTokensV2.warn, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskName ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokensV2.body.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.appraisal_deadline}: ${_formatDeadline(task.deadline)}',
                      style: AppTokensV2.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _InfoColumnV2(
                  title: s.appraisal_assigned_employee,
                  value: task.assignedEmployeeName ?? '',
                  valueColor: AppTokensV2.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: _InfoColumnV2(
                  title: s.appraisal_stage,
                  value: task.stage ?? '',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _InfoColumnV2(title: s.appraisal_tag, value: tag),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoColumnV2 extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoColumnV2({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTokensV2.caption),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTokensV2.body.copyWith(
            fontSize: 13,
            color: valueColor ?? AppTokensV2.fgSoft,
          ),
        ),
      ],
    );
  }
}
