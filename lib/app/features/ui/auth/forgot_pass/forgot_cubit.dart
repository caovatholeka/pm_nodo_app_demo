import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';

part 'forgot_state.dart';

class ForgotCubit extends Cubit<ForgotState> {
  final UserRepository _userRepo;

  ForgotCubit(this._userRepo) : super(const ForgotState());

  Future<void> submitForgotRequest({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      emit(state.copyWith(validationMessage: "Vui lòng nhập đầy đủ thông tin"));
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      emit(state.copyWith(validationMessage: "Email không hợp lệ"));
      return;
    }

    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
    if (!regex.hasMatch(password)) {
      emit(state.copyWith(
          validationMessage:
              "Mật khẩu phải ≥ 8 ký tự, có chữ IN HOA, số và ký tự đặc biệt"));
      return;
    }

    if (password != confirmPassword) {
      emit(state.copyWith(
          validationMessage: "Xác nhận mật khẩu không trùng khớp"));
      return;
    }

    emit(state.copyWith(forgotStatus: LoadStatus.LOADING));

    try {
      final body = {
        "email": email,
        "password": password,
        "confirm_password": confirmPassword,
      };

      final res = await _userRepo.sendOTP(body);

      if (res.error == false || res.code == 200 || res.code == 0) {
        emit(state.copyWith(forgotStatus: LoadStatus.SUCCESS));
      } else {
        emit(state.copyWith(
          forgotStatus: LoadStatus.FAILURE,
          message: res.message ?? "Gửi yêu cầu thất bại",
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        forgotStatus: LoadStatus.FAILURE,
        message: "Lỗi kết nối máy chủ",
      ));
    }
  }
}
