import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_justification_state.dart';

class CreateJustificationCubit
    extends Cubit<CreateJustificationState> {
  CreateJustificationCubit() : super(const CreateJustificationState()) {
    _loadMockData();
  }
  void _loadMockData() {
    const reasons = [
      DropdownItem(id: 'late', name: 'Đi muộn'),
      DropdownItem(id: 'early', name: 'Về sớm'),
      DropdownItem(id: 'personal', name: 'Việc cá nhân'),
    ];

    const methods = [
      DropdownItem(id: 'wfh', name: 'Làm việc tại nhà'),
      DropdownItem(id: 'onsite', name: 'Làm việc tại công ty'),
      DropdownItem(id: 'other', name: 'Khác'),
    ];

    emit(state.copyWith(
      reasons: reasons,
      methods: methods,
    ));
  }

  void selectReason(DropdownItem item) {
    emit(state.copyWith(selectedReason: item));
  }

  void selectMethod(DropdownItem item) {
    emit(state.copyWith(selectedMethod: item));
  }

  void changeDate(String value) {
    emit(state.copyWith(date: value));
  }

  void changeHours(String value) {
    emit(state.copyWith(hours: value));
  }

  void changeNote(String value) {
    emit(state.copyWith(note: value));
  }

  Future<void> submit() async {
    if (!state.isFormValid) return;

    emit(state.copyWith(isSubmitting: true));

    final payload = {
      "reason_type": state.selectedReason!.id,
      "method": state.selectedMethod!.id,
      "date": state.date,
      "hours": state.hours,
      "note": state.note,
    };

    // TODO: call API
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(isSubmitting: false));
  }
}
