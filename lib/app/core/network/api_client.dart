import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../config/app_config.dart';
import '../../data/models/entities/token_entity.dart';

part 'api_client.g.dart';

@RestApi()//baseUrl: AppConfig.baseUrl
abstract class ApiClient {
  factory ApiClient(Dio dio, {required String baseUrl}) = _ApiClient;

  /// Auth
  @POST("/client/api/v1/login")
  Future<TokenEntity> authLogin(@Body() Map<String, dynamic> body);
}