import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/justification_approve_param.dart';
import 'package:pm_app/app/data/repositories/jutification_repository.dart';

part 'justification_state.dart';

class JustificationCubit extends Cubit<JustificationState> {
  final JutificationRepository _repo = GetIt.I<JutificationRepository>();

  JustificationCubit() : super(const JustificationState());

  Future<void> loadList({String? startDate, String? endDate}) async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try {
      final params = <String, dynamic>{};

      if (startDate != null) params['start_date'] = startDate;
      if (endDate != null) params['end_date'] = endDate;

      final res = await _repo.getAttendanceList(params: params);

      List listJson = [];
      if (res.data is Map && res.data.containsKey('data')) {
        listJson = res.data['data'];
      } else if (res.data is List) {
        listJson = res.data;
      }

      final list =
          listJson.map((e) => JustificationEntity.fromJson(e)).toList();

      emit(state.copyWith(loadStatus: LoadStatus.SUCCESS, list: list));
    } catch (e, s) {
      logger.e("Mapping Error: $e");
      logger.d("Where: $s");

      emit(state.copyWith(loadStatus: LoadStatus.FAILURE, error: e.toString()));
    }
  }

  Future<void> approveByIds(List<int> ids) async {
    if (ids.isEmpty) return;

    emit(state.copyWith(approveStatus: LoadStatus.LOADING, error: null));

    try {
      final param = JustificationApproveParam(exceptionIds: ids);

      await _repo.approveJustification(param);

      emit(state.copyWith(approveStatus: LoadStatus.SUCCESS));

      await loadList();
    } catch (e, s) {
      logger.e("Approve justification error: $e");
      logger.d("Where: $s");

      emit(
        state.copyWith(approveStatus: LoadStatus.FAILURE, error: e.toString()),
      );
    }
  }

  void resetApproveStatus() {
    emit(state.copyWith(approveStatus: LoadStatus.INITIAL));
  }
}
