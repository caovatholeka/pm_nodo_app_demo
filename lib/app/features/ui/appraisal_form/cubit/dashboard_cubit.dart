import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/birthdays_entity.dart';
import 'package:pm_app/app/data/models/entities/birthdays_this_month_entity.dart';
import 'package:pm_app/app/data/models/entities/discipline_evaluation_detail_entity.dart';
import 'package:pm_app/app/data/models/entities/discipline_evaluation_entity.dart';
import 'package:pm_app/app/data/models/entities/project_tasks_entity.dart';
import 'package:pm_app/app/data/models/entities/request_summary_entity.dart';
import 'package:pm_app/app/data/models/entities/tasks_entity.dart';
import 'package:pm_app/app/data/models/entities/timesheet_entity.dart';
import 'package:pm_app/app/data/models/entities/work_quality_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/projects_param.dart';
import 'package:pm_app/app/data/models/param/send_suggestion_param.dart';
import 'package:pm_app/app/data/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  DashboardCubit({required DashboardRepository repository})
    : _repository = repository,
      super(const DashboardState());

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Map<String, dynamic>? _extractPayload(dynamic response) {
    final root = _asMap(response);
    if (root == null) {
      return null;
    }

    final nestedData = _asMap(root['data']);
    return nestedData ?? root;
  }

  Future<void> getRequestSummaries() async {
    try {
      emit(state.copyWith(requestStatus: LoadStatus.LOADING));

      final res = await _repository.getRequestSumaries();
      final dataMap =
          res.data is Map ? Map<String, dynamic>.from(res.data as Map) : null;
      final rawItems =
          res.items ??
          dataMap?['items'] ??
          (res.data is List ? res.data : null);

      final items = mapList(rawItems, RequestSummaryEntity.fromJson);

      emit(
        state.copyWith(
          requestStatus: LoadStatus.SUCCESS,
          requestSummaries: items,
        ),
      );
    } catch (e, s) {
      logger.d(e);
      logger.d(s);
      emit(
        state.copyWith(
          requestStatus: LoadStatus.FAILURE,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getWorkQuality(String month) async {
    try {
      emit(state.copyWith(workQualityStatus: LoadStatus.LOADING));

      final entity = await _repository.getWorkQuality(month);
      emit(
        state.copyWith(
          workQualityStatus: LoadStatus.SUCCESS,
          workQuality: entity,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.d(s);
      emit(state.copyWith(workQualityStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> getDisciplineEvaluation(int month) async {
    try {
      emit(state.copyWith(disciplineStatus: LoadStatus.LOADING));

      final entity = await _repository.getDisciplineEvaluation(month);

      emit(
        state.copyWith(
          disciplineStatus: LoadStatus.SUCCESS,
          disciplineEvaluation: entity,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.d(s);

      emit(
        state.copyWith(
          disciplineStatus: LoadStatus.FAILURE,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getDisciplineEvaluationDetail(int month) async {
    try {
      emit(state.copyWith(disciplineDetailStatus: LoadStatus.LOADING));

      final entity = await _repository.getDetailDisciplineEvaluation(month);

      emit(
        state.copyWith(
          disciplineDetailStatus: LoadStatus.SUCCESS,
          disciplineEvaluationDetail: entity,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.d(s);
      emit(
        state.copyWith(
          disciplineDetailStatus: LoadStatus.FAILURE,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<ProjectTasksEntity> _loadProjectTasks() {
    return _repository.getProjectTasks().then((res) {
      final payload = _extractPayload(res);
      final entity = mapObject(payload, ProjectTasksEntity.fromJson);

      if (entity == null) {
        throw Exception('Invalid project tasks response');
      }

      return entity;
    });
  }

  Future<void> getProjects() async {
    try {
      final res = await _repository.getProjects();
      final dataMap = _extractPayload(res);
      final rawProjects =
          dataMap?['projects'] ??
          dataMap?['items'] ??
          (res is Map ? res['items'] : null) ??
          (res is List ? res : null);
      final projects = mapList(rawProjects, ProjectsParam.fromJson);
      final firstProject = projects.isNotEmpty ? projects.first : null;
      final firstProjectId = firstProject?.projectID;
      final selectedProjectId =
          state.projectTaskProjectId ??
          state.selectedProjectId ??
          firstProjectId;
      final selectedProjectName =
          state.projectTaskProjectName ??
          state.selectedProjectName ??
          firstProject?.projectName;

      emit(
        state.copyWith(
          projects: projects,
          selectedProjectId: selectedProjectId,
          selectedProjectName: selectedProjectName,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.d(s);
      emit(state.copyWith(projectStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> getTodayTasks() async {
    try {
      emit(state.copyWith(taskStatus: LoadStatus.LOADING));
      final entity = await _loadProjectTasks();
      emit(
        state.copyWith(
          taskStatus: LoadStatus.SUCCESS,
          todayTasks: entity.tasks ?? const <TasksEntity>[],
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.d(s);
      emit(state.copyWith(taskStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> getProjectTasks() async {
    try {
      emit(state.copyWith(projectStatus: LoadStatus.LOADING));

      final entity = await _loadProjectTasks();
      emit(
        state.copyWith(
          projectStatus: LoadStatus.SUCCESS,
          projectTasks: entity.tasks ?? const <TasksEntity>[],
          selectedProjectId: state.selectedProjectId ?? entity.projectID,
          selectedProjectName: state.selectedProjectName ?? entity.projectName,
          projectTaskProjectId: entity.projectID,
          projectTaskProjectName: entity.projectName,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.d(s);
      emit(state.copyWith(projectStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> getListProject() async {
    try {
      emit(state.copyWith(projectStatus: LoadStatus.LOADING));

      final entity = await _loadProjectTasks();
      emit(
        state.copyWith(
          projectStatus: LoadStatus.SUCCESS,
          projectTasks: entity.tasks ?? const <TasksEntity>[],
          selectedProjectId: state.selectedProjectId ?? entity.projectID,
          selectedProjectName: state.selectedProjectName ?? entity.projectName,
          projectTaskProjectId: entity.projectID,
          projectTaskProjectName: entity.projectName,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.d(s);
      emit(state.copyWith(projectStatus: LoadStatus.FAILURE));
    }
  }

  void selectProject(ProjectsParam project) {
    emit(
      state.copyWith(
        selectedProjectId: project.projectID,
        selectedProjectName: project.projectName,
      ),
    );
  }

  Future<void> getTimeSheetData(int month) async {
    try {
      emit(state.copyWith(timesheetStatus: LoadStatus.LOADING));

      final res = await _repository.getTimeSheetData(month);
      final dataMap = _extractPayload(res);
      final entity = mapObject(dataMap, TimesheetEntity.fromJson);

      emit(
        state.copyWith(timesheetStatus: LoadStatus.SUCCESS, timesheet: entity),
      );
    } catch (e, s) {
      logger.e(e);
      logger.d(s);
      emit(
        state.copyWith(
          timesheetStatus: LoadStatus.FAILURE,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getBirthdaysThisMonth(int month) async {
    try {
      emit(state.copyWith(birthdayStatus: LoadStatus.LOADING));

      final res = await _repository.getBirthdaysThisMonth(month);
      final dataMap = _extractPayload(res);
      final rawItems =
          dataMap?['birthdays'] ??
          dataMap?['items'] ??
          (res is Map ? res['items'] : null) ??
          (res is List ? res : null);

      final entity = mapObject(dataMap, BirthdaysThisMonthEntity.fromJson);
      final birthdays =
          entity?.birthdays ?? mapList(rawItems, BirthdaysEntity.fromJson);

      emit(
        state.copyWith(
          birthdayStatus: LoadStatus.SUCCESS,
          birthdays: birthdays,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.d(s);
      emit(
        state.copyWith(
          birthdayStatus: LoadStatus.FAILURE,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getWorkQualityDetail(String month) async {
    try {
      emit(state.copyWith(workQualityStatus: LoadStatus.LOADING));

      final entity = await _repository.getWorkQualityDetail(month);

      emit(
        state.copyWith(
          workQualityStatus: LoadStatus.SUCCESS,
          worQualityDetail: entity,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.d(s);
      emit(
        state.copyWith(
          workQualityStatus: LoadStatus.FAILURE,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> submitImprovemnt(SendSuggestionParam body) async {
    try {
      emit(state.copyWith(suggestionStatus: LoadStatus.LOADING));

      await _repository.submitImprovemnt(body);
      emit(state.copyWith(suggestionStatus: LoadStatus.SUCCESS));
    } catch (e, s) {
      logger.e(e);
      logger.d(s);
      emit(
        state.copyWith(
          suggestionStatus: LoadStatus.FAILURE,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void resetSuggestionStatus() {
    emit(state.copyWith(suggestionStatus: LoadStatus.INITIAL));
  }
}
