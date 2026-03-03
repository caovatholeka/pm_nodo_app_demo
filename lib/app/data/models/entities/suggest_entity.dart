import 'package:json_annotation/json_annotation.dart';

part 'suggest_entity.g.dart';

@JsonSerializable()
class SuggestEntity {
  @JsonKey()
  String? code;

  @JsonKey()
  String? name; 

  @JsonKey()
  String? note;

  SuggestEntity({
    this.code,
    this.name,
    this.note,
  });

  SuggestEntity copyWith({
    String? code,
    String? name,
    String? note,
  }) {
    return SuggestEntity(
      code: code ?? this.code,
      name: name ?? this.name,
      note: note ?? this.note,
    );
  }

  factory SuggestEntity.fromJson(Map<String, dynamic> json) =>
      _$SuggestEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestEntityToJson(this);
}