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

  StaffCubit({required this.repository}) : super(const StaffState());

  static const int offset = 0;
  static const int limit = 10;
  Future<void> getListEmployees() async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try {
      final results = await repository.getListEmployees(
        limit: limit,
        offset: 0,
      );

      List<EmployeeEntity> employees = [];
      if (results.data != null) {
        employees = mapList<EmployeeEntity>(results.data, EmployeeEntity.fromJson);
      }

      emit(state.copyWith(
        listEmployees: employees,
        loadStatus: LoadStatus.SUCCESS,
      ));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> searchEmployees(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      await getListEmployees();
      return;
    }

    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try {
      String? nameParam;
      String? codeParam;

      final isCode = RegExp(r'^[0-9]+$').hasMatch(q) || q.toUpperCase().startsWith('NV');
      if (isCode) {
        codeParam = q;
      } else {
        nameParam = q;
      }

      final results = await repository.getListEmployees(
        limit: limit,
        offset: 0,
        name: nameParam,
        code: codeParam,
      );

      List<EmployeeEntity> employees = [];
      if (results.data != null) {
        employees = mapList<EmployeeEntity>(results.data, EmployeeEntity.fromJson);
      }

      emit(state.copyWith(
        listEmployees: employees,
        loadStatus: LoadStatus.SUCCESS,
      ));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  void onLoadMore() async {
    final currentPage = state.page;
    final totalPages = state.totalPages;

    if (totalPages > 0 && currentPage >= (totalPages - 1)) {
      emit(state.copyWith(loadEventStatus: LoadStatus.SUCCESS));
      return;
    }

    if (state.loadStatus != LoadStatus.SUCCESS ||
        state.loadEventStatus == LoadStatus.LOADING_MORE) {
      return;
    }

    emit(state.copyWith(loadEventStatus: LoadStatus.LOADING_MORE));
    try {
      final nextOffset = currentPage + 1;
      final results = await repository.getListEmployees(limit: limit, offset: nextOffset);

      List<EmployeeEntity> newPage = [];
      if (results.data != null) {
        newPage = mapList<EmployeeEntity>(results.data, EmployeeEntity.fromJson);
      }

      final existing = List<EmployeeEntity>.from(state.listEmployees ?? const []);
      final merged = [...existing, ...newPage];

      emit(state.copyWith(
        loadStatus: LoadStatus.SUCCESS,
        loadEventStatus: LoadStatus.SUCCESS,
        listEmployees: merged,
        page: results.offset,
        totalPages: results.total,
      ));
    } catch (e) {
      logger.d(e);
      emit(state.copyWith(
        loadStatus: LoadStatus.FAILURE,
        loadEventStatus: LoadStatus.FAILURE,
      ));
    }
  }

Future<void> filterEmployees(EmployeeFilterParam param) async {
  final hasNoFilter = (param.name == null || param.name!.isEmpty) &&
      (param.code == null || param.code!.isEmpty) &&
      (param.email == null || param.email!.isEmpty) &&
      param.departmentId == null &&
      (param.jobTitle == null || param.jobTitle!.isEmpty) &&
      param.active == null;

  if (hasNoFilter) {
    return;
  }

  emit(state.copyWith(loadStatus: LoadStatus.LOADING));

  try {
    final results = await repository.getListEmployees(
      limit: limit,
      offset: 0,
      name: param.name,
      code: param.code,
      email: param.email,
      departmentId: param.departmentId,
      jobTitle: param.jobTitle,
      active: param.active,
    );

    List<EmployeeEntity> employees = [];
    if (results.data != null) {
      employees = mapList<EmployeeEntity>(results.data, EmployeeEntity.fromJson);
    }

    emit(state.copyWith(
      listEmployees: employees,
      loadStatus: LoadStatus.SUCCESS,
      filterParam: param,
    ));
  } catch (e) {
    emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
  }
}

Future<void> clearFilter() async {
  emit(const StaffState(
    loadStatus: LoadStatus.LOADING,
    loadEventStatus: LoadStatus.INITIAL,
    listEmployees: [],
    page: 0,
    totalPages: 0,
  ));

  try {
    await getListEmployees();
  } catch (e) {
    emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
  }
}

}
