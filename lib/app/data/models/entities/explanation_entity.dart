import 'package:json_annotation/json_annotation.dart';

part 'explanation_entity.g.dart';

@JsonSerializable()
class ExplanationEntity {
  @JsonKey()
  String? date;

  @JsonKey()
  String? action;

  @JsonKey()
  String? datetime;

  @JsonKey(name: "attendance_explanation")
  String? attendanceExplain;

  @JsonKey(name: "is_late")
  bool? isLate;

  @JsonKey(name: "is_early")
  bool? isEarly;

  ExplanationEntity({
    this.date,
    this.attendanceExplain,
    this.action,
    this.datetime,
    this.isLate,
    this.isEarly
  });

  ExplanationEntity copyWith({
    String? date,
    String? attendanceExplain,
    String? action,
    String? datetime,
    bool? isLate,
    bool? isEarly
  }) {
    return ExplanationEntity(
      date: date ?? this.date,
      attendanceExplain: attendanceExplain ?? this.attendanceExplain,
      action: action ?? this.action,
      datetime: datetime ?? this.datetime,
      isLate: isLate,
      isEarly: isEarly
    );
  }

  factory ExplanationEntity.fromJson(Map<String, dynamic> json) =>
      _$ExplanationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ExplanationEntityToJson(this);
}