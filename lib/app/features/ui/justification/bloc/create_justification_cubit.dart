import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/repositories/jutification_repository.dart';
import 'package:pm_app/app/data/models/param/create_justification_param.dart';
import 'package:pm_app/app/data/models/param/exception_line_param.dart';

part 'create_justification_state.dart';

class CreateJustificationCubit extends Cubit<CreateJustificationState> {
  final JutificationRepository repository;

  CreateJustificationCubit(this.repository)
      : super(CreateJustificationState.initial());

  void changeDate(String value) => emit(state.copyWith(date: value));

  void changeReason(String value) => emit(state.copyWith(reasonType: value));

  void changeNote(String value) => emit(state.copyWith(note: value));

  void changeSelectedFormTypes(List<String> values) {
    final currentHours = Map<String, double>.from(state.formHours ?? {});
    
    final removedTypes = (state.selectedFormTypes ?? [])
        .where((type) => !values.contains(type))
        .toList();
    
    for (final type in removedTypes) {
      currentHours.remove(type);
    }

    emit(
      state.copyWith(
        selectedFormTypes: values,
        formHours: currentHours,
      ),
    );
  }

  void changeFormHours(String formType, double hours) {
    final updatedHours = Map<String, double>.from(state.formHours ?? {});
    updatedHours[formType] = hours;
    emit(state.copyWith(formHours: updatedHours));
  }

  void initFromDetail(JustificationEntity? e) {
    if (e == null) return;

    final selectedTypes = <String>[];
    final hours = <String, double>{};

    if (e.exceptionLines != null) {
      for (var line in e.exceptionLines!) {
        if (line.formType != null && line.timeNumber != null) {
          selectedTypes.add(line.formType!);
          hours[line.formType!] = line.timeNumber!;
        }
      }
    }

    emit(
      state.copyWith(
        id: e.id,
        date: e.date,
        reasonType: e.reasonType,
        note: e.note,
        selectedFormTypes: selectedTypes.isEmpty ? null : selectedTypes,
        formHours: hours.isEmpty ? null : hours,
      ),
    );
  }

  Future<void> submit() async {
    if (!state.isFormValid || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final lines = <ExceptionLineParam>[];

      for (final formType in state.selectedFormTypes!) {
        final hours = state.formHours![formType];
        if (hours != null) {
          lines.add(
            ExceptionLineParam(
              formType: formType,
              timeNumber: hours,
            ),
          );
        }
      }

      final param = CreateJustificationParam(
        date: state.date,
        reasonType: state.reasonType,
        note: state.note,
        exceptionLines: lines,
      );

      if (state.isEdit) {
        await repository.updateJustification(
          state.id!,
          param.toJson(),
        );
      } else {
        await repository.createJustification(param);
      }

      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } on DioException catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.response?.data?['message'] ?? 'Có lỗi xảy ra',
        ),
      );
    }
  }
}