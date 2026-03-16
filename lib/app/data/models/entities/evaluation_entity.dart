import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/responsive_id_entity.dart';
import 'package:pm_app/app/data/models/entities/skill_id_entity.dart';
import 'package:pm_app/app/data/models/entities/suggest_id_entity.dart';
import 'package:pm_app/app/data/models/entities/task_line_id_entity.dart';

part 'evaluation_entity.g.dart';
@JsonSerializable()
class EvaluationEntity {
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

  @JsonKey(name: "date_from")
  String? dateFrom;

  @JsonKey(name: "date_to")
  String? dateTo;

  @JsonKey()
  String? note;

  @JsonKey()
  String? state;

  @JsonKey(name: "total_task_score")
  dynamic totalTaskScore;

  @JsonKey(name: "total_parent_task_score")
  dynamic totalParentTaskScore;

  @JsonKey(name: "response_total_score")
  dynamic responseTotalScore;

  @JsonKey(name: "response_parent_total_score")
  dynamic responseParentTotalScore;

  @JsonKey(name: "skill_total_score")
  dynamic skillTotalScore;

  @JsonKey(name: "skill_parent_total_score")
  dynamic skillParentTotalScore;

  @JsonKey(name: "task_line_ids")
  List<TaskLineIdEntity>? taskLineIds;

  @JsonKey(name: "response_ids")
  List<ResponsiveIdEntity>? responseIds;

  @JsonKey(name: "skill_ids")
  List<SkillIdEntity>? skillIds;

  @JsonKey(name: "suggest_ids")
  List<SuggestIdEntity>? suggestIds;


  EvaluationEntity({
    this.id,
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
    this.totalTaskScore,
    this.totalParentTaskScore,
    this.responseTotalScore,
    this.responseParentTotalScore,
    this.skillTotalScore,
    this.skillParentTotalScore,
    this.taskLineIds,
    this.responseIds,
    this.skillIds,
    this.suggestIds
  });

  EvaluationEntity copyWith({
    int? id,
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
    dynamic totalTaskScore,
    dynamic totalParentTaskScore,
    dynamic responseTotalScore,
    dynamic responseParentTotalScore,
    dynamic skillTotalScore,
    dynamic skillParentTotalScore,
    List<TaskLineIdEntity>? taskLineIds,
    List<ResponsiveIdEntity>? responseIds,
    List<SkillIdEntity>? skillIds,
    List<SuggestIdEntity>? suggestIds
  }) {
    return EvaluationEntity(
        id: id ?? this.id,
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
        totalTaskScore: totalTaskScore ?? this.totalTaskScore,
        totalParentTaskScore: totalParentTaskScore ?? this.totalParentTaskScore,
        responseTotalScore: responseTotalScore ?? this.responseTotalScore,
        responseParentTotalScore:
            responseParentTotalScore ?? this.responseParentTotalScore,
        skillTotalScore: skillTotalScore ?? this.skillTotalScore,
        skillParentTotalScore:
            skillParentTotalScore ?? this.skillParentTotalScore,
        taskLineIds: taskLineIds ?? this.taskLineIds,
        responseIds: responseIds ?? this.responseIds,
        skillIds: skillIds ?? this.skillIds,
        suggestIds: suggestIds ?? this.suggestIds
    );
  }

  factory EvaluationEntity.fromJson(Map<String, dynamic> json) =>
      _$EvaluationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EvaluationEntityToJson(this);
}
