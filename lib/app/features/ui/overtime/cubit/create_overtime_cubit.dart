import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/overtime_line_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/create_overtime_param.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';

part 'create_overtime_state.dart';

class CreateOvertimeCubit extends Cubit<CreateOvertimeState> {
  final OvertimeRepository _repo = GetIt.I<OvertimeRepository>();

  CreateOvertimeCubit() : super(const CreateOvertimeState());

  void setFromDate(String value) {
    emit(state.copyWith(fromDate: value));
  }

  void setToDate(String value) {
    emit(state.copyWith(toDate: value));
  }

  void setNote(String? value) {
    emit(state.copyWith(note: value));
  }

  void initOvertimeLines(List<DateTime> days) {
    final lines = days
        .map(
          (d) => OvertimeLineEntity(
            date: DateFormat('yyyy-MM-dd').format(d),
            overtime: null,
            formType: null,
          ),
        )
        .toList();

    emit(state.copyWith(overtimeLines: lines));
  }

  void updateOvertimeLine(int index, OvertimeLineEntity line) {
    final updated = List<OvertimeLineEntity>.from(state.overtimeLines);
    if (index < 0 || index >= updated.length) return;
    updated[index] = line;
    emit(state.copyWith(overtimeLines: updated));
  }

  Future<void> submit() async {
    if (state.fromDate.isEmpty ||
        state.toDate.isEmpty ||
        state.overtimeLines.isEmpty) {
      emit(state.copyWith(error: 'Vui lòng nhập đầy đủ thông tin'));
      return;
    }

    emit(state.copyWith(
      loadStatus: LoadStatus.LOADING,
      error: null,
      submitSuccess: false,
    ));

    try {
      final param = CreateOvertimeParam(
        fromDate: state.fromDate,
        toDate: state.toDate,
        note: state.note,
        overtimeLines: state.overtimeLines,
      );

      await _repo.createOTRequest(param);

      emit(state.copyWith(
        loadStatus: LoadStatus.SUCCESS,
        submitSuccess: true,
      ));
    } catch (e, s) {
      logger.e('CreateOvertime error: $e, where: $s');
      emit(state.copyWith(
        loadStatus: LoadStatus.FAILURE,
        error: e.toString(),
      ));
    }
  }

  void resetSubmitState() {
    emit(state.copyWith(submitSuccess: false, error: null));
  }

  Future<void> update(int id) async {
  if (state.overtimeLines.any(
    (e) => e.overtime == null || e.formType == null,
  )) {
    emit(state.copyWith(error: 'Vui lòng nhập đủ số giờ và hình thức'));
    return;
  }

  emit(state.copyWith(loadStatus: LoadStatus.LOADING, error: null));

  try {
    await _repo.updateOTRequest(
      id,
      CreateOvertimeParam(
        fromDate: state.fromDate,
        toDate: state.toDate,
        note: state.note,
        overtimeLines: state.overtimeLines,
      ).toJson(),
    );

    emit(state.copyWith(loadStatus: LoadStatus.SUCCESS, submitSuccess: true));
  } catch (e) {
    emit(state.copyWith(loadStatus: LoadStatus.FAILURE, error: e.toString()));
  }
}

}
