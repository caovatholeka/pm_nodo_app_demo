part of 'justification_detail_cubit.dart';

class JustificationDetailState extends Equatable {
  final LoadStatus loadStatus;
  final JustificationEntity? detail;
  final String? error;
  final bool isSubmitting;
  final bool submitSuccess;

  const JustificationDetailState({
    this.loadStatus = LoadStatus.INITIAL,
    this.detail,
    this.error,
    this.isSubmitting = false,
    this.submitSuccess = false,
  });

  JustificationDetailState copyWith({
    LoadStatus? loadStatus,
    JustificationEntity? detail,
    String? error,
    bool? isSubmitting,
    bool? submitSuccess,
  }) {
    return JustificationDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      detail: detail ?? this.detail,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  @override
  List<Object?> get props =>
      [loadStatus, detail, error, isSubmitting, submitSuccess];
}
