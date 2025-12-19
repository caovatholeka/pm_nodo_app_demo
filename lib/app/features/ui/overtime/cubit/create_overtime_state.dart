part of 'create_overtime_cubit.dart';

class CreateOvertimeState extends Equatable {
  final LoadStatus loadStatus;
  final String fromDate;
  final String toDate;
  final String? note;
  final List<OvertimeLineEntity> overtimeLines;
  final String? error;
  final bool submitSuccess;

  const CreateOvertimeState({
    this.loadStatus = LoadStatus.INITIAL,
    this.fromDate = '',
    this.toDate = '',
    this.note,
    this.overtimeLines = const [],
    this.error,
    this.submitSuccess = false,
  });

  CreateOvertimeState copyWith({
    LoadStatus? loadStatus,
    String? fromDate,
    String? toDate,
    String? note,
    List<OvertimeLineEntity>? overtimeLines,
    String? error,
    bool? submitSuccess,
  }) {
    return CreateOvertimeState(
      loadStatus: loadStatus ?? this.loadStatus,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      note: note ?? this.note,
      overtimeLines: overtimeLines ?? this.overtimeLines,
      error: error,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        fromDate,
        toDate,
        note,
        overtimeLines,
        error,
        submitSuccess,
      ];
}
