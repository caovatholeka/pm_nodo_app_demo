part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  final LoadStatus requestStatus;
  final LoadStatus workQualityStatus;
  final LoadStatus disciplineStatus;
  final LoadStatus disciplineDetailStatus;
  final LoadStatus taskStatus;
  final LoadStatus projectStatus;
  final LoadStatus birthdayStatus;
  final LoadStatus timesheetStatus;
  final LoadStatus suggestionStatus;

  final List<RequestSummaryEntity> requestSummaries;
  final WorkQualityEntity? workQuality;
  final WorkQualityEntity? worQualityDetail;
  final DisciplineEvaluationEntity? disciplineEvaluation;
  final DisciplineEvaluationDetailEntity? disciplineEvaluationDetail;
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
    this.disciplineDetailStatus = LoadStatus.INITIAL,
    this.taskStatus = LoadStatus.INITIAL,
    this.projectStatus = LoadStatus.INITIAL,
    this.birthdayStatus = LoadStatus.INITIAL,
    this.timesheetStatus = LoadStatus.INITIAL,
    this.suggestionStatus = LoadStatus.INITIAL,
    this.requestSummaries = const [],
    this.workQuality,
    this.worQualityDetail,
    this.disciplineEvaluation,
    this.disciplineEvaluationDetail,
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
    LoadStatus? disciplineDetailStatus,
    LoadStatus? taskStatus,
    LoadStatus? projectStatus,
    LoadStatus? birthdayStatus,
    LoadStatus? timesheetStatus,
    LoadStatus? suggestionStatus,
    List<RequestSummaryEntity>? requestSummaries,
    WorkQualityEntity? workQuality,
    WorkQualityEntity? worQualityDetail,
    DisciplineEvaluationEntity? disciplineEvaluation,
    DisciplineEvaluationDetailEntity? disciplineEvaluationDetail,
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
      disciplineDetailStatus:
          disciplineDetailStatus ?? this.disciplineDetailStatus,
      taskStatus: taskStatus ?? this.taskStatus,
      projectStatus: projectStatus ?? this.projectStatus,
      birthdayStatus: birthdayStatus ?? this.birthdayStatus,
      timesheetStatus: timesheetStatus ?? this.timesheetStatus,
      requestSummaries: requestSummaries ?? this.requestSummaries,
      workQuality: workQuality ?? this.workQuality,
      worQualityDetail: worQualityDetail ?? this.worQualityDetail,
      disciplineEvaluation: disciplineEvaluation ?? this.disciplineEvaluation,
      disciplineEvaluationDetail:
          disciplineEvaluationDetail ?? this.disciplineEvaluationDetail,
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
      suggestionStatus: suggestionStatus ?? this.suggestionStatus,
    );
  }

  @override
  List<Object?> get props => [
        requestStatus,
        workQualityStatus,
        disciplineStatus,
        disciplineDetailStatus,
        taskStatus,
        projectStatus,
        birthdayStatus,
        timesheetStatus,
        suggestionStatus,
        requestSummaries,
        workQuality,
        worQualityDetail,
        disciplineEvaluation,
        disciplineEvaluationDetail,
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
