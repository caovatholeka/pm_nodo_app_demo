import 'package:equatable/equatable.dart';

class EmployeeFilterParam extends Equatable {
  String? employeeName;
  String? employeeId;
  String? departmentName;
  String? jobType;
  String? email;
  String? status;

  EmployeeFilterParam({
    this.employeeName,
    this.employeeId,
    this.departmentName,
    this.jobType,
    this.email,
    this.status,
  });

  EmployeeFilterParam copyWith({
    String? employeeName,
    String? employeeId,
    String? departmentName,
    String? jobType,
    String? email,
    String? status,
  }) {
    return EmployeeFilterParam(
        employeeName: employeeName ?? this.employeeName,
        employeeId: employeeId ?? this.employeeId,
        departmentName: departmentName ?? this.departmentName,
        jobType: jobType ?? this.jobType,
        email: email ?? this.email,
        status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    employeeName,
    employeeId,
    departmentName,
    jobType,
    email,
    status,
  ];
}