import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/utils/error_utils.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/justification_approve_param.dart';
import 'package:pm_app/app/data/models/param/justification_cancel_param.dart';
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
      logger.e("JustificationDetailCubit error: $e, Where: $s");

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

  /// Xóa đơn (chỉ đơn Nháp — server kiểm tra lại). Bỏ qua nếu đang xóa (chống bấm 2 lần).
  Future<void> deleteJustification() async {
    final id = state.detail?.id;
    if (id == null || state.deleteStatus == LoadStatus.LOADING) return;

    emit(state.copyWith(deleteStatus: LoadStatus.LOADING));
    try {
      await _repo.deleteJustification(id);
      emit(state.copyWith(deleteStatus: LoadStatus.SUCCESS));
    } catch (e, s) {
      logger.e("DeleteJustification error: $e, Where: $s");
      emit(state.copyWith(
        deleteStatus: LoadStatus.FAILURE,
        deleteError: ErrorUtils.serverMessage(e),
      ));
    }
  }

  void resetDeleteStatus() {
    emit(state.copyWith(deleteStatus: LoadStatus.INITIAL));
  }

Future<void> approveJustification(JustificationApproveParam body) async {
    if (state.approveStatus == LoadStatus.LOADING) return;
    emit(state.copyWith(approveStatus: LoadStatus.LOADING));

    try {
      await _repo.approveJustification(body);
      emit(state.copyWith(approveStatus: LoadStatus.SUCCESS));
    } catch (e, s) {
      logger.e("ApproveJustification error: $e, Where: $s");
      emit(state.copyWith(approveStatus: LoadStatus.FAILURE, error: e.toString()));
    }
  }

Future<void> cancelJustification(int id, JustificationCancelParam body) async {
    if (state.cancelStatus == LoadStatus.LOADING) return;
    emit(state.copyWith(cancelStatus: LoadStatus.LOADING));

    try {
      await _repo.cancelJustification(id, body);
      emit(state.copyWith(cancelStatus: LoadStatus.SUCCESS));
    } catch (e, s) {
      logger.e("CancelJustification error: $e, Where: $s");
      emit(state.copyWith(cancelStatus: LoadStatus.FAILURE, error: e.toString()));
    }
  }

void resetApproveCancelStatus() {
    emit(state.copyWith(
      approveStatus: LoadStatus.INITIAL,
      cancelStatus: LoadStatus.INITIAL,
      error: null,
    ));
  }
}
