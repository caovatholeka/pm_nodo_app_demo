import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import '../../core/network/api_util.dart';
import '../../data/models/response/common_response.dart';

abstract class EmployeeRepository {
  Future<CommonResponse> getListEmployees({
    int? limit,
    int? page,
    String? name,
    String? code,
    String? email,
    int? departmentId,
    int? jobTitleId,
    String? active,
  });

  Future<EmployeeEntity> getDetailEmployee(int id);
}

class EmployeeRepositoryImpl extends EmployeeRepository {
  // final ApiClient _apiClient;
  //
  // EmployeeRepositoryImpl(this._apiClient);
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

 @override
  Future<CommonResponse> getListEmployees({
  int? limit,
  int? page,
  String? name,
  String? code,
  String? email,
  int? departmentId,
  int? jobTitleId,
  String? active,
}) {
  return _apiClient.getListEmployees(
    limit,
    page,
    name,
    code,
    email,
    departmentId,
    jobTitleId,
    active,
  );
}


  @override
  Future<EmployeeEntity> getDetailEmployee(int id) {
    return _apiClient.getDetailEmployee(id);
  }

}
