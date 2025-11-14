import 'package:json_annotation/json_annotation.dart';

part 'face_search_result_entity.g.dart';

@JsonSerializable()
class FaceSearchResultEntity {
  @JsonKey(name: "employee_name")
  String? employeeName;

  @JsonKey(name: "employee_id")
  String? employeeId;

  @JsonKey(name :"image_base64")
  String? imageBase64;

  FaceSearchResultEntity({
    this.employeeId,
    this.employeeName,
    this.imageBase64,
  });

  FaceSearchResultEntity copyWith({
    String? employeeName,
    String? employeeId,
    String? imageBase64,
  }) {
    return FaceSearchResultEntity(
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }

  factory FaceSearchResultEntity.fromJson(Map<String, dynamic> json) => _$FaceSearchResultEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FaceSearchResultEntityToJson(this);

}