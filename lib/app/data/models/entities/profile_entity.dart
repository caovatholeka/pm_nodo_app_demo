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

  @JsonKey()
  String? birthdayDate;

  @JsonKey()
  String? code;

  @JsonKey()
  String? avatarUrl;

  ProfileEntity({
    this.id,
    this.name,
    this.login,
    this.email,
    this.phone,
    this.birthdayDate,
    this.code,
    this.avatarUrl
  });

  ProfileEntity copyWith({
    int? id,
    String? name,
    String? login,
    String? email,
    bool? phone,
    String? birthdayDate,
    String? code,
    String? avatarUrl
  }) {
    return ProfileEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        login: login ?? this.login,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        birthdayDate: birthdayDate ?? this.birthdayDate,
        avatarUrl:avatarUrl ?? this.avatarUrl,
        code: code ?? this.code
    );
  }

  factory ProfileEntity.fromJson(Map<String, dynamic> json) => _$ProfileEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileEntityToJson(this);


}