import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';

import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/on_leave_repository.dart';

part 'detail_on_leave_state.dart';

class DetailOnLeaveCubit extends Cubit<DetailOnLeaveState> {
  OnLeaveRepository repository;

  DetailOnLeaveCubit({required this.repository}) : super(DetailOnLeaveState());


  getDetailOnLeave(int id) async{
    if(id == 0){
      return;
    }

    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try{
      OnLeaveEntity? entity = await repository.getDetailOnLeave(id);
      emit(state.copyWith(loadStatus: LoadStatus.SUCCESS,detailEntity: entity));
    }catch(e){
      logger.d(e);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE,detailEntity: null));
    }
  }

  void deleteOnLeave(int id) async{
    emit(state.copyWith(deleteStatus: LoadStatus.LOADING));
    try {
      await repository.deleteDetailOnLeave(id);
      emit(state.copyWith(deleteStatus: LoadStatus.SUCCESS));
    }on DioException catch(e){
      logger.d(e);
      // final res = e.response as Map<String, dynamic>;
      // logger.d("resss :: $res");
      emit(state.copyWith(deleteStatus: LoadStatus.FAILURE));
    }
  }

}