import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';
@JsonSerializable()
class UserEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  UserEntity({
    this.id,
    this.name,
  });

  UserEntity copyWith({
    int? id,
    String? name,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);
}