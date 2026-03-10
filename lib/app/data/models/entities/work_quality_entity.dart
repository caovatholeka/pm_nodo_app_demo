import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/task_evaluation_entity.dart';

part 'work_quality_entity.g.dart';

@JsonSerializable()
class WorkQualityEntity {
  @JsonKey()
  String? month;

  @JsonKey(name: "employee_id")
  int? employeeId;

  @JsonKey(name: "employee_name")
  String? employeeName;

  @JsonKey(name: "volume_score")
  int? volumeScore;

  @JsonKey(name: "progress_score")
  int? progressScore;

  @JsonKey(name: "quality_score")
  int? qualityScore;

  @JsonKey(name: "task_evaluations")
  List<TaskEvaluationEntity>? taskEvaluations;

  WorkQualityEntity({
    this.month,
    this.employeeId,
    this.employeeName,
    this.volumeScore,
    this.progressScore,
    this.qualityScore,
    this.taskEvaluations
  });

  WorkQualityEntity copyWith({
    String? month,
    int? employeeId,
    String? employeeName,
    int? volumeScore,
    int? progressScore,
    int? qualityScore,
    List<TaskEvaluationEntity>? taskEvaluations
  }) {
    return WorkQualityEntity(
      month: month ?? this.month,
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
      volumeScore: volumeScore ?? this.volumeScore,
      progressScore: progressScore ?? this.progressScore,
      qualityScore: qualityScore ?? this.qualityScore,
      taskEvaluations: taskEvaluations ?? this.taskEvaluations
    );
  }

  factory WorkQualityEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkQualityEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WorkQualityEntityToJson(this);
}