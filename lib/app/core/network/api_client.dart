import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../config/app_config.dart';
import '../../data/models/entities/token_entity.dart';
import '../../data/models/response/common_response.dart';

part 'api_client.g.dart';

@RestApi()//baseUrl: AppConfig.baseUrl
abstract class ApiClient {
  factory ApiClient(Dio dio, {required String baseUrl}) = _ApiClient;

  /// Auth
  @POST("/users/do_login")
  Future<CommonResponse> authLogin(@Body() Map<String, dynamic> body);


  // xin nghi
  @POST("/client/api/v1/timeOffManagement/search")
  Future<CommonResponse> getListTimeOnLeaves(@Body() Map<String, dynamic> body,
      @Query("size") int? size,
      @Query("number") int? number,
      );

  @GET("/client/api/v1/timeOffManagement/get-data/{id}")
  Future<CommonResponse> getDetailOnLeave( @Path('id') int id);
}