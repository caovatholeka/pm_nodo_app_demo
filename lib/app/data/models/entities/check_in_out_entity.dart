import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/shift_flag_entity.dart';

part 'check_in_out_entity.g.dart';

@JsonSerializable()
class CheckInOutEntity {
  @JsonKey()
  int? id;

  @JsonKey(name: "employee_id")
  int? employeeId;

  @JsonKey(name: "employee_name")
  String? employeeName;

  @JsonKey()
  String? action;

  @JsonKey()
  String? datetime;

  @JsonKey(name: "has_face_image")
  bool? hasFaceImage;

  @JsonKey(name: "shift_flags")
  ShiftFlagEntity? shiftFlag;

  CheckInOutEntity({
    this.id,
    this.employeeId,
    this.employeeName,
    this.action,
    this.datetime,
    this.hasFaceImage,
    this.shiftFlag
  });

  CheckInOutEntity copyWith({
    int? id,
    int? employeeId,
    String? employeeName,
    String? datetime,
    bool? hasFaceImage,
    ShiftFlagEntity? shiftFlag
  }) {
    return CheckInOutEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      datetime: datetime ?? this.datetime,
      hasFaceImage : hasFaceImage ?? this.hasFaceImage,
      shiftFlag: shiftFlag ?? this.shiftFlag
    );
  }

  factory CheckInOutEntity.fromJson(Map<String, dynamic> json) => _$CheckInOutEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInOutEntityToJson(this);
}