import 'package:json_annotation/json_annotation.dart';

part 'user_approve_entity.g.dart';

@JsonSerializable()
class UserApproveEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  UserApproveEntity({
    this.id,
    this.name,
  });

  UserApproveEntity copyWith({
    int? id,
    String? name,
  }) {
    return UserApproveEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory UserApproveEntity.fromJson(Map<String, dynamic> json) =>
      _$UserApproveEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserApproveEntityToJson(this);
}