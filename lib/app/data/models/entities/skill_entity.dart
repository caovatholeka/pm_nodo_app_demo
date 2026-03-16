import 'package:json_annotation/json_annotation.dart';

part 'skill_entity.g.dart';

@JsonSerializable()
class SkillEntity {
  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  @JsonKey(name: "rate_point")
  dynamic ratePoint;

  @JsonKey(name: "parent_rate_point")
  dynamic parentRatePoint;

  @JsonKey()
  String? note;

  @JsonKey(name: "parent_note")
  String? parentNote;

  SkillEntity({
    this.code,
    this.name,
    this.ratePoint,
    this.parentRatePoint,
    this.note,
    this.parentNote,
  });

  SkillEntity copyWith({
    String? code,
    String? name,
    dynamic ratePoint,
    dynamic parentRatePoint,
    String? note,
    String? parentNote,
  }) {
    return SkillEntity(
      code: code ?? this.code,
      name: name ?? this.name,
      ratePoint: ratePoint ?? this.ratePoint,
      parentRatePoint: parentRatePoint ?? this.parentRatePoint,
      note: note ?? this.note,
      parentNote: parentNote ?? this.parentNote,
    );
  } 

  factory SkillEntity.fromJson(Map<String, dynamic> json) =>
      _$SkillEntityFromJson(json);
      
  Map<String, dynamic> toJson() => _$SkillEntityToJson(this);
}
