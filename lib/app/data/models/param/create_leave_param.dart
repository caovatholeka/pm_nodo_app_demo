import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/leave_day_entity.dart';

part 'create_leave_param.g.dart';

@JsonSerializable()
class UpdateOnLeaveParam {
  @JsonKey(name: "employee_id")
  int? employeeId;

  @JsonKey(name: "holiday_status_id")
  int? holidayStatusId;

  @JsonKey(name: "department_id")
  int? departmentId;

  @JsonKey(name: "request_date_from")
  String? requestDateFrom;

  @JsonKey(name: "request_date_to")
  String? requestDateTo;

  @JsonKey()
  String? name;

  @JsonKey(name:"leave_days")    
  List<LeaveDayEntity>? leaveDays;

  UpdateOnLeaveParam({
    this.employeeId,
    this.holidayStatusId,
    this.departmentId,
    this.requestDateFrom,
    this.requestDateTo,
    this.name,
    this.leaveDays
  });

UpdateOnLeaveParam copyWith({
  int? employeeId,
  int? holidayStatusId,
  int? departmentId,
  String? requestDateFrom,
  String? requestDateTo,
  String? name,
  List<LeaveDayEntity>? leaveDays,
  }) {
    return UpdateOnLeaveParam(
      employeeId: employeeId ?? this.employeeId,
      holidayStatusId: holidayStatusId ?? this.holidayStatusId,
      departmentId: departmentId ?? this.departmentId,
      requestDateFrom: requestDateFrom ?? this.requestDateFrom,
      requestDateTo: requestDateTo ?? this.requestDateTo,
      name: name ?? this.name,
      leaveDays: leaveDays ?? this.leaveDays
    );
  }

  factory UpdateOnLeaveParam.fromJson(Map<String, dynamic> json) => _$UpdateOnLeaveParamFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateOnLeaveParamToJson(this);
}