import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/app_flags.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/core/service/firebase_messaging_service.dart';
import '../../../../core/commons/global_data.dart';
import '../../../../core/helper/response_mapper.dart';
import '../../../../core/logger/logger.dart';
import '../../../../data/models/entities/token_entity.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';
import '../../../bloc/app_cubit.dart';
import 'package:pm_app/generated/l10n.dart';

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
      final identifiers =
          await FirebaseMessagingService.ensureCachedMessagingIdentifiers(
            refreshToken: false,
          );

      final deviceId = identifiers['device_id'] ?? '';
      final fcmToken = identifiers['fcm_token'] ?? '';
      final deviceType = identifiers['device_type'] ?? '';

      final param = {"login": username, "password": password};

      if (deviceId.isNotEmpty) {
        param["device_id"] = deviceId;
      }
      if (fcmToken.isNotEmpty) {
        param["fcm_token"] = fcmToken;
      }
      if (deviceType.isNotEmpty) {
        param["device_type"] = deviceType;
      }

      logger.d(
        "Login device payload -> "
        "deviceId=${deviceId.isEmpty ? '<empty>' : deviceId}, "
        "deviceType=${deviceType.isEmpty ? '<empty>' : deviceType}, "
        "hasFcmToken=${fcmToken.isNotEmpty}",
      );

      final result = await authRepository.authLogin(param);

      final raw = result.data;

      if (raw is Map<String, dynamic> && raw["error"] == true) {
        final message = _normalizeLoginMessage(
          _extractServerMessage(raw, fallback: result.message ?? ""),
        );

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

        // Luôn ghi lại tài khoản vừa đăng nhập (độc lập với "nhớ tài khoản"),
        // để lần khởi động sau app biết nên hiện giao diện nào ngay từ splash.
        await SharedPrefsHelper.setLastLoginEmail(username);
        AppFlags.cachedLoginEmail = username.trim().toLowerCase();

        final appCubit = GetIt.I<AppCubit>();
        await appCubit.getProfile(forceRefresh: true);

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
            errMsg: _extractServerMessage(
              raw,
              fallback: result.message ?? S.current.common_login_no_token,
            ),
          ),
        );
      }
    } on DioException catch (e, s) {
      logger.e("Login failed: $e");
      logger.e(s);

      await authRepository.removeToken();
      GlobalData.instance.token = null;

      String message = S.current.common_login_failed;
      final res = e.response?.data;

      final serverMessage = _extractServerMessage(res);

      if (e.type == DioExceptionType.connectionError) {
        message = S.current.common_cannot_connect_check_network;
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        message = S.current.common_connection_timeout_retry;
      } else if (_isLoginCredentialError(
        e.response?.statusCode,
        serverMessage,
      )) {
        message = _wrongCredentialsMessage;
      } else if (serverMessage.isNotEmpty) {
        message = serverMessage;
      }

      emit(state.copyWith(loginStatus: LoadStatus.FAILURE, errMsg: message));
    } catch (e, s) {
      logger.e("Unexpected error during login: $e");
      logger.e(s);
      emit(
        state.copyWith(
          loginStatus: LoadStatus.FAILURE,
          errMsg: S.current.common_unknown_error,
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

  String _extractServerMessage(dynamic data, {String fallback = ''}) {
    final message = _findMessage(data);
    if (message.isNotEmpty) return message;
    return fallback;
  }

  static String get _wrongCredentialsMessage => S.current.common_wrong_credentials;

  String _normalizeLoginMessage(String message) {
    final text = message.trim();
    if (text.isEmpty || _isUnclearServerMessage(text)) {
      return _wrongCredentialsMessage;
    }
    return text;
  }

  bool _isLoginCredentialError(int? statusCode, String serverMessage) {
    if (_isUnclearServerMessage(serverMessage)) return true;

    return statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 404 ||
        statusCode == 422;
  }

  bool _isUnclearServerMessage(String message) {
    final text = message.trim().toLowerCase();
    return text.isEmpty ||
        text == "internal server error" ||
        text == "server error" ||
        text.contains("internal server error");
  }

  String _findMessage(dynamic data) {
    if (data == null) return '';

    if (data is String) {
      final text = data.trim();
      if (text.isEmpty) return '';

      try {
        final decoded = jsonDecode(text);
        return _findMessage(decoded);
      } catch (_) {
        return text;
      }
    }

    if (data is List) {
      for (final item in data) {
        final message = _findMessage(item);
        if (message.isNotEmpty) return message;
      }
      return '';
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      const directKeys = [
        'message',
        'msg',
        'errorMessage',
        'error_message',
        'detail',
      ];
      for (final key in directKeys) {
        final value = map[key];
        final message = _findMessage(value);
        if (message.isNotEmpty) return message;
      }

      if (map['errors'] != null) {
        final errors = _findMessage(map['errors']);
        if (errors.isNotEmpty) return errors;
      }

      for (final entry in map.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key.contains('message') ||
            key.contains('error') ||
            key.contains('detail')) {
          final message = _findMessage(entry.value);
          if (message.isNotEmpty) return message;
        }
      }
    }

    return '';
  }
}
