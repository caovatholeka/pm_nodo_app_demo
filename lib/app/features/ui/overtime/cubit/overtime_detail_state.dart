part of 'overtime_detail_cubit.dart';

class OvertimeDetailState extends Equatable {
  final LoadStatus loadStatus;
  final OvertimeEntity? detail;
  final String? error;
  final bool isSubmitting;
  final bool submitSuccess;

  const OvertimeDetailState({
    this.loadStatus = LoadStatus.INITIAL,
    this.detail,
    this.error,
    this.isSubmitting = false,
    this.submitSuccess = false,
  });

  OvertimeDetailState copyWith({
    LoadStatus? loadStatus,
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
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    detail,
    error,
    isSubmitting,
    submitSuccess,
  ];
}
