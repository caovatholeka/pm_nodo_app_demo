import '../../core/network/api_client.dart';
import '../models/response/common_response.dart';

abstract class EmployeeRepository {
  Future<CommonResponse> getListEmployees({int? limit, int? offset});
  Future<CommonResponse> getDetailEmployee(int id);
}

class EmployeeRepositoryImpl extends EmployeeRepository {
  late ApiClient _apiClient;

  EmployeeRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

  @override
  Future<CommonResponse> getListEmployees({int? limit, int? offset}) async {
    return _apiClient.getListEmployees(limit,offset);
  }

  @override
  Future<CommonResponse> getDetailEmployee(int id) async {
    return _apiClient.getDetailEmployee(id);
  }
}