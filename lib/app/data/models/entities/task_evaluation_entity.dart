import 'package:json_annotation/json_annotation.dart';

part 'task_evaluation_entity.g.dart';

@JsonSerializable()
class TaskEvaluationEntity {
  @JsonKey()
  int? id;

  @JsonKey(name: "task_name")
  String? taskName;

  @JsonKey(name: "project_id")
  int? projectId;

  @JsonKey(name: "project_name")
  String? projectName;

  @JsonKey(name: "project_logo")
  String? projectLogo;

  @JsonKey(name: "evaluator_id")
  int? evaluatorId;

  @JsonKey(name: "evaluator_name")
  String? evaluatorName;

  @JsonKey(name: "evaluation_date")
  String? evaluationDate;

  @JsonKey(name: "feedback")
  String? feedback;

  @JsonKey(name: "assigned_employee_id")
  int? assignedEmployeeId;

  @JsonKey(name: "assigned_employee_name")
  String? assignedEmployeeName;

  @JsonKey(name: "execution_hours")
  int? executionHours;

  @JsonKey(name: "tags")
  List<String>? tags;

  TaskEvaluationEntity({
    this.id,
    this.taskName,
    this.projectId,
    this.projectName,
    this.projectLogo,
    this.evaluatorId,
    this.evaluatorName,
    this.evaluationDate,
    this.feedback,
    this.assignedEmployeeId,
    this.assignedEmployeeName,
    this.executionHours,
    this.tags
  });

  TaskEvaluationEntity copyWith({
    int? id,
    String? taskName,
    int? projectId,
    String? projectName,
    String? projectLogo,
    int? evaluatorId,
    String? evaluatorName,
    String? evaluationDate,
    String? feedback,
    int? assignedEmployeeId,
    String? assignedEmployeeName,
    int? executionHours,
    List<String>? tags
  }) {
    return TaskEvaluationEntity(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      projectId: projectId ?? this.projectId,

      projectName: projectName ?? this.projectName,
      projectLogo: projectLogo ?? this.projectLogo,
      evaluatorId: evaluatorId ?? this.evaluatorId,

      evaluatorName: evaluatorName ?? this.evaluatorName,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      feedback: feedback ?? this.feedback,

      assignedEmployeeId: assignedEmployeeId ?? this.assignedEmployeeId,
      assignedEmployeeName: assignedEmployeeName ?? this.assignedEmployeeName,
      executionHours: executionHours ?? this.executionHours,
      tags: tags ?? this.tags,

    );
  }

  factory TaskEvaluationEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskEvaluationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskEvaluationEntityToJson(this);
}