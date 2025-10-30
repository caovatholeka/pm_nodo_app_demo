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

      emit(state.copyWith(
        loadStatus: LoadStatus.SUCCESS,
        allEmployees: listEmployees,
        listEmployees: listEmployees?? []));

    }catch(e,s){
      logger.d(e);
      logger.d(s);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE,listEmployees: []));
    }
  }

  void searchEmployees(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(listEmployees: state.allEmployees));
    } else {
      final filtered = (state.allEmployees??[]).where((emp) {
        final name = emp.name?.toLowerCase() ?? '';
        final code = emp.code?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) || code.contains(query.toLowerCase());
      }).toList();

      emit(state.copyWith(listEmployees: filtered));
    }
  }

  void filterEmployees({
  String? name,
  String? code,
  String? department,
  String? jobTitle,
  String? email,
  String? status,
}) {
  final all = state.listEmployees ?? [];
  final filtered = all.where((e) {
    final matchesName = name == null || name.isEmpty || e.name?.toLowerCase().contains(name.toLowerCase()) == true;
    final matchesCode = code == null || code.isEmpty || e.code?.toLowerCase().contains(code.toLowerCase()) == true;
    final matchesDept = department == null || department.isEmpty || e.department == department;
    final matchesJob = jobTitle == null || jobTitle.isEmpty || e.jobTitle == jobTitle;
    final matchesEmail = email == null || email.isEmpty || e.workEmail?.toLowerCase().contains(email.toLowerCase()) == true;
    return matchesName && matchesCode && matchesDept && matchesJob && matchesEmail;
  }).toList();

  emit(state.copyWith(listEmployees: filtered));
}

}