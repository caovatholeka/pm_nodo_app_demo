import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/repositories/employee_repository.dart';

part 'employee_detail_state.dart';

class EmployeeDetailCubit extends Cubit<EmployeeDetailState> {
  final EmployeeRepository repository;

  EmployeeDetailCubit({required this.repository}) : super(EmployeeDetailState.initial());

  Future<void> getDetailEmployee(int id) async {
    try {
      emit(state.copyWith(loadStatus: LoadStatus.LOADING));
      final response = await repository.getDetailEmployee(id);
      final employee = response.data;
      if (employee != null) {
        emit(state.copyWith(employee: employee, loadStatus: LoadStatus.SUCCESS));
      } else {
        emit(state.copyWith(loadStatus: LoadStatus.FAILURE, error: "Không có dữ liệu"));
      }
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE, error: e.toString()));
    }
  }
}
