import 'package:dio/dio.dart';
import 'package:pm_app/app/data/models/entities/attendance_entity.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/param/create_leave_param.dart';
import '../../data/models/response/common_response.dart';
import '../../data/models/response/on_leave_response.dart';

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
  @Query("name") String? name,
  @Query("code") String? code,
  @Query("email") String? email,
  @Query("department_id") int? departmentId,
  @Query("job_title") String? jobTitle,
  @Query("active") bool? active,
);

  @GET("/metadata/jobs")
  Future<CommonResponse> getListJobs(
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  );

  /// Lấy danh sách phòng ban 
  @GET("/metadata/departments")
  Future<CommonResponse> getListDepartments(
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  );

  //Lấy chi tiết nhân viên
  @GET("/employees/employees/{id}")
  Future<EmployeeEntity> getDetailEmployee(@Path("id") int id);

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

  @POST("/leave/hr_leave/save_or_update")
  Future<OnLeaveResponse> saveOrUpdateLeave(@Body() UpdateOnLeaveParam param);

  @POST("/leave/hr_leave/confirm_hr_leave")
  Future<dynamic> confirmHrLeave(@Body() Map<String,dynamic> body);


  // danh sach cham cong
  @GET("/work_entry/attendance/by_month")
  Future<List<AttendanceEntity>> getListAttendances(
      @Query("employee_id") int? employeeId,
      @Query("month") int? month,
      @Query("year") int? year,
      );
}