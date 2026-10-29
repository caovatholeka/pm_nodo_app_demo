import 'package:equatable/equatable.dart';
import 'package:pm_app/app/core/utils/validators.dart';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/data/models/entities/overtime_line_entity.dart';
import 'package:pm_app/app/data/models/param/create_overtime_param.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';
import 'package:pm_app/generated/l10n.dart';

part 'create_overtime_state.dart';

class CreateOvertimeCubit extends Cubit<CreateOvertimeState> {
  final OvertimeRepository _repo = GetIt.I<OvertimeRepository>();

  CreateOvertimeCubit() : super(CreateOvertimeState.initial());

  void setFromDate(String value) {
    emit(state.copyWith(fromDate: value));
  }

  void setToDate(String value) {
    emit(state.copyWith(toDate: value));
  }

  void setNote(String? value) {
    emit(state.copyWith(note: value));
  }

  void initFromDetail(int id) {
    emit(state.copyWith(id: id));
  }

  /// [defaultFormType]: hình thức nhận gán sẵn cho mỗi ngày (app v2 ẩn ô chọn, luôn 'pay').
  void initOvertimeLines(List<DateTime> days, {String? defaultFormType}) {
    emit(
      state.copyWith(
        overtimeLines:
            days
                .map(
                  (d) => OvertimeLineEntity(
                    date: DateFormat('yyyy-MM-dd').format(d),
                    overtime: null,
                    formType: defaultFormType,
                  ),
                )
                .toList(),
      ),
    );
  }

  void updateOvertimeLine(int index, OvertimeLineEntity line) {
    final lines = List<OvertimeLineEntity>.from(state.overtimeLines);
    if (index < 0 || index >= lines.length) return;

    lines[index] = line;
    emit(state.copyWith(overtimeLines: lines));
  }

  Future<void> submit() async {
    if (!state.isFormValid || state.isSubmitting) return;

    emit(
      state.copyWith(
        isSubmitting: true,
        errorMessage: null,
        successMessage: null,
        isSuccess: false,
      ),
    );

    try {
      final param = CreateOvertimeParam(
        fromDate: state.fromDate!,
        toDate: state.toDate!,
        note: state.note,
        overtimeLines: state.overtimeLines,
      );

      final res =
          state.isEdit
              ? await _repo.updateOTRequest(state.id!, param.toJson())
              : await _repo.createOTRequest(param);

      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          successMessage:
              res is Map && res['message'] is String
                  ? res['message']
                  : S.current.success,
        ),
      );
    } on DioException catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    } catch (_) {
      emit(state.copyWith(isSubmitting: false, errorMessage: S.current.common_error_occurred));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'];
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final v = errors.values.first;
          if (v is List && v.isNotEmpty) {
            return v.first.toString();
          }
        }
      }
    }

    return S.current.common_invalid_data;
  }
}
