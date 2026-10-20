import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/entities/task_stage_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';
import 'package:pm_app/app/features/ui_v2/task/create_new_task_v2.dart';
import 'package:pm_app/app/features/ui_v2/task/task_detail_page_v2.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Việc cần làm — giao diện tối (v2). Giữ nguyên hành vi bản cũ
/// [TaskManagePage]: nạp danh sách giai đoạn (`getListStages`) rồi danh sách
/// việc theo tab/từ khoá, đổi trạng thái qua bottom sheet, tạo mới, xem chi
/// tiết. Tái dùng nguyên [TaskCubit] qua GetIt. Trang tạo/xem chi tiết mở
/// bản tối ([CreateNewTaskV2], [TaskDetailPageV2]).
class TaskManagePageV2 extends StatefulWidget {
  final bool? isFromHome;
  const TaskManagePageV2({super.key, this.isFromHome});

  @override
  State<TaskManagePageV2> createState() => _TaskManagePageV2State();
}

class _TaskManagePageV2State extends State<TaskManagePageV2> {
  final _cubit = GetIt.I.get<TaskCubit>();

  final ScrollController controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.getListTasks();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    await _cubit.getListStages();
  }

  Future<void> _onRefresh() async {
    _cubit.getListTasks();
  }

  Future<void> _createNewTask() async {
    HapticFeedback.selectionClick();
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateNewTaskV2()),
    );

    if (result != null && result) {
      _onRefresh();
    }
  }

  Future<void> _openDetailTask(TaskEntity entity) async {
    HapticFeedback.selectionClick();
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TaskDetailPageV2(taskEntity: entity, taskId: entity.id),
      ),
    );

    if (result != null && result) {
      _onRefresh();
    }
  }

  Color _statusColor(String code) {
    switch (code) {
      case "new":
        return AppColors.newTask;
      case "in_progress":
        return AppColors.progressTask;
      case "done":
        return AppColors.doneTask;
      case "rejected":
        return AppColors.rejectTask;
      default:
        return AppTokensV2.fgMuted;
    }
  }

  void _updateTaskStatus(TaskEntity entity) async {
    HapticFeedback.selectionClick();
    final picked = await showModalBottomSheet<TaskStageEntity>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppTokensV2.bgTop,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _StageBottomSheetV2(
        listStages: _cubit.state.listTaskStages,
        currentTaskStatus: entity.stage?.code ?? "",
        colorFor: _statusColor,
      ),
    );

    if (picked != null) {
      _cubit.updateTaskStage((entity.id ?? 0).toString(), picked.id ?? 0);
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _goNotification() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
          child: const NotificationPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<TaskCubit, TaskState>(
      bloc: _cubit,
      listenWhen: (prev, cur) => prev.loadStatus != cur.loadStatus,
      listener: (context, state) {
        if (state.updateStageStatus == LoadStatus.LOADING ||
            state.getStageStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        } else {
          LoadingOverlay.hide(context);
        }
      },
      builder: (context, state) {
        final canShowBackButton =
            widget.isFromHome ?? Navigator.of(context).canPop();

        return Scaffold(
          backgroundColor: AppTokensV2.bgDeep,
          body: AmbientBackgroundV2(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: StaggerRevealV2(
                        index: 0, child: _topBar(s, canShowBackButton)),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: StaggerRevealV2(index: 1, child: _searchBar(s)),
                  ),
                  const SizedBox(height: 12),
                  StaggerRevealV2(index: 2, child: _tabBar()),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: _listTasks(s),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(S s, bool showBack) {
    return Row(children: [
      if (showBack) ...[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.maybePop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTokensV2.fg, size: 20),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Text(s.to_do_detail_title,
            style: AppTokensV2.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNotification,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            border: Border.all(color: AppTokensV2.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.notifications_none_rounded,
              size: 20, color: AppTokensV2.fgSoft),
        ),
      ),
    ]);
  }

  Widget _searchBar(S s) {
    return Row(children: [
      Expanded(
        child: BlocBuilder<TaskCubit, TaskState>(
          bloc: _cubit,
          buildWhen: (prev, cur) => prev.query != cur.query,
          builder: (context, state) {
            _searchController.text = state.query ?? "";
            return GlassCardV2(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              radius: 15,
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    _dismissKeyboard();
                    _cubit.getListTasks();
                  },
                  child: const Icon(Icons.search_rounded,
                      size: 19, color: AppTokensV2.fgMuted),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: AppTokensV2.body.copyWith(fontSize: 13.5),
                    cursorColor: AppTokensV2.accent,
                    textInputAction: TextInputAction.search,
                    onChanged: (val) => _cubit.onChangeQuery(val),
                    onSubmitted: (_) => _cubit.getListTasks(),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintText: s.to_searchbar,
                      hintStyle: AppTokensV2.caption,
                    ),
                  ),
                ),
                if ((state.query ?? "").isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _cubit.onChangeQuery("");
                      _cubit.getListTasks();
                    },
                    child: const Icon(Icons.close_rounded,
                        size: 17, color: AppTokensV2.fgMuted),
                  ),
              ]),
            );
          },
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _createNewTask,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppTokensV2.accentGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: AppTokensV2.glow,
                  blurRadius: 18,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 22),
        ),
      ),
    ]);
  }

  Widget _tabBar() {
    return BlocBuilder<TaskCubit, TaskState>(
      bloc: _cubit,
      buildWhen: (prev, cur) =>
          prev.loadStatus != cur.loadStatus ||
          prev.currentTabIndex != cur.currentTabIndex ||
          prev.listTaskStages != cur.listTaskStages,
      builder: (context, state) {
        final stages = state.listTaskStages ?? const <TaskStageEntity>[];
        if (stages.isEmpty) return const SizedBox(height: 36);
        return SizedBox(
          height: 36,
          child: ListView.separated(
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: stages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = stages[index];
              final selected = index == state.currentTabIndex;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (index != _cubit.state.currentTabIndex) {
                    HapticFeedback.selectionClick();
                    _cubit.onChangeTab(index);
                    _cubit.onChangeCurrentTabItem(item);
                    _cubit.getListTasks();
                  }
                },
                child: AnimatedContainer(
                  duration: AppTokensV2.dFast,
                  curve: AppTokensV2.easeExpo,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTokensV2.accent.withValues(alpha: 0.22)
                        : AppTokensV2.surfaceStrong,
                    border: Border.all(
                        color:
                            selected ? AppTokensV2.accent : AppTokensV2.border),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Text(
                    item.name ?? "",
                    style: TextStyle(
                      color: selected ? AppTokensV2.accent : AppTokensV2.fgSoft,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _listTasks(S s) {
    return BlocBuilder<TaskCubit, TaskState>(
      bloc: _cubit,
      buildWhen: (prev, cur) =>
          prev.loadStatus != cur.loadStatus || prev.listTasks != cur.listTasks,
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.LOADING) {
          return const Center(
            child: CircularProgressIndicator(
                strokeWidth: 2.2, color: AppTokensV2.accent),
          );
        }

        final list = state.listTasks ?? const <TaskEntity>[];
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.checklist_rounded,
                    size: 44, color: AppTokensV2.fgMuted),
                const SizedBox(height: 10),
                Text('Không có dữ liệu', style: AppTokensV2.captionStrong),
              ]),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTokensV2.accent,
          backgroundColor: AppTokensV2.bgTop,
          child: ListView.builder(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 4, bottom: 120),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final entity = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StaggerRevealV2(
                  index: index < 6 ? index : 0,
                  child: _taskCard(s, entity),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _taskCard(S s, TaskEntity entity) {
    final statusColor = _statusColor(entity.stage?.code ?? "");
    final assignees =
        entity.userIds?.map((u) => u.name).whereType<String>().join(", ") ??
            "";
    final hasPriority = (entity.priority ?? "").isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetailTask(entity),
      child: GlassCardV2(
        padding: const EdgeInsets.all(14),
        radius: 18,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(
              hasPriority ? Icons.star_rounded : Icons.star_border_rounded,
              size: 20,
              color: hasPriority ? AppTokensV2.warn : AppTokensV2.fgMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(entity.name ?? '-',
                  style: AppTokensV2.body.copyWith(fontSize: 14.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _updateTaskStatus(entity),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entity.stage?.name ?? '',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const Icon(Icons.expand_more_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if ((entity.assigner?.name ?? '').isNotEmpty)
            _infoRow('${s.to_do_card_taskmaster}: ${entity.assigner?.name}'),
          if (assignees.isNotEmpty)
            _infoRow('${s.to_taskempl}: $assignees'),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(
              child: _labelValue(s.to_do_card_deadline,
                  AppDateUtils.changeIso8601StringToDateTimeString(
                      entity.deadline ?? '')),
            ),
            Expanded(
              child: _labelValue(
                s.to_jobtype,
                (entity.taskType ?? '') == 'normal' ? 'Thông thường' : 'Tuyển dụng',
              ),
            ),
          ]),
          if ((entity.createdDate ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                AppDateUtils.changeIso8601StringToDateTimeString(
                    entity.createdDate ?? ''),
                style: AppTokensV2.caption,
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _infoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text,
          style: AppTokensV2.caption.copyWith(fontSize: 11.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTokensV2.caption.copyWith(fontSize: 10.5)),
      const SizedBox(height: 2),
      Text(value,
          style: AppTokensV2.captionStrong.copyWith(fontSize: 11.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
    ]);
  }
}

/// Bottom sheet chọn giai đoạn công việc — bản tối, thay [TaskStageBottomSheet].
class _StageBottomSheetV2 extends StatelessWidget {
  final List<TaskStageEntity>? listStages;
  final String? currentTaskStatus;
  final Color Function(String code) colorFor;

  const _StageBottomSheetV2({
    required this.listStages,
    required this.currentTaskStatus,
    required this.colorFor,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final stages = listStages ?? const <TaskStageEntity>[];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.to_status, style: AppTokensV2.section),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: stages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final value = stages[index];
                  final selected = currentTaskStatus == value.code;
                  final color = colorFor(value.code ?? "");
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context, value);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? Border.all(color: Colors.white, width: 1.4)
                            : null,
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Text(value.name ?? '',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                        if (selected)
                          const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
