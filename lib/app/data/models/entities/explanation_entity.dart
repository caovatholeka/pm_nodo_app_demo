import 'package:json_annotation/json_annotation.dart';

import 'check_in_info_entity.dart';

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

  @JsonKey()
  CheckInInfoEntity? location;

  @JsonKey(name: "is_late")
  bool? isLate;

  @JsonKey(name: "is_early")
  bool? isEarly;

  // Id lượt chấm (biometric.data) — dùng để khớp lượt vừa chấm với lịch sử
  @JsonKey()
  int? id;

  ExplanationEntity({
    this.id,
    this.date,
    this.attendanceExplain,
    this.location,
    this.action,
    this.datetime,
    this.isLate,
    this.isEarly
  });

  ExplanationEntity copyWith({
    int? id,
    String? date,
    String? attendanceExplain,
    CheckInInfoEntity? location,
    String? action,
    String? datetime,
    bool? isLate,
    bool? isEarly
  }) {
    return ExplanationEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      attendanceExplain: attendanceExplain ?? this.attendanceExplain,
      action: action ?? this.action,
      location: location ?? this.location,
      datetime: datetime ?? this.datetime,
      isLate: isLate,
      isEarly: isEarly
    );
  }

  factory ExplanationEntity.fromJson(Map<String, dynamic> json) =>
      _$ExplanationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ExplanationEntityToJson(this);
}