import 'package:dio/dio.dart';
import 'package:pm_app/app/data/models/entities/attendance_entity.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/data/models/param/create_task_param.dart';
import 'package:pm_app/app/features/ui/overtime/overtime_detail.dart';
import 'package:pm_app/app/data/models/param/create_work_trip_param.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/entities/face_search_response_entity.dart';
import '../../data/models/entities/file_entity.dart';
import '../../data/models/param/create_leave_param.dart';
import '../../data/models/response/common_response.dart';
import '../../data/models/response/on_leave_response.dart';
import '../../data/models/response/work_trip_response.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {required String baseUrl}) = _ApiClient;

  @POST('/api/v1/faces/search-face')
  Future<FaceSearchResponseEntity> searchFaceEmployee(@Body() FormData? body);

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
    @Query("state") String? active,
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
  Future<CommonResponse> getDetailWorkEntry(
    @Query("attendance_id") int? attendanceId,
  );

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

  // notification
  @POST("/users/get_notification")
  Future<CommonResponse> getNotification(@Body() Map<String, dynamic> body);

  @POST("/users/mark_notification_read")
  Future<CommonResponse> markNotiRead(
    @Body() Map<String, dynamic> body,
    @Query("noti_id") int notiId,
  );

  @GET("/users/count_unread_notifications")
  Future<CommonResponse> countUnreadNoti();

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

  //attendance exception (gửi giải trình)
  @GET("/attendance_exception/attendance_exception_list")
  Future<CommonResponse> getAttendanceList();

  @GET("/attendance_exception/attendance_exception_detail/{id}")
  Future<JustificationEntity> getDetailAttendance(@Path("id") int id);

  @POST("/attendance_exception/attendance_exception_create")
  Future<CommonResponse> createAttendance(@Body() Map<String, dynamic> body);

  @PUT('/attendance_exception/attendance_exception/{id}')
  Future<dynamic> updateAttendance(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @POST("/attendance_exception/attendance_exception_submit/{id}")
  Future<JustificationEntity> submitAttendance(@Path("id") int id);

  @DELETE('/attendance_exception/attendance_exception_delete/{id}')
  Future<dynamic> deleteAttendance(@Path("id") int id);

  //OT
  @GET("/overtime/overtime_list")
  Future<CommonResponse> getListOT();

  @GET("/overtime/overtime_detail/{id}")
  Future<OvertimeEntity> getDetailOT(@Path("id") int id);

  @POST("/overtime/overtime_create")
  Future<CommonResponse> createOTRequest(@Body() Map<String, dynamic> body);

  @PUT("/overtime/overtime_update/{id}")
  Future<dynamic> updateOTRequest(
    @Path("id") int id,
    @Body() Map<String, dynamic> body,
  );

  @POST("/overtime/overtime_submit/{id}")
  Future<OvertimeEntity> submitOT(@Path("id") int id);

  @DELETE('/overtime/overtime_delete/{id}')
  Future<dynamic> deleteOTRequest(@Path("id") int id);
  ///Upload files
  @POST("")
  Future<List<FileEntity>> uploadFiles(@Body() FormData? body);

  // danh sach cong tac
  @GET("/going_on_business/going_on_business_list")
  Future<CommonResponse> getListBusinessTrip();

  // tao phiếu công tác
  @POST("/going_on_business/going_on_business_create")
  Future<WorkTripResponse> createBusinessTrip(@Body() CreateWorkTripParam body);

  // chi tiet phieu ct
  @GET("/going_on_business/going_on_business_detail/{id}")
  Future<WorkTripEntity> getDetailWorkTrip(@Path("id") int id);

  // gui duyet
  @POST("/going_on_business/going_on_business_submit/{id}")
  Future<CommonResponse> submitWorkTrip(@Body() CreateWorkTripParam body,@Path("id") int id);

  // xoa
  @DELETE("/going_on_business/going_on_business_delete/{id}")
  Future<CommonResponse> deleteWorkTrip(@Path("id") int id);

  // update
  @PUT("/going_on_business/going_on_business_update/{id}")
  Future<WorkTripResponse> updateWorkTrip(@Body() CreateWorkTripParam body, @Path("id") int id);
}
