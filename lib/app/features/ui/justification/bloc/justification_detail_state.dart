part of 'justification_detail_cubit.dart';

class JustificationDetailState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus approveStatus;
  final LoadStatus cancelStatus;
  final JustificationEntity? detail;
  final String? error;
  final bool isSubmitting;
  final bool submitSuccess;
  // Xóa đơn nháp; deleteError = thông báo lỗi từ server (nếu có).
  final LoadStatus deleteStatus;
  final String? deleteError;

  const JustificationDetailState({
    this.loadStatus = LoadStatus.INITIAL,
    this.approveStatus = LoadStatus.INITIAL,
    this.cancelStatus = LoadStatus.INITIAL,
    this.detail,
    this.error,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.deleteStatus = LoadStatus.INITIAL,
    this.deleteError,
  });

  JustificationDetailState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? approveStatus,
    LoadStatus? cancelStatus,
    JustificationEntity? detail,
    String? error,
    bool? isSubmitting,
    bool? submitSuccess,
    LoadStatus? deleteStatus,
    String? deleteError,
  }) {
    return JustificationDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      detail: detail ?? this.detail,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      approveStatus: approveStatus ?? this.approveStatus,
      cancelStatus: cancelStatus ?? this.cancelStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      deleteError: deleteError,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    approveStatus,
    cancelStatus,
    detail,
    error,
    isSubmitting,
    submitSuccess,
    deleteStatus,
    deleteError,
  ];
}
