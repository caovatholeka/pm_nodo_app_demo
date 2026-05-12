import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/responsive_id_entity.dart';
import 'package:pm_app/app/data/models/entities/skill_entity.dart';
import 'package:pm_app/app/data/models/entities/suggest_id_entity.dart';
import 'package:pm_app/app/data/models/entities/task_line_entity.dart';

part 'evaluation_asess_entity.g.dart';

@JsonSerializable()
class EvaluationAsessEntity {
  @JsonKey(name:"task_line_ids")
  List<TaskLineEntity>? taskLineIds;

  @JsonKey(name:"response_ids")
  List<ResponsiveIdEntity>? responseIds;

  @JsonKey(name:"skill_ids")
  List<SkillEntity>? skillIds;

  @JsonKey(name:"suggest_ids")
  List<SuggestIdEntity>? suggestIds;

  EvaluationAsessEntity({
    this.taskLineIds,
    this.responseIds,
    this.skillIds,
    this.suggestIds,
  });

  EvaluationAsessEntity copyWith({
    List<TaskLineEntity>? taskLineIds,
    List<ResponsiveIdEntity>? responseIds,
    List<SkillEntity>? skillIds,
    List<SuggestIdEntity>? suggestIds,
  }) {
    return EvaluationAsessEntity(
      taskLineIds: taskLineIds ?? this.taskLineIds,
      responseIds: responseIds ?? this.responseIds,
      skillIds: skillIds ?? this.skillIds,
      suggestIds: suggestIds ?? this.suggestIds,
    );
  }

  factory EvaluationAsessEntity.fromJson(Map<String, dynamic> json) =>
      _$EvaluationAsessEntityFromJson(json);
  Map<String, dynamic> toJson() => _$EvaluationAsessEntityToJson(this);

}