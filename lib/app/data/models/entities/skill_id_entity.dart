import 'package:json_annotation/json_annotation.dart';

part 'skill_id_entity.g.dart';
@JsonSerializable()
class SkillIdEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  @JsonKey()
  String? note;

  @JsonKey(name: "rate_point")
  bool? ratePoint;

  @JsonKey(name: "parent_rate_point")
  bool? parentRatePoint;

  @JsonKey(name: "parent_note")
  String? parentNote;

  SkillIdEntity({
    this.id,
    this.code,
    this.name,
    this.note,
    this.ratePoint,
    this.parentRatePoint,
    this.parentNote
  });

  SkillIdEntity copyWith({
    int? id,
    String? code,
    String? name,
    String? note,
    bool? ratePoint,
    bool? parentRatePoint,
    String? parentNote
  }) {
    return SkillIdEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.note,
      ratePoint: ratePoint ?? this.ratePoint,
      parentRatePoint: parentRatePoint ?? this.parentRatePoint,
      parentNote: parentNote ?? this.parentNote
    );
  }

  factory SkillIdEntity.fromJson(Map<String, dynamic> json) =>
      _$SkillIdEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SkillIdEntityToJson(this);
}