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

  EmployeeEntity({
    this.id,
    this.code,
    this.name,
    this.workEmail,
    this.jobTitle,
    this.department,
  });

  EmployeeEntity copyWith({
    int? id,
    String? code,
    String? name,
    String? workEmail,
    String? jobTitle,
    String? department,
  }) {
    return EmployeeEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      workEmail: workEmail ?? this.workEmail,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
    );
  }

  factory EmployeeEntity.fromJson(Map<String, dynamic> json) => _$EmployeeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeEntityToJson(this);


}