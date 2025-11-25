import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';

import '../../../core/helper/response_mapper.dart';
import '../../../core/logger/logger.dart';
import '../../../data/models/entities/explanation_entity.dart';
import '../../../data/models/entities/task_data_entity.dart';
import '../../../data/repositories/user_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  UserRepository userRepository;
  TaskRepository taskRepository;

  HomeCubit({
    required this.userRepository,
    required this.taskRepository
  }) : super(HomeState());

  // lấy lịch sử chấm công ngày hôm nay
  getListAttendanceToday() async {
    final year = DateTime.now().year;
    final month = DateTime.now().month;
    final day = DateTime.now().day;
    final dateFrom = "$year-$month-$day";
    try{
      final res = await userRepository.getListAttendanceToday(dateFrom,dateFrom);
      List<ExplanationEntity>? list;
      if(res.data != null){
        list =  mapList(res.data, ExplanationEntity.fromJson);
      }

      if((list ?? []).isNotEmpty){
        emit(state.copyWith(listAttendanceToday: list));
      }else{
        emit(state.copyWith(listAttendanceToday: []));
      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(listAttendanceToday: []));
    }
  }

  // lấy danh sách việc cần làm
  getListNewTasks() async {
    emit(state.copyWith(loadDataStatus: LoadStatus.LOADING));
    String? name;
    int stagId = 1;
    int page = 1;
    int limit = 5;
    try {
      final res = await taskRepository.getListTask(name,stagId,page,limit);
      TaskDataEntity? taskData;
      if(res.data != null){
        taskData = mapObject(res.data, TaskDataEntity.fromJson);
      }

      if((taskData?.items ?? []).isNotEmpty){
        emit(state.copyWith(loadDataStatus: LoadStatus.SUCCESS,listNewTasks: taskData?.items ?? []));
      }else{
        emit(state.copyWith(loadDataStatus: LoadStatus.SUCCESS,listNewTasks: []));
      }
    }catch(e,s){
      logger.d(e);
      logger.d(s);
      emit(state.copyWith(loadDataStatus: LoadStatus.FAILURE,listNewTasks: []));
    }
  }

}