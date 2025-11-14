part of 'explanation_cubit.dart';

class ExplanationState extends Equatable {
  final bool isLoading;
  final ProfileEntity? profile;
  final String? error;
  final String? reason;
  final bool submitSuccess;
  final LoadStatus loadStatus;

  const ExplanationState({
    this.loadStatus = LoadStatus.INITIAL,
    this.isLoading = false,
    this.profile,
    this.error,
    this.reason,
    this.submitSuccess = false,
  });

  ExplanationState copyWith({
    LoadStatus? loadStatus,
    bool? isLoading,
    ProfileEntity? profile,
    String? error,
    String? reason,
    bool? submitSuccess,
  }) {
    return ExplanationState(
      loadStatus: loadStatus ?? this.loadStatus,
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
      reason: reason ?? this.reason,
      submitSuccess: submitSuccess ?? this.submitSuccess, 
    );
  }

  @override
  List<Object?> get props => [loadStatus,isLoading, profile, error, reason, submitSuccess];
}
