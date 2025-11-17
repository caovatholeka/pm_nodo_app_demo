import 'package:json_annotation/json_annotation.dart';

part 'explanation_entity.g.dart';

@JsonSerializable()
class ExplanationEntity {
  @JsonKey()
  String? date;

  @JsonKey(name: "attendance_explanation")
  String? attendanceExplain;

  ExplanationEntity({
    this.date,
    this.attendanceExplain
  });

  ExplanationEntity copyWith({
    String? date,
    String? attendanceExplain,
  }) {
    return ExplanationEntity(
      date: date ?? this.date,
      attendanceExplain: attendanceExplain ?? this.attendanceExplain,
    );
  }

  factory ExplanationEntity.fromJson(Map<String, dynamic> json) =>
      _$ExplanationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ExplanationEntityToJson(this);
}