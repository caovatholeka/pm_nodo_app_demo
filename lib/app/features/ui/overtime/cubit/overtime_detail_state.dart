part of 'overtime_detail_cubit.dart';

class OvertimeDetailState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus approveStatus;
  final LoadStatus cancelStatus;
  final OvertimeEntity? detail;
  final String? error;
  final bool isSubmitting;
  final bool submitSuccess;

  const OvertimeDetailState({
    this.loadStatus = LoadStatus.INITIAL,
    this.approveStatus = LoadStatus.INITIAL,
    this.cancelStatus = LoadStatus.INITIAL,
    this.detail,
    this.error,
    this.isSubmitting = false,
    this.submitSuccess = false,
  });

  OvertimeDetailState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? approveStatus,
    LoadStatus? cancelStatus,
    OvertimeEntity? detail,
    String? error,
    bool? isSubmitting,
    bool? submitSuccess,
  }) {
    return OvertimeDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      approveStatus: approveStatus ?? this.approveStatus,
      cancelStatus: cancelStatus ?? this.cancelStatus,
      detail: detail ?? this.detail,
      error: error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    detail,
    error,
    isSubmitting,
    submitSuccess,
    approveStatus,
    cancelStatus,
  ];
}
