import 'package:json_annotation/json_annotation.dart';

part 'check_in_info_entity.g.dart';

@JsonSerializable()
class CheckInInfoEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  @JsonKey()
  String? address;

  @JsonKey()
  double? radius;

  @JsonKey()
  double? latitude;

  @JsonKey()
  double? longitude;

  CheckInInfoEntity({
    this.id,
    this.name,
    this.address,
    this.radius,
    this.latitude,
    this.longitude,
  });

  CheckInInfoEntity copyWith({
    int? id,
    double? radius,
    double? latitude,
    double? longitude,
    String? name,
    String? address
  }) {
    return CheckInInfoEntity(
        id: id ?? this.id,
        radius: radius ?? this.radius,
        longitude:  longitude ?? this.longitude,
        latitude: latitude ?? this.latitude,
        address: address ?? this.address,
        name: name ?? this.name
    );
  }

  factory CheckInInfoEntity.fromJson(Map<String, dynamic> json) => _$CheckInInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInInfoEntityToJson(this);
}