import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';

part 'otp_verify_state.dart';

class OtpVerifyCubit extends Cubit<OtpVerifyState> {
  final UserRepository _userRepo;

  OtpVerifyCubit(this._userRepo) : super(const OtpVerifyState());

  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    emit(state.copyWith(errorMessage: null));
    emit(state.copyWith(verifyStatus: LoadStatus.LOADING));

    try {
      final res = await _userRepo.verifyOtp({
        "email": email,
        "otp": otp,
      });

      if (res.error == false || res.code == 200 || res.code == 0) {
        emit(state.copyWith(verifyStatus: LoadStatus.SUCCESS));
      } else {
        emit(state.copyWith(
          verifyStatus: LoadStatus.FAILURE,
          errorMessage: res.message ?? "Xác minh OTP thất bại",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        verifyStatus: LoadStatus.FAILURE,
        errorMessage: "Lỗi kết nối máy chủ",
      ));
    }
  }

  Future<void> resendOTP({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    emit(state.copyWith(
      errorMessage: null,
      resendStatus: LoadStatus.LOADING,
    ));

    try {
      final res = await _userRepo.sendOTP({
        "email": email,
        "password": password,
        "confirm_password": confirmPassword,
      });

      if (res.error == false || res.code == 200 || res.code == 0) {
        emit(state.copyWith(resendStatus: LoadStatus.SUCCESS));
      } else {
        emit(state.copyWith(
          resendStatus: LoadStatus.FAILURE,
          errorMessage: res.message ?? "Gửi lại OTP thất bại",
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        resendStatus: LoadStatus.FAILURE,
        errorMessage: "Lỗi kết nối máy chủ",
      ));
    }
  }
}
