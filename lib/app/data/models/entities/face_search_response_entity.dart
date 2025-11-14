import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/face_search_data_entity.dart';

part 'face_search_response_entity.g.dart';

@JsonSerializable()
class FaceSearchResponseEntity {
  @JsonKey()
  bool? success;

  @JsonKey(name: "message")
  String? message;

  @JsonKey(name: "data")
  FaceSearchDataEntity? searchData;

  FaceSearchResponseEntity({
    this.success,
    this.message,
    this.searchData,
  });

  FaceSearchResponseEntity copyWith({
    bool? success,
    String? message,
    FaceSearchDataEntity? searchData,
  }) {
    return FaceSearchResponseEntity(
      success: success ?? this.success,
      message: message ?? this.message,
      searchData: searchData ?? this.searchData,
    );
  }

  factory FaceSearchResponseEntity.fromJson(Map<String, dynamic> json) => _$FaceSearchResponseEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FaceSearchResponseEntityToJson(this);
}