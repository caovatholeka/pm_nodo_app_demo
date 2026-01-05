import 'package:dio/dio.dart';
import 'fire_base_analystic.dart';

class DioCrashlyticsInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    FirebaseAnalysticService.recordError(
      err,
      err.stackTrace,
      fatal: false,
    );

    FirebaseAnalysticService.log(
      err.requestOptions.path,
    );

    super.onError(err, handler);
  }
}
