part of 'create_overtime_cubit.dart';

class CreateOvertimeState extends Equatable {
  final String? fromDate;
  final String? toDate;
  final String? note;
  final List<OvertimeLineEntity> overtimeLines;

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final String? successMessage;


  final int? id;
  bool get isEdit => id != null;

  const CreateOvertimeState({
    this.fromDate,
    this.toDate,
    this.note,
    this.overtimeLines = const [],
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.id,
    this.successMessage,
  });

  bool get isFormValid {
    if (fromDate == null || toDate == null) return false;
    if (overtimeLines.isEmpty) return false;

    for (final e in overtimeLines) {
      if (e.overtime == null || e.overtime! <= 0) return false;
      if (e.formType == null) return false;
    }
    return true;
  }

  CreateOvertimeState copyWith({
    String? fromDate,
    String? toDate,
    String? note,
    List<OvertimeLineEntity>? overtimeLines,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    String? successMessage,
    int? id,
  }) {
    return CreateOvertimeState(
      id: id ?? this.id,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      note: note ?? this.note,
      overtimeLines: overtimeLines ?? this.overtimeLines,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  factory CreateOvertimeState.initial() => const CreateOvertimeState();

  @override
  List<Object?> get props => [
        fromDate,
        toDate,
        note,
        overtimeLines,
        isSubmitting,
        isSuccess,
        errorMessage,
        id,
      ];
}
