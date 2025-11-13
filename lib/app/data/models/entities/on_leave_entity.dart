import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/leave_day_entity.dart';
import 'package:pm_app/app/data/models/entities/user_approve_entity.dart';
import 'package:pm_app/app/data/models/entities/work_flow_stage_entity.dart';

part 'on_leave_entity.g.dart';

@JsonSerializable()
class OnLeaveEntity {
  @JsonKey()
  int? id;

  @JsonKey(name:"employee_id")
  int? employeeId;

  @JsonKey(name: "employee_name")
  String? employeeName;

  @JsonKey(name:"department_id")
  int? departmentId;

  @JsonKey(name:"department_name")
  String? departmentName;

  @JsonKey(name:"date_from")
  String? dateFrom;

  @JsonKey(name:"date_to")
  String? dateTo;

  @JsonKey(name:"holiday_status")
  String? holidayStatus;

  @JsonKey(name:"holiday_status_id")
  int? holidayStatusId;

  @JsonKey(name:"leave_stage")
  WorkFlowStageEntity? leaveStage;

  @JsonKey()
  String? description;

  @JsonKey(name:"duration_display")
  String? durationDisplay;

  @JsonKey(name:"remain_leave")
  int? remainLeave;

  @JsonKey(name:"user_approve")
  UserApproveEntity? userApprove;

  @JsonKey()
  String? state;

  @JsonKey(name: "line_ids")
  List<LeaveDayEntity>? lineIds;

  @JsonKey()
  int? status;

  OnLeaveEntity({
    this.id,
    this.employeeId,
    this.employeeName,
    this.departmentId,
    this.departmentName,
    this.dateFrom,
    this.dateTo,
    this.holidayStatus,
    this.holidayStatusId,
    this.leaveStage,
    this.description,
    this.durationDisplay,
    this.remainLeave,
    this.userApprove,
    this.state,
    this.status
  });

  OnLeaveEntity copyWith({
    int? id,
    int? employeeId,
    String? employeeName,
    int? departmentId,
    String? departmentName,
    String? dateFrom,
    String? dateTo,
    String? holidayStatus,
    int? holidayStatusId,
    WorkFlowStageEntity? leaveStage,
    String? description,
    String? durationDisplay,
    int? remainLeave,
    UserApproveEntity? userApprove,
    String? state,
    int? status
  }) {
    return OnLeaveEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      holidayStatus: holidayStatus ?? this.holidayStatus,
      holidayStatusId: holidayStatusId ?? this.holidayStatusId,
      leaveStage: leaveStage ?? this.leaveStage,
      description: description ?? this.description,
      durationDisplay: durationDisplay ?? this.durationDisplay,
      remainLeave: remainLeave ?? this.remainLeave,
      userApprove: userApprove ?? this.userApprove,
      state: state ?? this.state,
      status: status ?? this.status
    );
  }

  factory OnLeaveEntity.fromJson(Map<String, dynamic> json) => _$OnLeaveEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OnLeaveEntityToJson(this);
}