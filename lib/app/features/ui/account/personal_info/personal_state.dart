import 'package:equatable/equatable.dart';
import '../../../../data/models/entities/profile_entity.dart';

class PersonalState extends Equatable {
  final bool isLoading;
  final String? error;
  final ProfileEntity? profile;

  const PersonalState({
    this.isLoading = false,
    this.error,
    this.profile,
  });

  PersonalState copyWith({
    bool? isLoading,
    String? error,
    ProfileEntity? profile,
  }) {
    return PersonalState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, profile];
}
