import 'package:pm_app/app/data/models/entities/employee_entity.dart';

class MasterData {

  static const List<String> employeeStatuses = [
    'Đang làm việc', 
    'Đã nghỉ việc',  
  ];

  static List<String> getDepartmentsFromEmployees(List<EmployeeEntity> employees) {
    final departments = employees
        .map((e) => e.department)
        .where((d) => d != null && d.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return departments.cast<String>();
  }

  static List<String> getJobTitlesFromEmployees(List<EmployeeEntity> employees) {
    final jobTitles = employees
        .map((e) => e.jobTitle)
        .where((j) => j != null && j.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return jobTitles.cast<String>();
  }
}
