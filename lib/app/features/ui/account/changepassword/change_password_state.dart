part of 'change_password_cubit.dart';

class ChangePasswordState extends Equatable {
  final LoadStatus status;
  final String? message;

  const ChangePasswordState({
    this.status = LoadStatus.INITIAL,
    this.message,
  });

  ChangePasswordState copyWith({
    LoadStatus? status,
    String? message,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
