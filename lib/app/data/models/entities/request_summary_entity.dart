import 'package:json_annotation/json_annotation.dart';

part 'request_summary_entity.g.dart';

@JsonSerializable()
class RequestSummaryEntity {
  @JsonKey()
  String? key;

  @JsonKey()
  String? label;

  @JsonKey()
  int? count;

  RequestSummaryEntity({
    this.key,
    this.label,
    this.count,
  });

  RequestSummaryEntity copyWith({
    String? key,
    String? label,
    int? count,
  }) {
    return RequestSummaryEntity(
      key: key ?? this.key,
      label: label ?? this.label,
      count: count ?? this.count,
    );
  }

  factory RequestSummaryEntity.fromJson(Map<String, dynamic> json) =>
      _$RequestSummaryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RequestSummaryEntityToJson(this);
}