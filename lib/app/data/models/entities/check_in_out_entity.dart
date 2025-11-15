import 'package:json_annotation/json_annotation.dart';

part 'check_in_out_entity.g.dart';

@JsonSerializable()
class CheckInOutEntity {
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

  CheckInOutEntity({
    this.employeeId,
    this.employeeName,
    this.action,
    this.datetime,
    this.hasFaceImage
  });

  CheckInOutEntity copyWith({
    int? employeeId,
    String? employeeName,
    String? datetime,
    bool? hasFaceImage
  }) {
    return CheckInOutEntity(
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      datetime: datetime ?? this.datetime,
      hasFaceImage : hasFaceImage ?? this.hasFaceImage
    );
  }

  factory CheckInOutEntity.fromJson(Map<String, dynamic> json) => _$CheckInOutEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInOutEntityToJson(this);
}