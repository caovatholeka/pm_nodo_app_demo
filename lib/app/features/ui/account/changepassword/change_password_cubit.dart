import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final UserRepository userRepository;

  ChangePasswordCubit({required this.userRepository})
      : super(ChangePasswordState());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      if (isClosed) return;
      emit(state.copyWith(
        status: LoadStatus.FAILURE,
        message: "Mật khẩu xác nhận không trùng khớp",
      ));
      return;
    }

    if (isClosed) return;
    emit(state.copyWith(status: LoadStatus.LOADING));

    try {
      final tokenEntity = await SharedPrefsHelper.getToken();
      logger.d("🔑 Token lấy được: ${tokenEntity?.toJson()}");
      final token = tokenEntity?.accessToken ?? tokenEntity?.accessToken;

      if (token == null || token.isEmpty) {
        if (isClosed) return;
        emit(state.copyWith(
          status: LoadStatus.FAILURE,
          message: "Token không hợp lệ hoặc chưa đăng nhập",
        ));
        return;
      }

      logger.d("🔐 Token dùng đổi mật khẩu: $token");

      final body = {
        "old_password": currentPassword,
        "new_password": newPassword,
        "retype_new_password": confirmPassword,
      };
      
      final CommonResponse response =
          await userRepository.changeCurrentPass(body);

      if (isClosed) return;
      emit(state.copyWith(
        status: LoadStatus.SUCCESS,
        message: response.message ?? "Đổi mật khẩu thành công!",
      ));
    } on DioException catch (e) {
      final msg = e.response?.data?["detail"]?["message"] ??
          e.response?.data?["message"] ??
          "Không thể đổi mật khẩu. Vui lòng thử lại!";

      logger.e("❌ Lỗi đổi mật khẩu: $msg");

      if (isClosed) return;
      emit(state.copyWith(
        status: LoadStatus.FAILURE,
        message: msg,
      ));
    } catch (e) {
      logger.e("⚠️ Lỗi khác: $e");

      if (isClosed) return;
      emit(state.copyWith(
        status: LoadStatus.FAILURE,
        message: e.toString(),
      ));
    }
  }
}
