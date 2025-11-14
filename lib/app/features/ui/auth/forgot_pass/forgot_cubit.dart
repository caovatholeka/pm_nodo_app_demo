import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/auth_repository.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';

part 'forgot_state.dart';

class ForgotCubit extends Cubit<ForgotState> {
  final UserRepository _userRepo;

  String? savedLogin;

  ForgotCubit(this._userRepo)
      : super(const ForgotState());

  Future<void> sendForgotRequest(String login) async {
    emit(state.copyWith(forgotStatus: LoadStatus.LOADING));

    try {
      final res = await _userRepo.forgotPassword({"login": login});

      if (res.error == false || res.code == 200 || res.code == 0) {
        emit(state.copyWith(forgotStatus: LoadStatus.SUCCESS));
      } else {
        emit(state.copyWith(
        forgotStatus: LoadStatus.FAILURE,
        message: res.message ?? "Gửi mail thất bại",
      ));
    }
    } catch (e) {
      emit(state.copyWith(
        forgotStatus: LoadStatus.FAILURE,
        message: "Lỗi kết nối máy chủ",
      ));
    }
  }
}
