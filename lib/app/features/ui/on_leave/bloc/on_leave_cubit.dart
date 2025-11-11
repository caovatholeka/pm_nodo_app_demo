import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/response_mapper.dart';
import '../../../../core/logger/logger.dart';
import '../../../../data/models/entities/on_leave_entity.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/on_leave_repository.dart';

part 'on_leave_state.dart';

class OnLeaveCubit extends Cubit<OnLeaveState> {
  OnLeaveRepository repository;

  OnLeaveCubit({required this.repository}) : super(OnLeaveState());


  void getListOnLeaveTimes() async{
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try{

      int limit = 10;
      int offset  = 0;
      String? startDate;
      String? endDate;
      final results = await repository.getListTimeOnLeaves(limit,
          offset,state.startDateFilter,
          state.endDateFilter);
      List<OnLeaveEntity>? listLeaves;
      if(results.data != null){
        listLeaves =  mapList<OnLeaveEntity>(results.data, OnLeaveEntity.fromJson);
      }

      emit(state.copyWith(loadStatus: LoadStatus.SUCCESS,listLeaveEntities: listLeaves?? []));

    }catch(e,s){
      logger.d(e);
      logger.d(s);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE,listLeaveEntities: []));
    }
  }

  onChangeDateFilter(String start, String end){
    emit(state.copyWith(startDateFilter: start,endDateFilter: end));
  }

}