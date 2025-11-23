import 'package:json_annotation/json_annotation.dart';

part 'task_stage_entity.g.dart';

@JsonSerializable()
class TaskStageEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  TaskStageEntity({
    this.id,
    this.code,
    this.name,
  });

  TaskStageEntity copyWith({
    int? id,
    String? code,
    String? name,
  }) {
    return TaskStageEntity(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
    );
  }

  factory TaskStageEntity.fromJson(Map<String, dynamic> json) => _$TaskStageEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskStageEntityToJson(this);
}