class EmployeeFilterParam {
  final String? name;
  final String? code;
  final String? email;
  final String? department;
  final String? jobTitle;
  final bool? active; 

  EmployeeFilterParam({
    this.name,
    this.code,
    this.email,
    this.department,
    this.jobTitle,
    this.active,
  });
}
