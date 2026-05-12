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

  @JsonKey(name:"is_checked")
  bool?isChecked;

  SuggestIdEntity({
    this.id,
    this.code,
    this.name,
    this.note,
    this.isChecked,
  });

  SuggestIdEntity copyWith({
    int? id,
    String? code,
    String? name,
    String? note,
    bool? isChecked,
  }) {
    return SuggestIdEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      note: note ?? this.note,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  factory SuggestIdEntity.fromJson(Map<String, dynamic> json) =>
      _$SuggestIdEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestIdEntityToJson(this);
}