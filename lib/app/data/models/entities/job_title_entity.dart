import 'package:json_annotation/json_annotation.dart';

part 'job_title_entity.g.dart';

@JsonSerializable()
class JobTitleEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  JobTitleEntity({
    this.id,
    this.code,
    this.name,
  });

  JobTitleEntity copyWith({
    int? id,
    String? code,
    String? name,
  }) {
    return JobTitleEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  factory JobTitleEntity.fromJson(Map<String, dynamic> json) => _$JobTitleEntityFromJson(json);

  Map<String, dynamic> toJson() => _$JobTitleEntityToJson(this);
}