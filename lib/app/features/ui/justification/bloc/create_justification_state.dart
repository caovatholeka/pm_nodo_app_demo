part of 'create_justification_cubit.dart';

class CreateJustificationState {
  final String? date;
  final String? reasonType;
  final String? note;

  final String? firstFormType;
  final double? firstHours;

  final String? secondFormType;
  final double? secondHours;

  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const CreateJustificationState({
    this.date,
    this.reasonType,
    this.note,
    this.firstFormType,
    this.firstHours,
    this.secondFormType,
    this.secondHours,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  bool get isFormValid =>
      date != null &&
      date!.isNotEmpty &&
      reasonType != null &&
      reasonType!.isNotEmpty &&
      note != null &&
      note!.trim().isNotEmpty &&
      firstFormType != null &&
      firstHours != null &&
      secondFormType != null &&
      secondHours != null;

  CreateJustificationState copyWith({
    String? date,
    String? reasonType,
    String? note,
    String? firstFormType,
    double? firstHours,
    String? secondFormType,
    double? secondHours,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return CreateJustificationState(
      date: date ?? this.date,
      reasonType: reasonType ?? this.reasonType,
      note: note ?? this.note,
      firstFormType: firstFormType ?? this.firstFormType,
      firstHours: firstHours ?? this.firstHours,
      secondFormType: secondFormType ?? this.secondFormType,
      secondHours: secondHours ?? this.secondHours,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  factory CreateJustificationState.initial() =>
      const CreateJustificationState();
}
