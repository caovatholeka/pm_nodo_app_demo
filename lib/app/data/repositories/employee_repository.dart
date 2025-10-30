import '../../core/network/api_client.dart';
import '../models/response/common_response.dart';

abstract class EmployeeRepository {
  Future<CommonResponse> getListEmployees();
}

class EmployeeRepositoryImpl extends EmployeeRepository {
  late ApiClient _apiClient;

  EmployeeRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

  @override
  Future<CommonResponse> getListEmployees() async {
    return _apiClient.getListEmployees();
  }
}