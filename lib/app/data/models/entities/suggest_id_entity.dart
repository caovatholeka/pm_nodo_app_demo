import 'package:json_annotation/json_annotation.dart';

part 'suggest_id_entity.g.dart';
@JsonSerializable()
class SuggestIdEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  @JsonKey()
  String? note;

  SuggestIdEntity({
    this.id,
    this.code,
    this.name,
    this.note
  });

  SuggestIdEntity copyWith({
    int? id,
    String? code,
    String? name,
    String? note
  }) {
    return SuggestIdEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.note,
    );
  }

  factory SuggestIdEntity.fromJson(Map<String, dynamic> json) =>
      _$SuggestIdEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestIdEntityToJson(this);
}