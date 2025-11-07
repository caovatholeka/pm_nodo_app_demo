import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';

part 'employee_detail_state.dart';

class EmployeeDetailCubit extends Cubit<EmployeeDetailState> {
  final ApiClient apiClient;

  EmployeeDetailCubit({required this.apiClient}) : super(EmployeeDetailState.initial());
  Future<void> getDetailEmployee(int id) async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try {
      final employee = await apiClient.getDetailEmployee(id);

      if (employee != null) {
        emit(state.copyWith(
          employee: employee,
          loadStatus: LoadStatus.SUCCESS,
        ));
      } else {
        emit(state.copyWith(
          loadStatus: LoadStatus.FAILURE,         
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        loadStatus: LoadStatus.FAILURE,
      ));
    }
  }
}
