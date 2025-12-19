import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';

part 'overtime_detail_state.dart';

class OvertimeDetailCubit extends Cubit<OvertimeDetailState> {
  final OvertimeRepository _repo = GetIt.I<OvertimeRepository>();

  OvertimeDetailCubit() : super(const OvertimeDetailState());

  Future<void> getDetailOT(int id) async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try {
      final detail = await _repo.getOTDetail(id);
      emit(state.copyWith(loadStatus: LoadStatus.SUCCESS, detail: detail));
    } catch (e, s) {
      logger.e("err:$e, where: $s");
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE, error: e.toString()));
    }
  }

  void resetSubmitState() {
    emit(state.copyWith(submitSuccess: false, error: null));
  }

  Future<void> submitApproval() async {
    final id = state.detail?.id;
    if (id == null) return;

    emit(state.copyWith(isSubmitting: true, error: null, submitSuccess: false));

    try {
      final updatedDetail = await _repo.submitOTP(id);

      emit(
        state.copyWith(
          isSubmitting: false,
          submitSuccess: true,
          detail: updatedDetail, 
        ),
      );
    } catch (e, s) {
      logger.e('Submit OT error: $e, where: $s');
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }


}
