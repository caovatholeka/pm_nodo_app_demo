import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/core/utils/validators.dart';
import 'package:pm_app/generated/l10n.dart';

part 'forgot_state.dart';

class ForgotCubit extends Cubit<ForgotState> {
  final UserRepository _userRepo;

  ForgotCubit(this._userRepo) : super(const ForgotState());

  final Validator _validator = Validator();

  void resetStatus() {
    emit(const ForgotState());
  }

  Future<void> submitForgotRequest({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {

    emit(state.copyWith(
      validationMessage: null,
      forgotStatus: LoadStatus.INITIAL,
    ));


    final emailError = _validator.validateEmail(email);
    if (emailError != null) {
      emit(state.copyWith(
        validationMessage: S.current.common_invalid_email,
        forgotStatus: LoadStatus.FAILURE,
      ));
      return;
    }

    final passError =
        _validator.validatePassword(password, S.current.password);
    if (passError != null) {
      emit(state.copyWith(
        validationMessage: S.current.common_new_password_rule,
        forgotStatus: LoadStatus.FAILURE,
      ));
      return;
    }

    final confirmError =
        _validator.validateConfirmPassword(password, confirmPassword);
    if (confirmError != null) {
      emit(state.copyWith(
        validationMessage: confirmError,
        forgotStatus: LoadStatus.FAILURE,
      ));
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
        emit(state.copyWith(
          forgotStatus: LoadStatus.SUCCESS,
          validationMessage: null,
        ));
      } else {
        emit(state.copyWith(
          forgotStatus: LoadStatus.FAILURE,
          validationMessage:
              res.message ?? S.current.common_request_failed,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        forgotStatus: LoadStatus.FAILURE,
        validationMessage: S.current.common_server_connection_error,
      ));
    }
  }
}
