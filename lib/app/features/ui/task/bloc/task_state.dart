part of 'task_cubit.dart';

class TaskState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus getStageStatus;
  final LoadStatus updateStageStatus;
  final LoadStatus createStatus;
  final LoadStatus loadDetailStatus;
  final LoadStatus deleteStatus;
  final LoadStatus updateStatus;
  final List<TaskEntity>? listTasks;
  final List<TaskStageEntity>? listTaskStages;
  final int currentTabIndex;
  final TaskStageEntity? currentTabItem;
  final String? query;

  // detail
  final TaskEntity? detailTask;

  // create task
  final List<UserEntity>? listUsers;
  final List<UserEntity>? currentUsers;
  final String? strUsers;
  final String? taskName;
  final bool taskPriority;
  final DateTime? deadlineDateTime;
  final String? deadlineTime;
  final String? description;

  const TaskState({
    this.loadStatus = LoadStatus.INITIAL,
    this.getStageStatus = LoadStatus.INITIAL,
    this.updateStageStatus = LoadStatus.INITIAL,
    this.createStatus = LoadStatus.INITIAL,
    this.loadDetailStatus = LoadStatus.INITIAL,
    this.deleteStatus = LoadStatus.INITIAL,
    this.updateStatus = LoadStatus.INITIAL,
    this.listTasks,
    this.listTaskStages,
    this.currentTabIndex = 0,
    this.currentTabItem,
    this.detailTask,
    this.query,
    this.taskName,
    this.taskPriority = false,
    this.listUsers,
    this.currentUsers,
    this.strUsers,
    this.deadlineDateTime,
    this.deadlineTime,
    this.description
  });

  TaskState copyWith({
    bool resetDateTime = false,
    LoadStatus? loadStatus,
    LoadStatus? getStageStatus,
    LoadStatus? updateStageStatus,
    LoadStatus? createStatus,
    LoadStatus? loadDetailStatus,
    LoadStatus? deleteStatus,
    LoadStatus? updateStatus,
    List<TaskEntity>? listTasks,
    List<TaskStageEntity>? listTaskStages,
    int? currentTabIndex,
    TaskStageEntity? currentTabItem,
    TaskEntity? detailTask,
    String? query,
    String? taskName,
    bool? taskPriority,
    List<UserEntity>? listUsers,
    List<UserEntity>? currentUsers,
    String? strUsers,
    DateTime? deadlineDateTime,
    String? deadlineTime,
    String? description,
  }) {
    return TaskState(
      loadStatus: loadStatus ?? this.loadStatus,
      getStageStatus: getStageStatus ?? this.getStageStatus,
      updateStageStatus: updateStageStatus ?? this.updateStageStatus,
      createStatus: createStatus ?? this.createStatus,
      loadDetailStatus: loadDetailStatus ?? this.loadDetailStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      updateStatus: updateStageStatus ?? this.updateStatus,
      listTasks: listTasks ?? this.listTasks,
      listTaskStages: listTaskStages ?? this.listTaskStages,
      detailTask: detailTask ?? this.detailTask,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      currentTabItem: currentTabItem ?? this.currentTabItem,
      query: query ?? this.query,
      taskName: taskName ?? this.taskName,
      taskPriority: taskPriority ?? this.taskPriority,
      listUsers: listUsers ?? this.listUsers,
      currentUsers: currentUsers ?? this.currentUsers,
      strUsers: strUsers ?? this.strUsers,
      deadlineDateTime: resetDateTime ? null : (deadlineDateTime ?? this.deadlineDateTime),
      deadlineTime: deadlineTime ?? this.deadlineTime,
      description: description ?? this.description
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    getStageStatus,
    updateStageStatus,
    createStatus,
    loadDetailStatus,
    deleteStatus,
    updateStatus,
    listTasks,
    detailTask,
    listTaskStages,
    currentTabIndex,
    currentTabItem,
    query,
    taskName,
    taskPriority,
    listUsers,
    currentUsers,
    strUsers,
    deadlineDateTime,
    deadlineTime,
    description
  ];
}