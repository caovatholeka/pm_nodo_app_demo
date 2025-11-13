import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/work_entry_entity.dart';
import 'package:pm_app/app/data/repositories/work_entry_repository.dart';
import 'package:pm_app/app/features/ui/attendance/explanation/explanation_list_state.dart';
import 'package:pm_app/di/di.dart';

class WorkEntryCubit extends Cubit<WorkEntryState> {
  WorkEntryCubit() : super(const WorkEntryState());

  final repo = sl<WorkEntryRepository>();

  Future<void> loadWorkEntries({
    int limit = 20,
    int offset = 0,
    required String dateFrom,
    required String dateTo,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final body = {
        "limit": limit,
        "offset": offset,
        dateFrom: "2025-09-01",
        dateTo: "2025-09-30",
      };

      final response = await repo.getWorkEntries(body);

      if (response.code != 200) {
        emit(state.copyWith(isLoading: false, error: response.message));
        return;
      }
      if (response.data == null) {
        emit(state.copyWith(isLoading: false, list: []));
        return;
      }

      final raw = response.data["data"] as List<dynamic>? ?? [];

      final list = raw
          .map((e) => WorkEntryEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      emit(state.copyWith(isLoading: false, list: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
