import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/utils/error_utils.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/cancel_ot_param.dart';
import 'package:pm_app/app/data/models/param/ot_approve_param.dart';
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
    if (id == null || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, error: null, submitSuccess: false));

    try {
      await _repo.submitOTP(id);

      // Tải lại chi tiết ngay trong lượt gửi rồi emit 1 lần. Trước đây emit "thành công"
      // rồi mới gọi getDetailOT → bật loading lần 2 ngay sau thông báo thành công, hộp
      // loading đó không tắt được (phải bấm quay lại).
      OvertimeEntity? detail;
      try {
        detail = await _repo.getOTDetail(id);
      } catch (e, s) {
        logger.e("Reload OT detail after submit error: $e, where: $s");
      }
      emit(state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
        detail: detail,
      ));
    } catch (e, s) {
      logger.e('Submit OT error: $e, where: $s');
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  Future<void> approveOT() async {
    final id = state.detail?.id;
    if (id == null || state.approveStatus == LoadStatus.LOADING) return;

    emit(state.copyWith(approveStatus: LoadStatus.LOADING));

    try {
      final param = OtApproveParam(overtimeIds: [id]);
      await _repo.approveOT(param);

      final updatedDetail = await _repo.getOTDetail(id);

      emit(
        state.copyWith(
          approveStatus: LoadStatus.SUCCESS,
          detail: updatedDetail,
        ),
      );
    } catch (e, s) {
      logger.e("Approve OT error: $e, where: $s");
      emit(state.copyWith(approveStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> cancelOT(int id, String note) async {
    if (state.cancelStatus == LoadStatus.LOADING) return;
    emit(state.copyWith(cancelStatus: LoadStatus.LOADING));
    try {
      final param = CancelOtParam(note: note);
      await _repo.cancelOT(id, param);
      emit(state.copyWith(cancelStatus: LoadStatus.SUCCESS));
      logger.i("Success calling api blyat");
    } catch (e, s) {
      logger.e("ERR: $e, $s");
      emit(state.copyWith(cancelStatus: LoadStatus.FAILURE));
    }
  }

  /// Xóa đơn (chỉ đơn Nháp — server kiểm tra lại). Bỏ qua nếu đang xóa (chống bấm 2 lần).
  Future<void> deleteOT() async {
    final id = state.detail?.id;
    if (id == null || state.deleteStatus == LoadStatus.LOADING) return;

    emit(state.copyWith(deleteStatus: LoadStatus.LOADING));
    try {
      await _repo.deleteOTRequest(id);
      emit(state.copyWith(deleteStatus: LoadStatus.SUCCESS));
    } catch (e, s) {
      logger.e("Delete OT error: $e, where: $s");
      emit(state.copyWith(
        deleteStatus: LoadStatus.FAILURE,
        deleteError: ErrorUtils.serverMessage(e),
      ));
    }
  }

  void resetDeleteStatus() {
    emit(state.copyWith(deleteStatus: LoadStatus.INITIAL));
  }

  void resetApproveStatus() {
    emit(state.copyWith(approveStatus: LoadStatus.INITIAL));
  }

  void resetCancelStatus() {
    emit(state.copyWith(cancelStatus: LoadStatus.INITIAL));
  }
}
