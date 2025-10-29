import 'package:json_annotation/json_annotation.dart';

part 'profile_entity.g.dart';

@JsonSerializable()
class ProfileEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  @JsonKey()
  String? login;

  @JsonKey()
  String? email;

  @JsonKey()
  bool? phone;

  ProfileEntity({
    this.id,
    this.name,
    this.login,
    this.email,
    this.phone,
  });

  ProfileEntity copyWith({
    int? id,
    String? name,
    String? login,
    String? email,
    bool? phone,
  }) {
    return ProfileEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        login: login ?? this.login,
        email: email ?? this.email,
        phone: phone ?? this.phone,
    );
  }

  factory ProfileEntity.fromJson(Map<String, dynamic> json) => _$ProfileEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileEntityToJson(this);


}