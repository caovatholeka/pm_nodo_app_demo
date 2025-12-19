import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/exception_line_entity.dart';
import 'package:pm_app/app/data/models/entities/overtime_detail_entity.dart';
import 'package:pm_app/app/data/models/entities/overtime_line_entity.dart';
import 'package:pm_app/app/data/models/entities/work_flow_stage_entity.dart';

part 'overtime_entity.g.dart';

@JsonSerializable()
class OvertimeEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  @JsonKey(name: "employee_id")
  int? employeeId;

  @JsonKey(name: "employee_name")
  String? employeeName;

  @JsonKey(name: "employee_code")
  String? employeeCode;

  @JsonKey(name: "department_id")
  int? departmentId;

  @JsonKey(name: "department_name")
  String? departmentName;

  @JsonKey(name: "date_create")
  String? dateCreate;

  @JsonKey(name: "from_date")
  String? fromDate;

  @JsonKey(name: "to_date")
  String? toDate;

  @JsonKey()
  String? note;

  @JsonKey(name: "reason_cancel")
  String? reasonCancel;

  @JsonKey()
  WorkFlowStageEntity? stage;

  @JsonKey(name: "overtime_detail")
  List <OvertimeDetailEntity>? overtimeDetail;
  
  @JsonKey(name: 'overtime_lines')
  List<OvertimeLineEntity>? overtimeLines;

  OvertimeEntity({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.departmentId,
    required this.departmentName,
    required this.stage,
    required this.overtimeDetail,
    required this.overtimeLines
  });

  factory OvertimeEntity.fromJson(Map<String, dynamic> json) =>
      _$OvertimeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OvertimeEntityToJson(this);
}
