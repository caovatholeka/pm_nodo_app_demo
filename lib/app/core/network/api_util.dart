import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../../data/models/entities/token_entity.dart';
import '../logger/logger.dart';
import 'api_client.dart';
import 'api_interceptors.dart';

class ApiUtil {
  ApiUtil._();
  static final ApiUtil instance = ApiUtil._();

  late final ApiInterceptors _interceptor = ApiInterceptors();

  late final Dio _dio = _createDio();

  late final ApiClient _client = ApiClient(_dio, baseUrl: AppConfig.baseUrl);

  Dio get dio => _dio;
  ApiClient get apiClient => _client;
  ApiInterceptors get interceptor => _interceptor;

  Dio _createDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));
    dio.interceptors.add(_interceptor);

    assert(() {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ));
      return true;
    }());

    return dio;
  }

  static Future<TokenEntity?> getNewAccessToken(
      TokenEntity token, [
        String? baseUrl,
      ]) async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));

    try {
      final res = await dio.post(
        '${baseUrl ?? AppConfig.baseUrl}/myllv-example/v1/auth/refresh-token',
        data: {'refreshToken': token.refreshToken},
      );

      if (res.statusCode != null &&
          res.statusCode! < 400 &&
          res.data is Map &&
          res.data['success'] == true) {
        logger.d('--- Get New AccessToken ---');
        logger.d('AccessToken: ${res.data['access_token']}');
        return token.copyWith(accessToken: res.data['access_token']);
      }
    } on DioException catch (e) {
      logger.e('Refresh token failed: ${e.message}');
    }
    return null;
  }
}
