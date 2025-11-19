part of 'forgot_cubit.dart';

class ForgotState extends Equatable {
  final LoadStatus forgotStatus;
  final String? message;
  final String? validationMessage;

  const ForgotState({
    this.forgotStatus = LoadStatus.INITIAL,
    this.message,
    this.validationMessage,
  });

  ForgotState copyWith({
    LoadStatus? forgotStatus,
    String? message,
    String? validationMessage,
  }) {
    return ForgotState(
      forgotStatus: forgotStatus ?? this.forgotStatus,
      message: message ?? this.message,
      validationMessage: validationMessage,
    );
  }

  @override
  List<Object?> get props => [
        forgotStatus,
        message,
        validationMessage,
      ];
}
