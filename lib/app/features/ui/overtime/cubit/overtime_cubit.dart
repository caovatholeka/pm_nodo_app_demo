import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/ot_approve_param.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';
import 'package:rename/platform_file_editors/abs_platform_file_editor.dart';

part 'overtime_state.dart';

class OvertimeCubit extends Cubit<OvertimeState> {
  final OvertimeRepository _repo = GetIt.I<OvertimeRepository>();

  OvertimeCubit() : super(const OvertimeState());

  Future<void> loadOTList({String? startDate, String? endDate}) async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try {
      final params = <String, dynamic>{};

      if (startDate != null) params['start_date'] = startDate;
      if (endDate != null) params['end_date'] = endDate;

      final res = await _repo.getListOT(params: params);

      List listJson = [];
      if (res.data is Map && res.data.containsKey('data')) {
        listJson = res.data['data'];
      } else if (res.data is List) {
        listJson = res.data;
      }

      final list = listJson.map((e) => OvertimeEntity.fromJson(e)).toList();

      emit(state.copyWith(loadStatus: LoadStatus.SUCCESS, list: list));
    } catch (e, s) {
      logger.e("err: $e");
      logger.d("where: $s");

      emit(state.copyWith(loadStatus: LoadStatus.FAILURE, error: e.toString()));
    }
  }

  void approveBulkOvertimes(List<int> overtimeIds) async {
    if (overtimeIds.isEmpty) return;

    emit(state.copyWith(approveStatus: LoadStatus.LOADING));

    try {
      final res = await _repo.approveOT(
        OtApproveParam(overtimeIds: overtimeIds),
      );

      emit(state.copyWith(approveStatus: LoadStatus.SUCCESS));
    } catch (e, s) {
      logger.e("err: $e");
      logger.d("where: $s");

      emit(
        state.copyWith(approveStatus: LoadStatus.FAILURE, error: e.toString()),
      );
    }
  }

  void resetApproveStatus() {
    emit(state.copyWith(approveStatus: LoadStatus.INITIAL));
  }

  Future<void> submitApproval(int id) async {
    emit(state.copyWith(submitStatus: LoadStatus.LOADING));

    try {
      await _repo.submitOTP(id);

      emit(state.copyWith(submitStatus: LoadStatus.SUCCESS));

      await loadOTList();
    } catch (e, s) {
      logger.e("Submit OT error: $e");
      logger.d("Where: $s");

      emit(
        state.copyWith(submitStatus: LoadStatus.FAILURE, error: e.toString()),
      );
    }
  }
}
