import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/jutification_repository.dart';

part 'justification_detail_state.dart';

class JustificationDetailCubit extends Cubit<JustificationDetailState> {
  final JutificationRepository _repo = GetIt.I<JutificationRepository>();

  JustificationDetailCubit() : super(const JustificationDetailState());

  Future<void> getDetail(int id) async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try {
      final detail = await _repo.getDetailAttendance(id);

      emit(state.copyWith(loadStatus: LoadStatus.SUCCESS, detail: detail));
    } catch (e, s) {
      logger.e("JustificationDetailCubit error: ${e}, Where: ${s}");

      emit(state.copyWith(loadStatus: LoadStatus.FAILURE, error: e.toString()));
    }
  }

  Future<void> submitApproval() async {
    final id = state.detail?.id;
    if (id == null || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, submitSuccess: false, error: null));

    try {
      await _repo.submitJustification(id);

      emit(state.copyWith(isSubmitting: false, submitSuccess: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  void resetSubmitState() {
    emit(state.copyWith(submitSuccess: false, error: null));
  }

  Future<void> deleteJustification(int id) async {
  if (state.isSubmitting) return;

  emit(state.copyWith(isSubmitting: true, error: null));

  try {
    await _repo.deleteJustification(id);

    emit(state.copyWith(
      isSubmitting: false,
      submitSuccess: true,
    ));
  } catch (e, s) {
    logger.e("DeleteJustification error: $e, Where: $s");

    emit(state.copyWith(
      isSubmitting: false,
      error: e.toString(),
    ));
  }
}

}
