import 'package:json_annotation/json_annotation.dart';

part 'leave_day_entity.g.dart';

@JsonSerializable()
class LeaveDayEntity {
  @JsonKey()
  String? date;

  @JsonKey()
  String? type;

  LeaveDayEntity({
    this.date,
    this.type
  });

  LeaveDayEntity copyWith({
    String? date,
    String? type,
  }) {
    return LeaveDayEntity(
        date: date ?? this.date,
        type: type ?? this.type,
    );
  }

  factory LeaveDayEntity.fromJson(Map<String, dynamic> json) => _$LeaveDayEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveDayEntityToJson(this);

}