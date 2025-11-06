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

  @JsonKey(name: "x_location_type")
  String? xlocationType;

  @JsonKey(name: "manager_by")
  String? managerby;

  @JsonKey(name: "contract_status")
  String? contractStatus;

  @JsonKey()
  String? gender;

  @JsonKey()
  String? phone;

  @JsonKey(name: "current_address")
  bool? currentAddress;

  @JsonKey()
  String? department;

  @JsonKey(name: "avatar")
  String? avatarUrl;

  @JsonKey()
  String? birthday;

  @JsonKey()
  bool? active;


  EmployeeEntity({
    this.id,
    this.code,
    this.name,
    this.workEmail,
    this.jobTitle,
    this.department,
    this.avatarUrl,
    this.active,
    this.xlocationType,
    this.managerby,
    this.contractStatus,
    this.gender,
    this.phone,
    this.currentAddress,
    this.birthday,
  });

  EmployeeEntity copyWith({
    int? id,
    String? code,
    String? name,
    String? workEmail,
    String? jobTitle,
    String? department,
    String? avatarUrl,
    bool? active,
    String? xlocationType,
    String? managerby,
    String? contractStatus,
    String? gender,
    String? phone,
    bool? currentAddress,
    String? birthday,
  }) {
    return EmployeeEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      workEmail: workEmail ?? this.workEmail,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      active: active ?? this.active,
      xlocationType: xlocationType ?? this.xlocationType,
      managerby: managerby ?? this.managerby,
      contractStatus: contractStatus ?? this.contractStatus,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      currentAddress: currentAddress ?? this.currentAddress,
      birthday: birthday ?? this.birthday,
    );
  }

  factory EmployeeEntity.fromJson(Map<String, dynamic> json) => _$EmployeeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeEntityToJson(this);


}