import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/exception_line_entity.dart';
import 'package:pm_app/app/data/models/entities/work_flow_stage_entity.dart';

part 'justification_entity.g.dart';

@JsonSerializable()
class JustificationEntity {
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

  @JsonKey(name:"department_name")
  String? departmentName;

  @JsonKey()
  String? date;

  @JsonKey()
  String? note;

  @JsonKey(name: "reason_type")
  String? reasonType;

  @JsonKey()
  WorkFlowStageEntity? stage;

  @JsonKey(name:"exception_lines")
  List<ExceptionLineEntity>? exceptionLines;

  

  JustificationEntity({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.departmentId,
    required this.departmentName,
    required this.date,
    required this.note,
    required this.reasonType,
    required this.stage,
    required this.exceptionLines,
  });

  factory JustificationEntity.fromJson(Map<String, dynamic> json) =>
      _$JustificationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$JustificationEntityToJson(this);
}
