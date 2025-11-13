import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/department_entity.dart';

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
  DepartmentEntity? department;

  @JsonKey(name: "remain_leave")
  double? remainLeave;

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
    this.department,
    this.remainLeave,
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
    DepartmentEntity? department,
    double? remainLeave,
    String? code,
    String? avatarUrl
  }) {
    return ProfileEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        login: login ?? this.login,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        department: department ?? this.department,
        remainLeave: remainLeave ?? this.remainLeave,
        birthdayDate: birthdayDate ?? this.birthdayDate,
        avatarUrl:avatarUrl ?? this.avatarUrl,
        code: code ?? this.code
    );
  }

  factory ProfileEntity.fromJson(Map<String, dynamic> json) => _$ProfileEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileEntityToJson(this);


}