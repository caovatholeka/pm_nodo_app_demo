import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/response/common_response.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {required String baseUrl}) = _ApiClient;

  /// Đăng nhập
  @POST("/users/do_login")
  Future<CommonResponse> authLogin(@Body() Map<String, dynamic> body);

  /// Lấy thông tin người dùng
  @POST("/users/get_detail_users")
  Future<CommonResponse> getUserProfile(@Body() Map<String, dynamic> body);

  /// Đổi mật khẩu
  @POST("/users/change_password")
  Future<CommonResponse> changePassword(@Body() Map<String, dynamic> body);

  /// Đăng xuất
  @POST("/users/do_logout")
  Future<CommonResponse> logOut(@Body() Map<String, dynamic> body);

  /// Lấy danh sách nhân viên
  @GET("/employees/employees")
  Future<CommonResponse> getListEmployees(
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  );

  //Lấy chi tiết nhân viên
  @GET("/employees/employee/{id}")
  Future<CommonResponse> getDetailEmployee(@Path("id") int id);

  /// Lấy danh sách phòng ban 
  @GET("/metadata/departments")
  Future<CommonResponse> getListDepartments(
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  );

  /// Lấy danh sách đơn xin nghỉ
  @GET("/leave/get_hr_leave")
  Future<CommonResponse> getListTimeOnLeaves(
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  );

  /// Lấy chi tiết đơn xin nghỉ
  @GET("/leave/hr_leave/{id}")
  Future<OnLeaveEntity> getDetailOnLeave(@Path("id") int id);

  /// Xóa đơn xin nghỉ
  @DELETE("/leave/hr_leave/{id}")
  Future<dynamic> deleteDetailOnLeave( @Path('id') int id);

  // employee
  @GET("/employees/employees")
  Future<CommonResponse> getListEmployees(
      @Query("limit") int? limit,
      @Query("offset") int? offset,
      );
}