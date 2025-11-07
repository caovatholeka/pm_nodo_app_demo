import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import '../../data/models/response/common_response.dart';

abstract class EmployeeRepository {
  Future<CommonResponse> getListEmployees({
    int? limit,
    int? offset,
    String? name,
    String? code,
    String? email,
    int? departmentId,
    String? jobTitle,
    bool? active,
  });

  Future<EmployeeEntity> getDetailEmployee(int id);
}

class EmployeeRepositoryImpl extends EmployeeRepository {
  final ApiClient _apiClient;

  EmployeeRepositoryImpl(this._apiClient);

 Future<CommonResponse> getListEmployees({
  int? limit,
  int? offset,
  String? name,
  String? code,
  String? email,
  int? departmentId,
  String? jobTitle,
  bool? active,
}) {
  return _apiClient.getListEmployees(
    limit,
    offset,
    name,
    code,
    email,
    departmentId,
    jobTitle,
    active,
  );
}


  @override
  Future<EmployeeEntity> getDetailEmployee(int id) {
    return _apiClient.getDetailEmployee(id);
  }
}
