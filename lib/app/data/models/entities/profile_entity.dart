import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/converters/odoo_value.dart';
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

  @JsonKey(fromJson: odooStringFromJson)
  String? phone;

  @JsonKey(name: "employee_id")
  int? employeeId;

  @JsonKey(name: "x_employee_code")
  String? employeeCode;

  @JsonKey()
  DepartmentEntity? department;

  @JsonKey(name: "remain_leave")
  double? remainLeave;

  @JsonKey()
  DepartmentEntity? manager;

  @JsonKey()
  String? state;

  @JsonKey(name: "work_location")
  String? workLocation;

  @JsonKey()
  String? birthday;

  @JsonKey(name: "current_address")
  String? currentAddress;

  @JsonKey(name: "job_title")
  String? jobTitle;

  @JsonKey(name: "contract_status")
  String? contractStatus;

  @JsonKey(name: "date_join_company")
  String? dateJoinCompany;

  @JsonKey()
  String? code;

  @JsonKey(name: "avatar")
  String? avatarUrl;

  @JsonKey(name: "is_hr_director")
  bool? isHrDirector;

  @JsonKey(name: "is_director")
  bool? isDirector;

  ProfileEntity({
    this.id,
    this.name,
    this.login,
    this.email,
    this.phone,
    this.department,
    this.remainLeave,
    this.birthday,
    this.manager,
    this.state,
    this.workLocation,
    this.currentAddress,
    this.jobTitle,
    this.dateJoinCompany,
    this.contractStatus,
    this.employeeId,
    this.employeeCode,
    this.code,
    this.avatarUrl,
    this.isHrDirector,
    this.isDirector,
  });

  ProfileEntity copyWith({
    int? id,
    String? name,
    String? login,
    String? email,
    String? phone,
    int? employeeId,
    String? employeeCode,
    String? birthday,
    DepartmentEntity? department,
    double? remainLeave,
    String? state,
    String? code,
    String? avatarUrl,
    String? dateJoinCompany,
    String? contractStatus,
    String? jobTitle,
    String? currentAddress,
    String? workLocation,
    DepartmentEntity? manager,
    bool? isHrDirector,
    bool? isDirector,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      login: login ?? this.login,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      remainLeave: remainLeave ?? this.remainLeave,
      birthday: birthday ?? this.birthday,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      code: code ?? this.code,
      employeeCode: employeeCode ?? this.employeeCode,
      employeeId: employeeId ?? this.employeeId,
      manager: manager ?? this.manager,
      workLocation: workLocation ?? this.workLocation,
      currentAddress: currentAddress ?? this.currentAddress,
      jobTitle: jobTitle ?? this.jobTitle,
      contractStatus: contractStatus ?? this.contractStatus,
      dateJoinCompany: dateJoinCompany ?? this.dateJoinCompany,
      state: state ?? this.state,
      isHrDirector: isHrDirector ?? this.isHrDirector,
      isDirector: isDirector ?? this.isDirector,
    );
  }

  factory ProfileEntity.fromJson(Map<String, dynamic> json) =>
      _$ProfileEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileEntityToJson(this);
}
