import 'package:dio/dio.dart';
import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/param/create_leave_param.dart';
import '../../data/models/response/common_response.dart';
import '../../data/models/response/on_leave_response.dart';

part 'api_client.g.dart';

@RestApi()//baseUrl: AppConfig.baseUrl
abstract class ApiClient {
  factory ApiClient(Dio dio, {required String baseUrl}) = _ApiClient;


  // get user profile
  @POST("/users/get_detail_users")
  Future<CommonResponse> getUserProfile(@Body() Map<String, dynamic> body);

  /// Auth
  @POST("/users/do_login")
  Future<CommonResponse> authLogin(@Body() Map<String, dynamic> body);

  //Đổi mật khẩu
  @POST("/users/change_password")
  Future<CommonResponse> changePassword(@Body() Map<String,dynamic> body);

  //Đăng xuất
  @POST("/users/do_logout")
  Future<CommonResponse> logOut(@Body() Map<String,dynamic> body);

  // xin nghi
  @GET("/leave/get_hr_leave")
  Future<CommonResponse> getListTimeOnLeaves(
      @Query("limit") int? limit,
      @Query("offset") int? offset,
      );

  @GET("/leave/hr_leave/{id}")
  Future<OnLeaveEntity> getDetailOnLeave( @Path('id') int id);

  @DELETE("/leave/hr_leave/{id}")
  Future<dynamic> deleteDetailOnLeave( @Path('id') int id);

  @POST("/leave/hr_leave/save_or_update")
  Future<OnLeaveResponse> saveOrUpdateLeave(@Body() UpdateOnLeaveParam param);

  @POST("/leave/hr_leave/confirm_hr_leave")
  Future<dynamic> confirmHrLeave(@Body() Map<String,dynamic> body);

  // employee
  @GET("/employees/employees")
  Future<CommonResponse> getListEmployees(
      @Query("limit") int? limit,
      @Query("offset") int? offset,
      );
}