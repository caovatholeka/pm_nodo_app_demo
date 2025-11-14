import 'package:json_annotation/json_annotation.dart';

part 'check_in_info_entity.g.dart';

@JsonSerializable()
class CheckInInfoEntity {
  @JsonKey()
  String? workingPlaceId;

  @JsonKey()
  String? workingPlaceName;

  @JsonKey()
  String? workingPlaceAddress;

  @JsonKey()
  double? radius;

  @JsonKey()
  double? latitude;

  @JsonKey()
  double? longtitude;

  CheckInInfoEntity({
    this.workingPlaceId,
    this.workingPlaceName,
    this.workingPlaceAddress,
    this.radius,
    this.latitude,
    this.longtitude,
  });

  CheckInInfoEntity copyWith({
    String? workingPlaceId,
    double? radius,
    double? latitude,
    double? longtitude,
    String? workingPlaceName,
    String? workingPlaceAddress
  }) {
    return CheckInInfoEntity(
      workingPlaceId: workingPlaceId ?? this.workingPlaceId,
        radius: radius ?? this.radius,
        longtitude:  longtitude ?? this.longtitude,
        latitude: latitude ?? this.latitude,
      workingPlaceAddress: workingPlaceAddress ?? this.workingPlaceAddress,
      workingPlaceName: workingPlaceName ?? this.workingPlaceName
    );
  }

  factory CheckInInfoEntity.fromJson(Map<String, dynamic> json) => _$CheckInInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInInfoEntityToJson(this);
}