part of 'overtime_detail_cubit.dart';

class OvertimeDetailState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus approveStatus;
  final OvertimeEntity? detail;
  final String? error;
  final bool isSubmitting;
  final bool submitSuccess;

  const OvertimeDetailState({
    this.loadStatus = LoadStatus.INITIAL,
    this.approveStatus = LoadStatus.INITIAL,
    this.detail,
    this.error,
    this.isSubmitting = false,
    this.submitSuccess = false,
  });

  OvertimeDetailState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? approveStatus,
    OvertimeEntity? detail,
    String? error,
    bool? isSubmitting,
    bool? submitSuccess,
  }) {
    return OvertimeDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      detail: detail ?? this.detail,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      approveStatus: approveStatus ?? this.approveStatus,
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
  ];
}
