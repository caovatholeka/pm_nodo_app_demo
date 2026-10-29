import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';
import 'package:pm_app/generated/l10n.dart';

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
      emit(
        state.copyWith(
          status: LoadStatus.FAILURE,
          message: S.current.common_confirm_password_mismatch,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoadStatus.LOADING));

    try {
      final tokenEntity = await SharedPrefsHelper.getToken();
      final token = tokenEntity?.accessToken;

      if (token == null || token.isEmpty) {
        emit(
          state.copyWith(
            status: LoadStatus.FAILURE,
            message: S.current.common_invalid_token,
          ),
        );
        return;
      }

      final body = {
        "old_password": currentPassword,
        "new_password": newPassword,
        "retype_new_password": confirmPassword,
      };

      final CommonResponse response = await userRepository.changeCurrentPass(
        body,
      );

      if (response.code != 200) {
        emit(
          state.copyWith(
            status: LoadStatus.FAILURE,
            message: response.message ?? S.current.common_change_password_failed,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: LoadStatus.SUCCESS,
          message: response.message ?? S.current.change_password_success,
        ),
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?["detail"]?["message"] ??
          e.response?.data?["message"] ??
          S.current.common_change_password_retry;

      if (!isClosed) {
        emit(state.copyWith(status: LoadStatus.FAILURE, message: msg));
      }
    } catch (e) {
      logger.e("err: $e");
      if (!isClosed) {
        emit(
          state.copyWith(
            status: LoadStatus.FAILURE,
            message: S.current.common_unknown_error_detail(e),
          ),
        );
      }
    }
  }
}
