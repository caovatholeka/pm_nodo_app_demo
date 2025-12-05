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

  static const int page = 1;
  static const int limit = 10; //10;

  Future<void> getListEmployees({
    String? query,
    EmployeeFilterParam? filter,
  }) async {
    final trimmedQuery = query?.trim();
    final bool isSearching = trimmedQuery != null && trimmedQuery.isNotEmpty;

    final EmployeeFilterParam? effectiveFilter = isSearching ? null : filter;

    emit(
      state.copyWith(
        loadStatus: LoadStatus.LOADING,
        page: 1,
        listEmployees: [],
        totalPages: 1,
        filterParam: effectiveFilter,
      ),
    );

    String? nameParam;
    String? codeParam;
    String? emailParam;
    int? departmentId;
    int? jobTitleId;
    String? active;

    if (isSearching) {
      final q = trimmedQuery;
      if (RegExp(r'^[0-9]+$').hasMatch(q)) {
        codeParam = q;
      } else {
        nameParam = q;
      }
    } else if (effectiveFilter != null) {
      nameParam = effectiveFilter.name;
      codeParam = effectiveFilter.code;
      emailParam = effectiveFilter.email;
      departmentId = effectiveFilter.departmentId;
      jobTitleId = effectiveFilter.jobTitleId;
      active = effectiveFilter.active;
    }

    try {
      final results = await repository.getListEmployees(
        limit: (isSearching || effectiveFilter != null) ? 100 : limit,
        page: 1,
        name: nameParam,
        code: codeParam,
        email: emailParam,
        departmentId: departmentId,
        jobTitleId: jobTitleId,
        active: active,
      );

      List<EmployeeEntity> employees = [];
      if (results.data != null) {
        employees = mapList<EmployeeEntity>(
          results.data,
          EmployeeEntity.fromJson,
        );
      }

      emit(
        state.copyWith(
          listEmployees: employees,
          loadStatus: LoadStatus.SUCCESS,
          page: 1,
          totalPages:
              (isSearching || effectiveFilter != null)
                  ? 1
                  : results.total_pages,
          filterParam: effectiveFilter,
        ),
      );
    } catch (e) {
      logger.d(e);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  void clearFilter() {
    emit(
      state.copyWith(
        filterParam: null,
        page: 1,
        totalPages: 1,
        listEmployees: [],
      ),
    );

    getListEmployees();
  }

  void onLoadMore() async {
    if (state.filterParam != null) return;

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
      final results = await repository.getListEmployees(
        limit: limit,
        page: nextOffset,
      );

      List<EmployeeEntity> newPage = [];
      if (results.data != null) {
        newPage = mapList<EmployeeEntity>(
          results.data,
          EmployeeEntity.fromJson,
        );
      }

      final existing = List<EmployeeEntity>.from(
        state.listEmployees ?? const [],
      );
      final merged = [...existing, ...newPage];

      emit(
        state.copyWith(
          loadStatus: LoadStatus.SUCCESS,
          loadEventStatus: LoadStatus.SUCCESS,
          listEmployees: merged,
          page: results.page,
          totalPages: results.total_pages,
        ),
      );
    } catch (e) {
      logger.d(e);
      emit(
        state.copyWith(
          loadStatus: LoadStatus.FAILURE,
          loadEventStatus: LoadStatus.FAILURE,
        ),
      );
    }
  }
}
