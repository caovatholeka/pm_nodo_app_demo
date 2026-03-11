part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  final LoadStatus requestStatus;
  final LoadStatus workQualityStatus;
  final LoadStatus disciplineStatus;
  final LoadStatus taskStatus;
  final LoadStatus projectStatus;
  final LoadStatus birthdayStatus;
  final LoadStatus timesheetStatus;

  final List<RequestSummaryEntity> requestSummaries;
  final WorkQualityEntity? workQuality;
  final WorkQualityEntity? worQualityDetail;
  final DisciplineEvaluationEntity? disciplineEvaluation;
  final List<TasksEntity> todayTasks;
  final List<ProjectsParam> projects;
  final List<TasksEntity> projectTasks;
  final int? selectedProjectId;
  final String? selectedProjectName;
  final int? projectTaskProjectId;
  final String? projectTaskProjectName;
  final List<BirthdaysEntity> birthdays;
  final TimesheetEntity? timesheet;
  final String? errorMessage;

  const DashboardState({
    this.requestStatus = LoadStatus.INITIAL,
    this.workQualityStatus = LoadStatus.INITIAL,
    this.disciplineStatus = LoadStatus.INITIAL,
    this.taskStatus = LoadStatus.INITIAL,
    this.projectStatus = LoadStatus.INITIAL,
    this.birthdayStatus = LoadStatus.INITIAL,
    this.timesheetStatus = LoadStatus.INITIAL,
    this.requestSummaries = const [],
    this.workQuality,
    this.worQualityDetail,
    this.disciplineEvaluation,
    this.todayTasks = const [],
    this.projects = const [],
    this.projectTasks = const [],
    this.selectedProjectId,
    this.selectedProjectName,
    this.projectTaskProjectId,
    this.projectTaskProjectName,
    this.birthdays = const [],
    this.timesheet,
    this.errorMessage,
  });

  DashboardState copyWith({
    LoadStatus? requestStatus,
    LoadStatus? workQualityStatus,
    LoadStatus? disciplineStatus,
    LoadStatus? taskStatus,
    LoadStatus? projectStatus,
    LoadStatus? birthdayStatus,
    LoadStatus? timesheetStatus,
    List<RequestSummaryEntity>? requestSummaries,
    WorkQualityEntity? workQuality,
    WorkQualityEntity? worQualityDetail,
    DisciplineEvaluationEntity? disciplineEvaluation,
    List<TasksEntity>? todayTasks,
    List<ProjectsParam>? projects,
    List<TasksEntity>? projectTasks,
    int? selectedProjectId,
    String? selectedProjectName,
    int? projectTaskProjectId,
    String? projectTaskProjectName,
    List<BirthdaysEntity>? birthdays,
    TimesheetEntity? timesheet,
    String? errorMessage,
  }) {
    return DashboardState(
      requestStatus: requestStatus ?? this.requestStatus,
      workQualityStatus: workQualityStatus ?? this.workQualityStatus,
      disciplineStatus: disciplineStatus ?? this.disciplineStatus,
      taskStatus: taskStatus ?? this.taskStatus,
      projectStatus: projectStatus ?? this.projectStatus,
      birthdayStatus: birthdayStatus ?? this.birthdayStatus,
      timesheetStatus: timesheetStatus ?? this.timesheetStatus,
      requestSummaries: requestSummaries ?? this.requestSummaries,
      workQuality: workQuality ?? this.workQuality,
      worQualityDetail: worQualityDetail ?? this.worQualityDetail,
      disciplineEvaluation: disciplineEvaluation ?? this.disciplineEvaluation,
      todayTasks: todayTasks ?? this.todayTasks,
      projects: projects ?? this.projects,
      projectTasks: projectTasks ?? this.projectTasks,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
      selectedProjectName: selectedProjectName ?? this.selectedProjectName,
      projectTaskProjectId: projectTaskProjectId ?? this.projectTaskProjectId,
      projectTaskProjectName:
          projectTaskProjectName ?? this.projectTaskProjectName,
      birthdays: birthdays ?? this.birthdays,
      timesheet: timesheet ?? this.timesheet,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        requestStatus,
        workQualityStatus,
        disciplineStatus,
        taskStatus,
        projectStatus,
        birthdayStatus,
        timesheetStatus,
        requestSummaries,
        workQuality,
        worQualityDetail,
        disciplineEvaluation,
        todayTasks,
        projects,
        projectTasks,
        selectedProjectId,
        selectedProjectName,
        projectTaskProjectId,
        projectTaskProjectName,
        birthdays,
        timesheet,
        errorMessage,
      ];
}
