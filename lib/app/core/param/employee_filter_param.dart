class EmployeeFilterParam {
  final String? name;     
  final String? code;     
  final String? email;    
  final int? departmentId;   
  final String? jobTitle;    
  final bool? active;        

  EmployeeFilterParam({
    this.name,
    this.code,
    this.email,
    this.departmentId,
    this.jobTitle,
    this.active,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
      if (code != null && code!.trim().isNotEmpty) 'code': code!.trim(),
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      if (departmentId != null) 'department_id': departmentId,
      if (jobTitle != null) 'job_title': jobTitle,
      if (active != null) 'active': active,
    };
  }

  EmployeeFilterParam copyWith({
    String? name,
    String? code,
    String? email,
    int? departmentId,
    String? jobTitle,
    bool? active,
  }) {
    return EmployeeFilterParam(
      name: name ?? this.name,
      code: code ?? this.code,
      email: email ?? this.email,
      departmentId: departmentId ?? this.departmentId,
      jobTitle: jobTitle ?? this.jobTitle,
      active: active ?? this.active,
    );
  }

  bool get isEmpty =>
      (name == null || name!.trim().isEmpty) &&
      (code == null || code!.trim().isEmpty) &&
      (email == null || email!.trim().isEmpty) &&
      (departmentId == null) &&
      (jobTitle == null || jobTitle!.trim().isEmpty) &&
      (active == null);
}
