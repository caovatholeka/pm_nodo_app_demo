import '../../core/network/api_client.dart';
import '../models/response/common_response.dart';

abstract class EmployeeRepository {
  Future<CommonResponse> getListEmployees({int? limit, int? offset});
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
}