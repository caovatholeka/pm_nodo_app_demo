import 'package:json_annotation/json_annotation.dart';

part 'work_flow_stage_entity.g.dart';
@JsonSerializable()
class WorkFlowStageEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  WorkFlowStageEntity({
    this.id,
    this.code,
    this.name,
  });

  WorkFlowStageEntity copyWith({
    int? id,
    String? code,
    String? name,
  }) {
    return WorkFlowStageEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  factory WorkFlowStageEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkFlowStageEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WorkFlowStageEntityToJson(this);
}