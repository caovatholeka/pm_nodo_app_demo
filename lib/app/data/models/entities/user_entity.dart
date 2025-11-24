import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';
@JsonSerializable()
class UserEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  @JsonKey()
  String? avatar;

  UserEntity({
    this.id,
    this.name,
    this.avatar
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? avatar,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);
}