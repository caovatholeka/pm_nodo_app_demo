import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/data/models/entities/tasks_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/projects_param.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';

class TotalProject extends StatelessWidget {
  const TotalProject({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final visibleTasks = state.projectTasks;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Dự án',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProjectPicker(
                selectedProjectName:
                    state.selectedProjectName ?? state.projectTaskProjectName,
                projects: state.projects,
                isLoading: state.projectStatus == LoadStatus.LOADING,
              ),
              const SizedBox(height: 16),
              if (state.projectStatus == LoadStatus.LOADING)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.projectStatus == LoadStatus.FAILURE)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Khong tai duoc du lieu',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (visibleTasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Khong co task'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleTasks.length,
                  itemBuilder: (context, index) {
                    return _ProjectTaskCard(task: visibleTasks[index]);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProjectPicker extends StatelessWidget {
  final String? selectedProjectName;
  final List<ProjectsParam> projects;
  final bool isLoading;

  const _ProjectPicker({
    required this.selectedProjectName,
    required this.projects,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
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
                selectedProjectName ?? 'Chon du an',
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
                child: CircularProgressIndicator(strokeWidth: 2),
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
                const Row(
                  children: [
                    Text(
                      'Chon du an',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (projects.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('Khong co du an'),
                  )
                else
                  ...projects.map(
                    (project) => _ProjectSheetTile(project: project),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectSheetTile extends StatelessWidget {
  final ProjectsParam project;

  const _ProjectSheetTile({required this.project});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardCubit>().state;
    final isSelected = state.selectedProjectId == project.projectID;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: state.projectStatus == LoadStatus.LOADING
            ? null
            : () async {
                final cubit = context.read<DashboardCubit>();
                cubit.selectProject(project);
                Navigator.pop(context);
                await cubit.getProjectTasks();
              },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
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
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
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

class _ProjectTaskCard extends StatelessWidget {
  final TasksEntity task;

  const _ProjectTaskCard({required this.task});

  String _formatDeadline(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final tag =
        (task.tags != null && task.tags!.isNotEmpty) ? task.tags!.first : '';
    final isFavorite = task.isFavorite == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
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
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFE5E7EB),
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: isFavorite
                            ? Colors.black87
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deadline: ${_formatDeadline(task.deadline)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
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
                  title: 'NV phân công',
                  value: task.assignedEmployeeName ?? '',
                  valueColor: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: _InfoColumn(
                  title: 'Giai đoạn',
                  value: task.stage ?? '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _InfoColumn(
                  title: 'Thẻ',
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
            color: Color(0xFF6B7280),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? const Color(0xFF374151),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
