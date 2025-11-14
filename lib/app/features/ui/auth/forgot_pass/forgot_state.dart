part of 'forgot_cubit.dart';

class ForgotState extends Equatable {
  final LoadStatus forgotStatus;
  final String? message;

  const ForgotState({
    this.forgotStatus = LoadStatus.INITIAL,
    this.message,
  });

  ForgotState copyWith({
    LoadStatus? forgotStatus,
    String? message,
  }) {
    return ForgotState(
      forgotStatus: forgotStatus ?? this.forgotStatus,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        forgotStatus,
        message,
      ];
}
