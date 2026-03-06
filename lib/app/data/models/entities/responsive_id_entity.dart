import 'package:json_annotation/json_annotation.dart';

part 'responsive_id_entity.g.dart';
@JsonSerializable()
class ResponsiveIdEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  @JsonKey()
  String? note;

  @JsonKey(name: "rate_point")
  dynamic ratePoint;

  @JsonKey(name: "parent_rate_point")
  dynamic parentRatePoint;

  @JsonKey(name: "parent_note")
  String? parentNote;

  ResponsiveIdEntity({
    this.id,
    this.code,
    this.name,
    this.note,
    this.ratePoint,
    this.parentRatePoint,
    this.parentNote
  });

  ResponsiveIdEntity copyWith({
    int? id,
    String? code,
    String? name,
    String? note,
    dynamic ratePoint,
    dynamic parentRatePoint,
    String? parentNote
  }) {
    return ResponsiveIdEntity(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        note: note ?? this.note,
        ratePoint: ratePoint ?? this.ratePoint,
        parentRatePoint: parentRatePoint ?? this.parentRatePoint,
        parentNote: parentNote ?? this.parentNote
    );
  }

  factory ResponsiveIdEntity.fromJson(Map<String, dynamic> json) =>
      _$ResponsiveIdEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ResponsiveIdEntityToJson(this);
}