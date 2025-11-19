part of 'otp_verify_cubit.dart';

class OtpVerifyState extends Equatable {
  final LoadStatus verifyStatus;
  final LoadStatus resendStatus;
  final String? errorMessage;

  const OtpVerifyState({
    this.verifyStatus = LoadStatus.INITIAL,
    this.resendStatus = LoadStatus.INITIAL,
    this.errorMessage,
  });

  OtpVerifyState copyWith({
    LoadStatus? verifyStatus,
    LoadStatus? resendStatus,
    String? errorMessage,
  }) {
    return OtpVerifyState(
      verifyStatus: verifyStatus ?? this.verifyStatus,
      resendStatus: resendStatus ?? this.resendStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        verifyStatus,
        resendStatus,
        errorMessage,
      ];
}
