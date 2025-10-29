import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/repositories/employee_repository.dart';

import '../../../core/logger/logger.dart';
import '../../../data/models/enums/load_status.dart';

part 'staff_state.dart';

class StaffCubit extends Cubit<StaffState> {
  EmployeeRepository repository;

  StaffCubit({required this.repository}) : super(StaffState());


  void getListEmployees() async{
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try{

      int limit = 10;
      int offset  = 0;

      final results = await repository.getListEmployees();
      List<EmployeeEntity>? listEmployees;
      if(results.data != null){
        listEmployees =  mapList<EmployeeEntity>(results.data, EmployeeEntity.fromJson);
      }

      emit(state.copyWith(loadStatus: LoadStatus.SUCCESS,listEmployees: listEmployees?? []));

    }catch(e,s){
      logger.d(e);
      logger.d(s);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE,listEmployees: []));
    }
  }

}