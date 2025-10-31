import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/core/param/employee_filter_param.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/repositories/employee_repository.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import '../../../core/logger/logger.dart';

part 'staff_state.dart';

class StaffCubit extends Cubit<StaffState> {
  final EmployeeRepository repository;

  StaffCubit({required this.repository}) : super(StaffState());

  EmployeeFilterParam? _filterParam; 

  void getListEmployees() async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try {
      final results = await repository.getListEmployees();
      List<EmployeeEntity>? listEmployees;
      if (results.data != null) {
        listEmployees = mapList<EmployeeEntity>(results.data, EmployeeEntity.fromJson);
      }

      emit(state.copyWith(
        loadStatus: LoadStatus.SUCCESS,
        listEmployees: listEmployees ?? [],
      ));
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE, listEmployees: []));
    }
  }

  void searchEmployees(String query) {
    final allEmployees = state.listEmployees ?? [];
    if (query.isEmpty) {
      if (_filterParam != null) {
        filterEmployees(_filterParam!);
      } else {
        getListEmployees();
      }
      return;
    }

    final filtered = allEmployees.where((emp) {
      final nameMatch = emp.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final codeMatch = emp.code?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return nameMatch || codeMatch;
    }).toList();

    emit(state.copyWith(listEmployees: filtered, loadStatus: LoadStatus.SUCCESS));
  }


  void filterEmployees(EmployeeFilterParam param) {
  _filterParam = param;
  final employees = state.listEmployees ?? [];

  final filtered = employees.where((emp) {
    final matchesName = param.name == null || param.name!.isEmpty || emp.name?.toLowerCase().contains(param.name!.toLowerCase()) == true;
    final matchesCode = param.code == null || param.code!.isEmpty || emp.code?.toLowerCase().contains(param.code!.toLowerCase()) == true;
    final matchesDept = param.department == null || emp.department == param.department;
    final matchesJob = param.jobTitle == null || emp.jobTitle == param.jobTitle;
    final matchesEmail = param.email == null || param.email!.isEmpty || emp.workEmail?.toLowerCase().contains(param.email!.toLowerCase()) == true;
    final matchesActive = param.active == null ||
        (param.active == true && emp.active == true) ||
        (param.active == false && emp.active == false);

    return matchesName && matchesCode && matchesDept && matchesJob && matchesEmail && matchesActive;
  }).toList();

  emit(state.copyWith(
    listEmployees: filtered,
    loadStatus: LoadStatus.SUCCESS,
    filter: param, 
  ));
}

void clearFilter() {
  _filterParam = null;
  emit(state.copyWith(filter: null));
  getListEmployees();
  }
}