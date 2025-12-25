part of 'create_justification_cubit.dart';

class CreateJustificationState {
  final String? date;
  final String? reasonType;
  final String? note;

  final List<String>? selectedFormTypes;
  final Map<String, double>? formHours;

  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;
  final int? id;

  bool get isEdit => id != null;

  const CreateJustificationState({
    this.date,
    this.reasonType,
    this.note,
    this.selectedFormTypes,
    this.formHours,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
    this.id,
  });

  bool get isFormValid {
    if (date == null || date!.isEmpty) return false;
    if (reasonType == null) return false;
    if (note == null || note!.trim().isEmpty) return false;
    if (selectedFormTypes == null || selectedFormTypes!.isEmpty) return false;

    for (final formType in selectedFormTypes!) {
      if (formHours == null || !formHours!.containsKey(formType)) {
        return false;
      }
      if (formHours![formType] == null) return false;
    }

    return true;
  }

  CreateJustificationState copyWith({
    String? date,
    String? reasonType,
    String? note,
    List<String>? selectedFormTypes,
    Map<String, double>? formHours,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
    int? id,
  }) {
    return CreateJustificationState(
      id: id ?? this.id,
      date: date ?? this.date,
      reasonType: reasonType ?? this.reasonType,
      note: note ?? this.note,
      selectedFormTypes: selectedFormTypes ?? this.selectedFormTypes,
      formHours: formHours ?? this.formHours,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  factory CreateJustificationState.initial() =>
      const CreateJustificationState();
}