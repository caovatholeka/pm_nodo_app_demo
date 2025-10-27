import 'dart:convert';
import 'package:dio/dio.dart';
import '../../config/app_event.dart';
import '../../data/models/entities/token_entity.dart';
import '../../data/local/shared_prefs_helper.dart';
import '../commons/global_data.dart';
import '../logger/logger.dart';

class ApiInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final method = options.method;
    final uri = options.uri;
    final data = options.data;
    TokenEntity? token;

    if (GlobalData.instance.token == null) {
      token = await SharedPrefsHelper.getToken();
    } else {
      token = GlobalData.instance.token;
    }

    if (token != null) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }

    if (method == 'GET') {
      logger.long(
          "✈️ REQUEST[$method] => PATH: $uri \n Token: ${options.headers}");
    } else {
      try {
        logger.long(
            "✈️ REQUEST[$method] => PATH: $uri \n Token: ${GlobalData.instance.token?.accessToken} \n DATA: ${jsonEncode(data)}");
      } catch (e) {
        logger.long(
            "✈️ REQUEST[$method] => PATH: $uri \n Token: ${GlobalData.instance.token?.accessToken} \n DATA: $data");
      }
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final statusCode = response.statusCode;
    final uri = response.realUri;
    final data = jsonEncode(response.data);
    logger.long("✅ RESPONSE[$statusCode] => PATH: $uri\n DATA: $data");
    //Handle section expired
    if (response.statusCode == 401) {
      AppEvent.instance.onTokenExpired.add(true);
    }

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final uri = err.requestOptions.path;
    logger.long("⚠️ ERROR[$statusCode] => PATH: $uri");
    super.onError(err, handler);
  }

}