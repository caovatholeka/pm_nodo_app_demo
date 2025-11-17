import 'package:json_annotation/json_annotation.dart';

part 'shift_flag_entity.g.dart';
@JsonSerializable()
class ShiftFlagEntity {
  @JsonKey(name: "has_shift")
  bool? hasShift;

  @JsonKey(name: "is_late")
  bool? isLate;

  @JsonKey(name: "is_early")
  bool? isEarly;

  ShiftFlagEntity({
    this.hasShift,
    this.isEarly,
    this.isLate,
  });

  ShiftFlagEntity copyWith({
    bool? hasShift,
    bool? isLate,
    bool? isEarly,
  }) {
    return ShiftFlagEntity(
      hasShift: hasShift ?? this.hasShift,
      isLate: isLate ?? this.isLate,
      isEarly: isEarly ?? this.isEarly,
    );
  }

  factory ShiftFlagEntity.fromJson(Map<String, dynamic> json) =>
      _$ShiftFlagEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftFlagEntityToJson(this);
}