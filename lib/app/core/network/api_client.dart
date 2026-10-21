import 'package:dio/dio.dart';
import 'package:pm_app/app/data/models/entities/attendance_entity.dart';
import 'package:pm_app/app/data/models/entities/checkpoint_entity.dart';
import 'package:pm_app/app/data/models/entities/discipline_evaluation_detail_entity.dart';
import 'package:pm_app/app/data/models/entities/discipline_evaluation_entity.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/entities/evaluation_asess_entity.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/entities/work_quality_entity.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/data/models/param/approve_ob_param.dart';
import 'package:pm_app/app/data/models/param/cancel_ob_param.dart';
import 'package:pm_app/app/data/models/param/cancel_ot_param.dart';
import 'package:pm_app/app/data/models/param/create_task_param.dart';

import 'package:pm_app/app/data/models/param/create_work_trip_param.dart';
import 'package:pm_app/app/data/models/param/justification_approve_param.dart';
import 'package:pm_app/app/data/models/param/justification_cancel_param.dart';
import 'package:pm_app/app/data/models/param/leave_approve_param.dart';
import 'package:pm_app/app/data/models/param/leave_reject_param.dart';
import 'package:pm_app/app/data/models/param/ot_approve_param.dart';
import 'package:pm_app/app/data/models/param/send_suggestion_param.dart';
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
    @Query("scope") String? scope,
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

  // ca được phân trong ngày (YYYY-MM-DD) của nhân viên đang đăng nhập
  @GET("/metadata/shift_as_day")
  Future<CommonResponse> getShiftAsDay(@Query("date") String date);

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
  Future<CommonResponse> getAttendanceList(
    @Queries() Map<String, dynamic>? params,
  );

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
  Future<CommonResponse> getListOT(@Queries() Map<String, dynamic>? params);

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
  Future<CommonResponse> getListBusinessTrip(
    @Query("limit") int? limit,
    @Query("page") int? page,
    @Query("start_date") String? startDate,
    @Query("end_date") String? endDate,
  );

  // tao phiếu công tác
  @POST("/going_on_business/going_on_business_create")
  Future<WorkTripResponse> createBusinessTrip(@Body() CreateWorkTripParam body);

  // chi tiet phieu ct
  @GET("/going_on_business/going_on_business_detail/{id}")
  Future<WorkTripEntity> getDetailWorkTrip(@Path("id") int id);

  // gui duyet
  @POST("/going_on_business/going_on_business_submit/{id}")
  Future<CommonResponse> submitWorkTrip(
    @Body() CreateWorkTripParam body,
    @Path("id") int id,
  );

  // xoa
  @DELETE("/going_on_business/going_on_business_delete/{id}")
  Future<CommonResponse> deleteWorkTrip(@Path("id") int id);

  // update
  @PUT("/going_on_business/going_on_business_update/{id}")
  Future<WorkTripResponse> updateWorkTrip(
    @Body() CreateWorkTripParam body,
    @Path("id") int id,
  );

  //Phê duyệt đơn nghỉ
  @POST("/leave/hr_leave/approve")
  Future<CommonResponse> approveLeave(@Body() LeaveApproveParam body);

  //Hủy đơn nghỉ
  @POST("/leave/hr_leave/{id}/cancel")
  Future<CommonResponse> cancelLeave(
    @Path("id") int id,
    @Body() LeaveRejectParam body,
  );

  //Duyệt đơn OT
  @POST("/overtime/overtime/approve")
  Future<CommonResponse> approveOT(@Body() OtApproveParam body);

  @POST("/overtime/overtime/{id}/cancel")
  Future<CommonResponse> cancelOT(
    @Path("id") int id,
    @Body() CancelOtParam body,
  );

  //Duyệt đơn công tác
  @POST('/going_on_business/going_on_business/approve')
  Future<CommonResponse> approveOB(@Body() ApproveObParam body);

  //Hủy đơn công tác
  @POST('/going_on_business/going_on_business/{id}/cancel')
  Future<CommonResponse> cancelOB(
    @Path("id") int id,
    @Body() CancelObParam body,
  );

  //Duyệt đơn M/S
  @POST('/attendance_exception/attendance_exception/approve')
  Future<CommonResponse> approveJustification(
    @Body() JustificationApproveParam body,
  );

  //Hủy đơn M/S
  @POST('/attendance_exception/attendance_exception/{id}/cancel')
  Future<CommonResponse> cancelJustification(
    @Path("id") int id,
    @Body() JustificationCancelParam body,
  );

  // danh gia cong viec
  @GET("/evaluation/evaluation_list")
  Future<CommonResponse> getListEvaluation(
    @Query("date_from") String? dateFrom,
    @Query("date_to") String? dateTo,
    @Query("limit") int? limit,
    @Query("page") int? page,
  );

  @GET("/evaluation/evaluation_detail/{id}")
  Future<EvaluationEntity> getDetailEvaluation(@Path("id") int id);

  @POST("/evaluation/evaluation_create")
  Future<CommonResponse> createEvaluation(@Body() EvaluationEntity body);

  @PUT("/evaluation/evaluation_update/{id}")
  Future<dynamic> updateEvaluation(
    @Path("id") int id,
    @Body() Map<String, dynamic> body,
  );

  // thống kê đơn từ
  @GET('/dashboard/request_summary')
  Future<CommonResponse> getRequestSumaries();

  // ── Dashboard v2: đồng bộ với Dashboard web (số liệu từ chính các hàm của web) ──
  // Đơn từ cá nhân trong tháng
  @GET('/dashboard/request_summary')
  Future<dynamic> getDashboardRequests(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  // Đơn cần duyệt cho nhân sự trong tháng
  @GET('/dashboard/pending_summary')
  Future<dynamic> getDashboardPending(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  // Nề nếp chấm công
  @GET('/dashboard/discipline_evaluation')
  Future<dynamic> getDashboardBehaviour(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  // Cảnh báo chuyên cần trong tháng
  @GET('/dashboard/timesheet_data')
  Future<dynamic> getDashboardAlerts(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  // Sinh nhật trong tháng
  @GET('/dashboard/birthdays_this_month')
  Future<dynamic> getDashboardBirthdays(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  // Tổng quan nhân sự
  @GET('/dashboard/headcount')
  Future<dynamic> getDashboardHeadcount();
  // thống kê chất lượng công việc
  @GET('/dashboard/work_quality')
  Future<WorkQualityEntity> getWorkQuality(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  // chi tiết chất lượng công việc
  @GET('/dashboard/work_quality_detail')
  Future<WorkQualityEntity> getWorkQualityDetail(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  //Thống kê dữ liệu chấm công
  @GET('/dashboard/timesheet_data')
  Future<dynamic> getTimeSheetData(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  // thống kê sinh nhật trong tháng
  @GET('/dashboard/birthdays_this_month')
  Future<dynamic> getBirthdaysThisMonth(@Query("month") int? month);

  //Thống kê nề nếp
  @GET('/dashboard/discipline_evaluation')
  Future<DisciplineEvaluationEntity> getDisciplineEvaluation(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  //thống kê chi tiết nề nếp
  @GET('/dashboard/discipline_evaluation_detail')
  Future<DisciplineEvaluationDetailEntity> getDetailDisciplineEvaluation(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  //Lấy chi tiết dự án
  @GET('/dashboard/project_tasks')
  Future<dynamic> getProjectTasks(@Query("project_id") int? projectId);

  //Lấy dự án
  @GET('/dashboard/projects')
  Future<dynamic> getProjects();

  //Đề xuất cải thiện
  @POST('/dashboard/improvement_suggestion')
  Future<CommonResponse> submitImprovemnt(@Body() SendSuggestionParam body);

  //Gửi duyệt QLTT
  @POST('/evaluation/evaluation_submit/{id}')
  Future<CommonResponse> submitEvaluation(@Path("id") int id);

  //Gửi duyệt HR
  @POST('/evaluation/evaluation_assess/{id}')
  Future<EvaluationAsessEntity> assessEvaluation(
    @Path("id") int id,
    @Body() Map<String, dynamic> body,
  );

  //HR duyệt hoàn thành
  @POST('/evaluation/evaluation_approve/{id}')
  Future<CommonResponse> approvedEvaluation(@Path("id") int id,);

  //List checkpoint
  @GET('/checkpoint/checkpoint_list')
  Future<CommonResponse> getListCP(
    @Query("date_from") String? dateFrom,
    @Query("date_to") String? dateTo,
  );

  //Thêm checkpoint
  @POST('/checkpoint/checkpoint_create')
  Future<CheckpointEntity> createCheckpoint(@Body() CheckpointEntity body);

  //Sửa CP
  @PUT('/checkpoint/checkpoint_update/{id}')
  Future<CheckpointEntity> updateCheckpoint(
    @Path("id") int id,
    @Body() CheckpointEntity body,
  );

  //Chi tiết CP
  @GET('/checkpoint/checkpoint_detail/{id}')
  Future<CheckpointEntity> getDetailCheckpoint(@Path("id") int id);

  //Gửi duyệt CP
  @POST('/checkpoint/checkpoint_submit/{id}')
  Future<CheckpointEntity> submitCheckpoint(@Path("id") int id);

  //Gửi duyệt HR
  @POST('/checkpoint/checkpoint_assess/{id}')
  Future<CheckpointEntity> assessCheckpoint(
    @Path("id") int id,
    @Body() CheckpointEntity body,
  );

  @POST('/checkpoint/checkpoint_hr_approve/{id}')
  Future<CheckpointEntity> hrApproveCheckpoint(
    @Path("id") int id,
    @Body() CheckpointEntity body
  );
}
