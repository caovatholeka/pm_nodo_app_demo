import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/face_search_result_entity.dart';

part 'face_search_data_entity.g.dart';

@JsonSerializable()
class FaceSearchDataEntity {
  @JsonKey(name: "query_filename")
  String? queryFilename;

  @JsonKey(name: "top_k")
  int? topK;

  @JsonKey(name: "similarity_threshold")
  double? similarityThreshold;

  @JsonKey(name: "results_count")
  int? resultsCount;

  @JsonKey(name: "results")
  List<FaceSearchResultEntity>? searchResults;

  FaceSearchDataEntity({
    this.queryFilename,
    this.topK,
    this.similarityThreshold,
    this.resultsCount,
    this.searchResults
  });

  FaceSearchDataEntity copyWith({
    String? queryFilename,
    int? topK,
    double? similarityThreshold,
    int? resultsCount,
    List<FaceSearchResultEntity>? searchResults,
  }) {
    return FaceSearchDataEntity(
      queryFilename: queryFilename ?? this.queryFilename,
      topK: topK ?? this.topK,
      similarityThreshold: similarityThreshold ?? this.similarityThreshold,
      resultsCount: resultsCount ?? this.resultsCount,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  factory FaceSearchDataEntity.fromJson(Map<String, dynamic> json) => _$FaceSearchDataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FaceSearchDataEntityToJson(this);
}