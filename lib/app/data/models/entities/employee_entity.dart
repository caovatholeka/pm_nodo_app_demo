import 'package:json_annotation/json_annotation.dart';

part 'employee_entity.g.dart';

@JsonSerializable()
class EmployeeEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  @JsonKey(name: "work_email")
  String? workEmail;

  @JsonKey(name: "job_title")
  String? jobTitle;

  @JsonKey()
  String? department;

  @JsonKey()
  String? avatarUrl;

  EmployeeEntity({
    this.id,
    this.code,
    this.name,
    this.workEmail,
    this.jobTitle,
    this.department,
    this.avatarUrl
  });

  EmployeeEntity copyWith({
    int? id,
    String? code,
    String? name,
    String? workEmail,
    String? jobTitle,
    String? department,
    String? avatarUrl
  }) {
    return EmployeeEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      workEmail: workEmail ?? this.workEmail,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl
    );
  }

  factory EmployeeEntity.fromJson(Map<String, dynamic> json) => _$EmployeeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeEntityToJson(this);


}