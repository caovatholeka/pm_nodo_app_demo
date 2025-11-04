import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/commons/global_data.dart';
import '../../../core/logger/logger.dart';
import '../../../data/models/entities/token_entity.dart';
import '../../../data/repositories/auth_repository.dart';

part 'splash_state.dart';

enum SplashNavigator {
  OPEN_HOME,
  OPEN_LOG_IN,
}

class SplashCubit extends Cubit<SplashState> {
  AuthRepository authRepository;

  final navigatorController = PublishSubject<SplashNavigator>();

  SplashCubit({
    required this.authRepository,
  }) : super(SplashState());

  @override
  Future<void> close() {
    navigatorController.close();
    return super.close();
  }

  void getDevicesToken(String devicesToken) {
    GlobalData.instance.devicesToken = devicesToken;
  }

  void checkLogin() async {
    TokenEntity? token = await authRepository.getToken();

    if (token == null) {
      logger.d('emit LOGGED_OUT');
      emit(state.copyWith(loginState: LoginState.LOGGED_OUT));
      navigatorController.sink.add(SplashNavigator.OPEN_LOG_IN);
    } else {
      try {
        GlobalData.instance.token = token;

        emit(state.copyWith(loginState: LoginState.LOGGED_IN));
        navigatorController.sink.add(SplashNavigator.OPEN_HOME);
        logger.d('emit LOGGED_IN');
      } catch (error) {
        //Check 401
        if (error is DioException) {
          if (error.response?.statusCode == 401) {
            authRepository.removeToken();
            checkLogin();
            return;
          }
        }

        emit(state.copyWith(loginState: LoginState.ERROR));
        logger.e('$error');
      }
    }
  }
}