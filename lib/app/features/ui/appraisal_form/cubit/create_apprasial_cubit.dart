import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'create_apprasial_state.dart';

class CreateAppraisalCubit extends Cubit<CreateAppraisalState> {
  CreateAppraisalCubit() : super(const CreateAppraisalState());

  void setFromDate(DateTime date) {
    emit(
      state.copyWith(
        fromDate: date,
        resetLines: true,
      )
    );
  }

  void setToDate(DateTime date) {
    emit(
      state.copyWith(
        toDate: date,
        resetLines: true,
      ),
    );
  }

  void setNote(String value) {
    emit(state.copyWith(note: value));
  }

  void setHour(int index, double? value) {
    final map = Map<int, double?>.from(state.hours);
    map[index] = value;
    emit(state.copyWith(hours: map));
  }

  void setFormType(int index, String? value) {
    final map = Map<int, String?>.from(state.formTypes);
    map[index] = value;
    emit(state.copyWith(formTypes: map));
  }

  Future<void> submit() async {
    if (!state.isFormValid) return;

    emit(state.copyWith(isSubmitting: true));

    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(isSubmitting: false));
  }
}
