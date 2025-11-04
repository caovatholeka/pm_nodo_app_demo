import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';

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
      emit(state.copyWith(
          status: LoadStatus.FAILURE,
          message: "Mật khẩu xác nhận không khớp!"));
      return;
    }

    emit(state.copyWith(status: LoadStatus.LOADING));

    try {
      final body = {
        "old_password": currentPassword,
        "new_password": newPassword,
        "retype_new_password": confirmPassword
      };

      final result = await userRepository.changeCurrentPass(body);


      if (result.status == true || result.code == 200) {
        emit(state.copyWith(
          status: LoadStatus.SUCCESS,
          message: "Đổi mật khẩu thành công!",
        ));
      } else {
        emit(state.copyWith(
          status: LoadStatus.FAILURE,
          message: result.message ?? "Đổi mật khẩu thất bại!",
        ));
      }
    } on DioException catch (e) {
      logger.e("Change password error");
      emit(state.copyWith(
          status: LoadStatus.FAILURE,
          message: e.response?.data["message"] ?? "Lỗi hệ thống"));
    } catch (e) {
      emit(state.copyWith(
          status: LoadStatus.FAILURE, message: "Lỗi: ${e.toString()}"));
    }
  }
}
