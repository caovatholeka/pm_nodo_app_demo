import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/task_data_entity.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/entities/task_stage_entity.dart';
import 'package:pm_app/app/data/models/entities/user_entity.dart';
import 'package:pm_app/app/data/models/param/create_task_param.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';

import '../../../../config/app_config.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/enums/load_status.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;

  TaskCubit({required this.repository}) : super(const TaskState());

  resetStatus(){
    emit(state.copyWith(
      loadStatus: LoadStatus.INITIAL,
      updateStageStatus: LoadStatus.INITIAL,
      createStatus: LoadStatus.INITIAL,
      loadDetailStatus: LoadStatus.INITIAL,
      deleteStatus: LoadStatus.INITIAL,
      updateStatus: LoadStatus.INITIAL,
      currentUsers: [],
      resetDateTime: true,
      taskPriority: false
    ));
  }

  resetData(){
    emit(state.copyWith(
        listUsers:[],
        strUsers: "",
      currentUsers: [],
      deadlineTime: "",
      resetDateTime: true,
      taskPriority: false
    ));
  }

  initUpdateState(TaskEntity task){
    emit(state.copyWith(
      taskName: task.name,
      deadlineDateTime:  AppDateUtils.convertStringDateToDateTime(task.deadline ?? ""),
      deadlineTime: AppDateUtils.changeIso8601StringToDateTimeString(task.deadline ?? ""),
      description: task.description,
      taskPriority: task.priority.toString() == "1" ? true : false,
      strUsers: task.userIds?.map((user) => user.name).toList().join(","),
      currentUsers: task.userIds,
    ));
  }

  getListTasks() async {
    int page = 1;
    int limit = 100;
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try {
      final res = await repository.getListTask(state.query,state.currentTabItem?.id,page,limit);
      final items = TaskDataEntity.itemsFrom(res.data);
      emit(state.copyWith(loadStatus: LoadStatus.SUCCESS,listTasks: items));
    }catch(e,s){
      logger.d(e);
      logger.d(s);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE,listTasks: []));
    }
  }

  void updateTaskStage(String taskId, int stageId) async{
    if (state.updateStageStatus == LoadStatus.LOADING) return;
    emit(state.copyWith(updateStageStatus: LoadStatus.LOADING));
    try{
      final param = {
        "task_id": taskId,
        "stage_id": stageId
      };

      await repository.updateTaskStage(param);
      getListTasks();
      emit(state.copyWith(updateStageStatus: LoadStatus.SUCCESS));
    }catch(e){
      logger.d(e);
      emit(state.copyWith(updateStageStatus: LoadStatus.FAILURE));
    }
  }

  void onChangeTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void onChangeCurrentTabItem(TaskStageEntity item){
    emit(state.copyWith(currentTabItem: item));
  }

  void onChangeQuery(String query){
    emit(state.copyWith(query: query));
  }


  // Create task
  void getListUsers() async{
    try {
      final List<UserEntity>? list;
      final res = await repository.getListUser();
      if(res.data != null){
        list = mapList(res.data, UserEntity.fromJson);
        emit(state.copyWith(listUsers: list));
      }else{
        emit(state.copyWith(listUsers: []));
      }

    }catch(e){
      logger.d(e);
      emit(state.copyWith(listUsers: []));
    }
  }
  void onChangeTaskName(String name) {
    emit(state.copyWith(taskName: name));
  }

  void onChangeTakPriority() {
    bool pri = state.taskPriority;
    emit(state.copyWith(taskPriority: !pri));
  }

  onChangeUser(String user){
    emit(state.copyWith(strUsers: user));
  }

  onChangeCurrentUsers(List<UserEntity> users){
    emit(state.copyWith(currentUsers: users));
  }

  void setDeadlineDate(DateTime dateTime) {
    String formattedDate = DateFormat(AppConfig.birthdayReservedFormat).format(dateTime);
    emit(state.copyWith(deadlineTime: AppDateUtils.changeIso8601StringToDateTimeString(formattedDate), deadlineDateTime: dateTime));
  }

  void onChangeDeadlineTime(String time){
    emit(state.copyWith(deadlineTime: time));
  }

  void onChangeDescription(String desc){
    emit(state.copyWith(description: desc));
  }

  createNewTask() async {
    if (state.createStatus == LoadStatus.LOADING) return;
    emit(state.copyWith(createStatus: LoadStatus.LOADING));
    try{
      List<int> userIds = [];
      for(UserEntity user in (state.currentUsers ?? [])){
        userIds.add(user.id ?? 0);
      }
      CreateTaskParam createParam = CreateTaskParam(
        name: state.taskName,
        deadLine: AppDateUtils.parseDateToYMD(state.deadlineTime), // state.deadlineTime,
        desc: state.description,
        userIds: userIds,
        priority: state.taskPriority ? "1" : null
      );

      final res =  await repository.createTask(createParam);
      if(res.data != null){
        emit(state.copyWith(createStatus: LoadStatus.SUCCESS));
      }else{
        emit(state.copyWith(createStatus: LoadStatus.FAILURE));
      }

    }catch(e){
      logger.d(e);
      emit(state.copyWith(createStatus: LoadStatus.FAILURE));
    }
  }

  getDetailTask(int taskId) async {
    emit(state.copyWith(loadDetailStatus: LoadStatus.LOADING));
    try{
      TaskEntity? task;
      final res = await repository.getDetailTask(taskId);

      if(res.data != null){
        task = mapObject(res.data, TaskEntity.fromJson);
        emit(state.copyWith(loadDetailStatus: LoadStatus.SUCCESS,
          detailTask: task));
      }else{
        emit(state.copyWith(loadDetailStatus: LoadStatus.SUCCESS,
            detailTask: TaskEntity()));
      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(loadDetailStatus: LoadStatus.FAILURE));
    }
  }

  deleteTask(int taskId) async {
    if (state.deleteStatus == LoadStatus.LOADING) return;
    emit(state.copyWith(deleteStatus: LoadStatus.LOADING));
    try{
      final body = {
        "task_id": taskId
      };
      await repository.deleteTask(body);
      emit(state.copyWith(deleteStatus: LoadStatus.SUCCESS));
    }catch(e){
      logger.d(e);
      emit(state.copyWith(deleteStatus: LoadStatus.FAILURE));
    }
  }

  updateTask(String taskId) async{
    if (state.updateStatus == LoadStatus.LOADING) return;
    emit(state.copyWith(updateStatus: LoadStatus.LOADING));
    List<int> userIds = [];
    for(UserEntity user in (state.currentUsers ?? [])){
      userIds.add(user.id ?? 0);
    }

    final CreateTaskParam param = CreateTaskParam(
      taskId: taskId,
        name: state.taskName,
        deadLine: AppDateUtils.parseDateToYMD(state.deadlineTime),
        desc: state.description,
        userIds: userIds,
        priority: state.taskPriority ? "1" : null
    );
    try{
      final res = await repository.updateTask(param);
      if(res.data != null){
        emit(state.copyWith(updateStatus: LoadStatus.SUCCESS));
      }else{
        emit(state.copyWith(updateStatus: LoadStatus.FAILURE));
      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(updateStatus: LoadStatus.FAILURE));
    }
  }

  getListStages() async {
    emit(state.copyWith(getStageStatus: LoadStatus.LOADING));
    try{  
      final res = await repository.getTaskStages();
      List<TaskStageEntity>? list;
      if(res.data != null){
        list = mapList(res.data, TaskStageEntity.fromJson);
        if(list.isNotEmpty){
          emit(state.copyWith(getStageStatus: LoadStatus.SUCCESS,listTaskStages: list));
          onChangeCurrentTabItem(list.first);
          getListTasks();
        }else{
          emit(state.copyWith(getStageStatus: LoadStatus.FAILURE, listTaskStages: []));
        }

      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(getStageStatus: LoadStatus.FAILURE, listTaskStages: []));
    }
  }

}