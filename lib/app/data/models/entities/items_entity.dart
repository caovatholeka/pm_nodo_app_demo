import 'package:json_annotation/json_annotation.dart';

part 'items_entity.g.dart';

@JsonSerializable()
class ItemsEntity {
  @JsonKey()
  String? type;

  @JsonKey()
  String? title;

  @JsonKey()
  int? count;

  @JsonKey()
  String? description;

  ItemsEntity({required this.type, required this.title, required this.count, required this.description});

  factory ItemsEntity.fromJson(Map<String, dynamic> json) =>
   _$ItemsEntityFromJson(json);
   
  Map<String, dynamic> toJson() => _$ItemsEntityToJson(this);
}