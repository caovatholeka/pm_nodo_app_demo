part of 'create_apprasial_cubit.dart';

class CreateAppraisalState extends Equatable {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String note;
  final Map<int, double?> hours;
  final Map<int, String?> formTypes;
  final bool isSubmitting;

  const CreateAppraisalState({
    this.fromDate,
    this.toDate,
    this.note = '',
    this.hours = const {},
    this.formTypes = const {},
    this.isSubmitting = false,
  });
  bool get isFormValid {
    return fromDate != null && toDate != null;
  }

  CreateAppraisalState copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    String? note,
    Map<int, double?>? hours,
    Map<int, String?>? formTypes,
    bool? isSubmitting,
    bool resetLines = false,
  }) {
    return CreateAppraisalState(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      note: note ?? this.note,
      hours: resetLines ? {} : (hours ?? this.hours),
      formTypes: resetLines ? {} : (formTypes ?? this.formTypes),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    fromDate,
    toDate,
    note,
    hours,
    formTypes,
    isSubmitting,
  ];
}
