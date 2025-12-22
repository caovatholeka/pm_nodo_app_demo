import 'package:json_annotation/json_annotation.dart';

part 'schedule_entity.g.dart';
@JsonSerializable()
class ScheduleEntity {
  @JsonKey(name: "date_from")
  String? dateFrom;

  @JsonKey(name: "date_to")
  String? dateTo;

  @JsonKey()
  String? address;

  @JsonKey()
  String? type;

  @JsonKey(name: "is_overnight")
  bool? isOvernight;

  @JsonKey(name: "keep_lunch_allowance")
  bool? keepLunchAllowance;

  ScheduleEntity({
    this.dateFrom,
    this.dateTo,
    this.address,
    this.type,
    this.isOvernight,
    this.keepLunchAllowance
  });

  ScheduleEntity copyWith({
    String? dateFrom,
    String? dateTo,
    String? address,
    String? type,
    bool? isOvernight,
    bool? keepLunchAllowance
  }) {
    return ScheduleEntity(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      address: address ?? this.address,
      type: type ?? this.type,
      isOvernight: isOvernight ?? this.isOvernight,
      keepLunchAllowance: keepLunchAllowance ?? this.keepLunchAllowance
    );
  }

  factory ScheduleEntity.fromJson(Map<String, dynamic> json) =>
      _$ScheduleEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleEntityToJson(this);
}