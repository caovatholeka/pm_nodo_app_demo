import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/employee_repository.dart';

part 'employee_detail_state.dart';

class EmployeeDetailCubit extends Cubit<EmployeeDetailState> {
  final EmployeeRepository repository;

  EmployeeDetailCubit({required this.repository})
      : super(EmployeeDetailState.initial());

  Future<void> getDetailEmployee(int id) async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try {
      final employee = await repository.getDetailEmployee(id);

      emit(state.copyWith(
        employee: employee,
        loadStatus: LoadStatus.SUCCESS,
      ));
    } catch (e, s) {
      logger.e('getDetailEmployee error: $e');
      logger.e('Stack: $s');
      emit(state.copyWith(
        loadStatus: LoadStatus.FAILURE,
      ));
    }
  }
}
