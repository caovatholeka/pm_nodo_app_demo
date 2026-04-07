import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
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

  LogInCubit({required this.authRepository}) : super(LoginState());

  void resetState() {
    emit(const LoginState());
  }

  void doLogin(String username, String password) async {
    final type = GlobalData.instance.quickActionPending;
    GlobalData.instance.isLoggingIn = true;
    emit(state.copyWith(loginStatus: LoadStatus.LOADING, errMsg: null));
    try {
      String deviceId = await SharedPrefsHelper.getDeviceId();
      String fcmToken = await SharedPrefsHelper.getFcmToken();
      String deviceType = await SharedPrefsHelper.getDeviceType();

      final param = {
        "login": username,
        "password": password,
        "device_id": deviceId,
        "fcm_token": fcmToken,
        "device_type": deviceType,
      };
      final result = await authRepository.authLogin(param);

      final raw = result.data;

      if (raw is Map<String, dynamic> && raw["error"] == true) {
        final message = raw["message"] ?? "Đăng nhập thất bại";

        emit(state.copyWith(loginStatus: LoadStatus.FAILURE, errMsg: message));
        GlobalData.instance.isLoggingIn = false;
        return;
      }

      logger.d("🔁 authLogin raw response: ${result.toJson()}");

      dynamic payload = result.data;
      if (payload is Map && payload.containsKey('data')) {
        payload = payload['data'];
      }

      TokenEntity? entity = mapObject(payload, TokenEntity.fromJson);

      if (entity == null) {
        try {
          entity = TokenEntity.fromJson(payload as Map<String, dynamic>);
        } catch (e) {
          logger.w("⚠️ TokenEntity.fromJson failed: $e");
        }
      }

      if (entity != null &&
          entity.accessToken != null &&
          entity.accessToken!.isNotEmpty) {
        GlobalData.instance.userId = entity.uid;
        GlobalData.instance.token = entity;
        logger.i("🔐 Lưu token vào GlobalData: ${entity.toJson()}");

        await authRepository.saveToken(entity);
        await SharedPrefsHelper.setIsLoginApp(true);

        if (state.rememberMe == true) {
          await SharedPrefsHelper.setUsername(username);
        } else {
          await SharedPrefsHelper.setUsername("");
        }

        final appCubit = GetIt.I<AppCubit>();
        await appCubit.getProfile();

        emit(
          state.copyWith(loginStatus: LoadStatus.SUCCESS, tokenEntity: entity),
        );
        GlobalData.instance.isLoggingIn = false;
        if (type != null) {
          GlobalData.instance.quickActionPending = type;
        }
      } else {
        logger.w("⚠️ Không nhận được token từ server: $payload");
        emit(
          state.copyWith(
            loginStatus: LoadStatus.FAILURE,
            errMsg: "Không nhận được token từ server",
          ),
        );
      }
    } on DioException catch (e, s) {
      logger.e("Login failed: $e");
      logger.e(s);

      await authRepository.removeToken();
      GlobalData.instance.token = null;

      String message = "Đăng nhập thất bại";
      final res = e.response?.data;

      if (e.response?.statusCode == 401) {
        message = "Tài khoản hoặc mật khẩu không đúng";
      } else if (res is Map<String, dynamic> && res["message"] != null) {
        message = res["message"];
      } else if (e.type == DioExceptionType.connectionError) {
        message = "Không thể kết nối đến máy chủ, kiểm tra mạng của bạn";
      }

      emit(state.copyWith(loginStatus: LoadStatus.FAILURE, errMsg: message));
    } catch (e, s) {
      logger.e("Unexpected error during login: $e");
      logger.e(s);
      emit(
        state.copyWith(
          loginStatus: LoadStatus.FAILURE,
          errMsg: "Lỗi không xác định",
        ),
      );
    } finally {
      GlobalData.instance.isLoggingIn = false;
    }
  }

  void onChangeUSerName(String userName) {
    emit(state.copyWith(userName: userName));
  }

  void onChangePassword(String password) {
    emit(state.copyWith(password: password));
  }

  void onShowHidePwd(bool isShow) {
    emit(state.copyWith(showPassword: !isShow));
  }

  void onRememberMe(bool? value) {
    emit(state.copyWith(rememberMe: value));
  }
}
