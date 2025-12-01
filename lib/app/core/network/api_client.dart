import 'package:dio/dio.dart';
import 'package:pm_app/app/data/models/entities/attendance_entity.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';
import 'package:pm_app/app/data/models/param/create_task_param.dart';
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

  //Quên mật khẩu
  @POST("/users/forget_password")
  Future<CommonResponse> forgotPassword(@Body() Map<String, dynamic> body);

  /// Đăng xuất
  @POST("/users/do_logout")
  Future<CommonResponse> logOut(@Body() Map<String, dynamic> body);

  /// Lấy danh sách nhân viên
  @GET("/employees/employees")
  Future<CommonResponse> getListEmployees(
    @Query("limit") int? limit,
    @Query("page") int? offset,
    @Query("name") String? name,
    @Query("code") String? code,
    @Query("email") String? email,
    @Query("department_id") int? departmentId,
    @Query("job_id") int? jobTitle,
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
    @Query("page") int? page,
    @Query("start_date") String? startDate,
    @Query("end_date") String? endDate,
  );

  /// Lấy chi tiết đơn xin nghỉ
  @GET("/leave/hr_leave/{id}")
  Future<OnLeaveEntity> getDetailOnLeave(@Path("id") int id);

  /// Xóa đơn xin nghỉ
  @DELETE("/leave/hr_leave/{id}")
  Future<dynamic> deleteDetailOnLeave(@Path('id') int id);

  @POST("/leave/hr_leave/save_or_update")
  Future<OnLeaveResponse> saveOrUpdateLeave(@Body() UpdateOnLeaveParam param);

  @POST("/leave/hr_leave/confirm_hr_leave")
  Future<dynamic> confirmHrLeave(@Body() Map<String, dynamic> body);

  @GET("/metadata/leave_types")
  Future<CommonResponse> getListLeavesType();

  //Danh sách chấm công
  @GET("/work_entry/attendance/by_month")
  Future<List<AttendanceEntity>> getListAttendances(
    @Query("employee_id") int? employeeId,
    @Query("month") int? month,
    @Query("year") int? year,
  );

  // Chi tiết chấm công
  @GET("/work_entry/attendance_detail")
  Future<CommonResponse> getDetailWorkEntry(@Query("attendance_id") int? attendanceId,);

  @POST('/work_entry/user/entries')
  Future<CommonResponse> getListWorkEntry(@Body() Map<String, dynamic> body);

  @POST("/work_entry/send_invalid")
  Future<CommonResponse> sendInvalid(@Body() Map<String, dynamic> body);
  //
  @GET("/metadata/workflow_stages")
  Future<CommonResponse> getListWorkFlowStages();

  @GET("/metadata/workentry_types")
  Future<CommonResponse> getListWorkEntryTypes();

  @GET("/metadata/attendance_locations")
  Future<CommonResponse> getListWorkLocations();

  @POST("/attendance/check_in_out")
  Future<CommonResponse> userCheckInOut(@Body() FormData? body);

  @POST("/attendance/update_explanation")
  Future<dynamic> updateExplanation(@Body() Map<String, dynamic> body);

  @GET("/attendance/history")
  Future<CommonResponse> getListAttendanceHistory(
      @Query("date_from") String? dateFrom,
      @Query("date_to") String? dateTo,
      );

  //Quên mật khẩu
  @POST("/users/generate_otp")
  Future<CommonResponse> sendOTP(@Body() Map<String, dynamic> body);

  @POST("/users/verify_otp")
  Future<CommonResponse> verifyOtp(@Body() Map<String, dynamic> body);

  @POST("/users/get_notification")
  Future<CommonResponse> getNotification(@Body() Map<String, dynamic> body);

  @POST("/users/mark_notification_read")
  Future<CommonResponse> markNotiRead(@Body() Map<String, dynamic> body);
  
  // task
  // lay danh sach task
  @GET("/tasks/tasks")
  Future<CommonResponse> getListTask(
      @Query("name") String? name,
      @Query("stage_id") int? stageId,
      @Query("page") int? page,
      @Query("limit") int? limit,
      );

  // lay ds task stage
  @GET("/tasks/task_stages")
  Future<CommonResponse> getTaskStages();

  // update task stage
  @POST("/tasks/update_task_stage")
  Future<dynamic> updateTaskStage(@Body() Map<String, dynamic> body);

  @GET("/users/get_users")
  Future<CommonResponse> getListUser();

  @POST("/tasks/create_task")
  Future<CommonResponse> createTask(@Body() CreateTaskParam param);


  @GET("/tasks/detail_task/{id}")
  Future<CommonResponse> getDetailTask(@Path("id") int id);

  @POST("/tasks/delete_task")
  Future<dynamic> deleteTask(@Body() Map<String, dynamic> body);

  @POST("/tasks/update_task")
  Future<CommonResponse> updateTask(@Body() CreateTaskParam body);
}
