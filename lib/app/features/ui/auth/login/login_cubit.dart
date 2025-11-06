import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/commons/global_data.dart';
import '../../../../core/helper/response_mapper.dart';
import '../../../../core/logger/logger.dart';
import '../../../../data/models/entities/token_entity.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';
import '../../../bloc/app_cubit.dart';


part 'login_state.dart';

class LogInCubit extends Cubit<LoginState> {
  AuthRepository authRepository;

  LogInCubit({
    required this.authRepository
  }):super(LoginState());


  @override
  Future<void> close() {
    // showMessageController.close();
    return super.close();
  }

  void onReset() {
    emit(state.copyWith(
      tokenEntity: null,
      loginStatus: LoadStatus.INITIAL,
      // showPassword: false,
      // userName: "",
      // password: ""
    ));
  }

void doLogin(String username, String password) async {
  emit(state.copyWith(loginStatus: LoadStatus.LOADING));

  try {
    final param = {
      "login": username,
      "password": password,
    };

    final result = await authRepository.authLogin(param);
    TokenEntity? entity = mapObject(result.data, TokenEntity.fromJson);

    if (entity != null) {
      GlobalData.instance.userId = entity.uid;
      GlobalData.instance.token = entity;
      logger.d("🔐 Lưu token vào GlobalData: ${entity.toJson()}");
      await authRepository.saveToken(entity);

      final appCubit = GetIt.I<AppCubit>();
      appCubit.getProfile();
    }

    emit(state.copyWith(
      loginStatus: LoadStatus.SUCCESS,
      userName: "",
      password: "",
    ));

    logger.d("login success :: ${result.toJson()}");
  } on DioException catch (e, s) {
    logger.e(e);
    logger.e(s);

    await authRepository.removeToken();
    GlobalData.instance.token = null;

    final res = e.response?.data as Map<String, dynamic>? ?? {};
    emit(state.copyWith(
      loginStatus: LoadStatus.FAILURE,
      errMsg: res["message"] ?? "Đăng nhập thất bại",
    ));
  }
}



  void onChangeUSerName(String userName){
    emit(state.copyWith(userName: userName));
  }

  void onChangePassword(String password) {
    emit(state.copyWith(password: password));
  }

  void onShowHidePwd(bool isShow){
    emit(state.copyWith(showPassword: !isShow));
  }
}