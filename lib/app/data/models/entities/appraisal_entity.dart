import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/response_entity.dart';
import 'package:pm_app/app/data/models/entities/suggest_entity.dart';
import 'package:pm_app/app/data/models/entities/task_line_entity.dart';

part 'appraisal_entity.g.dart';

@JsonSerializable()
class AppraisalEntity {
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

  @JsonKey(name: "date_from")
  String? dateFrom;

  @JsonKey(name: "date_to")
  String? dateTo;

  @JsonKey()
  String? note;

  @JsonKey()
  String? state;

  @JsonKey(name: "task_line_ids")
  List<TaskLineEntity>? taskLineIds;

  @JsonKey(name: "response_ids")
  List<ResponseEntity>? responseIds;

  @JsonKey(name: "suggest_ids")
  List<SuggestEntity>? suggestIds;

  AppraisalEntity({
    this.name,
    this.employeeId,
    this.employeeName,
    this.employeeCode,
    this.departmentId,
    this.departmentName,
    this.dateFrom,
    this.dateTo,
    this.note,
    this.state,
    this.taskLineIds,
    this.responseIds,
    this.suggestIds,
  });


  AppraisalEntity copyWith({
    String? name,
    int? employeeId,
    String? employeeName,
    String? employeeCode,
    int? departmentId,
    String? departmentName,
    String? dateFrom,
    String? dateTo,
    String? note,
    String? state,
    List<TaskLineEntity>? taskLineIds,
    List<ResponseEntity>? responseIds,
    List<SuggestEntity>? suggestIds,
  }) {
    return AppraisalEntity(
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      note: note ?? this.note,
      state: state ?? this.state,
      taskLineIds: taskLineIds ?? this.taskLineIds,
      responseIds: responseIds ?? this.responseIds,
      suggestIds: suggestIds ?? this.suggestIds,
    );
  }

  factory AppraisalEntity.fromJson(Map<String, dynamic> json) =>
      _$AppraisalEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AppraisalEntityToJson(this);
}