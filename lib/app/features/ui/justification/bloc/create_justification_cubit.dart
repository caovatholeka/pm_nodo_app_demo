import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/repositories/jutification_repository.dart';
import 'package:pm_app/app/data/models/param/create_justification_param.dart';
import 'package:pm_app/app/data/models/param/exception_line_param.dart';

part 'create_justification_state.dart';

class CreateJustificationCubit extends Cubit<CreateJustificationState> {
  final JutificationRepository repository;

  CreateJustificationCubit(this.repository)
      : super(CreateJustificationState.initial());

  void changeDate(String value) {
    emit(state.copyWith(date: value));
  }

  void changeReason(String value) {
    emit(state.copyWith(reasonType: value));
  }

  void changeNote(String value) {
    emit(state.copyWith(note: value));
  }

  void changeFirstFormType(String value) {
    emit(state.copyWith(firstFormType: value));
  }

  void changeFirstHours(String value) {
    emit(state.copyWith(firstHours: double.tryParse(value)));
  }

  void changeSecondFormType(String value) {
    emit(state.copyWith(secondFormType: value));
  }

  void changeSecondHours(String value) {
    emit(state.copyWith(secondHours: double.tryParse(value)));
  }

  Future<void> submit() async {
    if (!state.isFormValid || state.isSubmitting) return;

    emit(
      state.copyWith(
        isSubmitting: true,
        errorMessage: null,
        isSuccess: false,
      ),
    );

    try {
      final param = CreateJustificationParam(
        date: state.date,
        reasonType: state.reasonType,
        note: state.note,
        exceptionLines: [
          ExceptionLineParam(
            formType: state.firstFormType,
            timeNumber: state.firstHours,
          ),
          ExceptionLineParam(
            formType: state.secondFormType,
            timeNumber: state.secondHours,
          ),
        ],
      );

      await repository.createJustification(param);

      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
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
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Có lỗi xảy ra, vui lòng thử lại',
        ),
      );
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] is String) {
        return data['message'];
      }

      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final value = errors.values.first;
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
        }
      }
    }

    return 'Dữ liệu không hợp lệ';
  }
}
