class SendInvalidParam {
  final int employeeId;
  final int departmentId;
  final String date;
  final String dateStartEmployeeCommit;
  final String dateStopEmployeeCommit;
  final String note;

  SendInvalidParam({
    required this.employeeId,
    required this.departmentId,
    required this.date,
    required this.dateStartEmployeeCommit,
    required this.dateStopEmployeeCommit,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      "employee_id": employeeId,
      "department_id": departmentId,
      "date": date,
      "date_start_employee_commit": dateStartEmployeeCommit,
      "date_stop_employee_commit": dateStopEmployeeCommit,
      "note": note,
    };
  }
}
