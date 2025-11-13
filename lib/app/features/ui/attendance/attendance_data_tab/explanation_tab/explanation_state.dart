import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';

class ExplanationState extends Equatable {
  final bool isLoading;
  final ProfileEntity? profile;
  final String? error;
  final String? reason;
  final bool submitSuccess;

  const ExplanationState({
    this.isLoading = false,
    this.profile,
    this.error,
    this.reason,
    this.submitSuccess = false,
  });

  ExplanationState copyWith({
    bool? isLoading,
    ProfileEntity? profile,
    String? error,
    String? reason,
    bool? submitSuccess,
  }) {
    return ExplanationState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
      reason: reason ?? this.reason,
      submitSuccess: submitSuccess ?? this.submitSuccess, 
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, error, reason, submitSuccess];
}
